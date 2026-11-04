# dotfiles

Personal dotfiles, managed with yadm. Designed around Fedora and CachyOS.

## Dependencies
 
### Required
 
| Tool | Why | Fedora | Arch / CachyOS |
|---|---|---|---|
| zsh | The shell | `zsh` | `zsh` |
| git | Cloning, and fetching the plugin submodules | `git` | `git` |
| less | `PAGER` | `less` | `less` |
| neovim | `EDITOR`, and the `vim` alias | `neovim` | `neovim` |
 
### Optional
 
The config degrades gracefully without these.
 
| Tool | Why | Fedora | Arch / CachyOS |
|---|---|---|---|
| bat | `cat` alias (only set if `bat` is installed) | `bat` | `bat` |
| foot | `TERMINAL` is set to it | `foot` | `foot` |
| ripgrep | Not aliased, but the intended `grep` replacement | `ripgrep` | `ripgrep` |
| fd | Not aliased, but the intended `find` replacement | `fd-find` | `fd` |

## Setup on a new machine
 
```sh
yadm clone https://github.com/JoaoPPinto/dotfiles.git
yadm bootstrap
```
 
## Machine classes
 
Templates and alternates branch on two classes. Set them on each host to match
that machine's hardware; having neither is valid.
 
| Class | Meaning | Affects |
|---|---|---|
| `desktop` | Fixed monitors, not a laptop | `waybar/config##template`, `sway/config.d/70-output.conf##c.desktop` |
| `nvidia` | Nvidia GPU present | `sway/environment##template` pulls in `sway/environment.nvidia` |
 
```sh
yadm config --add local.class desktop
yadm config --add local.class nvidia
yadm alt          # re-render templates after changing a class
```
 
## Bootstrap

Run `yadm bootstrap` from a graphical session.

`yadm bootstrap` runs `.config/yadm/bootstrap`, which executes every executable
file in `.config/yadm/bootstrap.d/` in sorted order, each as its own process.
Every step is idempotent, so re-running is safe.
 
| Step | What it does |
|---|---|
| `10-confirm-class` | Prints distro, hostname and classes, then asks to continue |
| `15-fedora-rpmfusion` | Fedora only: ensures RPM Fusion free and nonfree match the running release |
| `20-packages` | Installs `packages.d/core.<family>` and `packages.d/desktop.<family>`, plus `packages.d/aur.<family>` when present |
| `40-submodules` | Initializes the pinned zsh plugin submodules |
| `50-directories` | Creates the zsh cache and data directories `~/.config/zsh/.zshrc` expects |
| `60-systemd-user` | Reloads the user manager and enables tracked units that declare an install target |
| `70-shell` | Makes zsh the login shell |

`bootstrap.lib.sh` holds the shared helpers. It is not a step: it lives outside
`bootstrap.d/` and is not executable.

`60-systemd-user` skips itself when there is no `systemctl` or no systemd user
manager, and skips units without an `[Install]` section — such a unit is pulled
in by another unit and `systemctl` refuses to enable it. `swayidle.service` uses
`WantedBy=graphical-session.target`, so sway's `sway-session.target` starts it
with the session. Enabling it creates a `.wants` symlink under
`~/.config/systemd/user/`, which yadm reports as an untracked file.
 
### Skipping a step
 
Clear its executable bit. yadm tracks that bit, so the change shows up in the
repo; commit it if the step should stay off.
 
```sh
chmod -x .config/yadm/bootstrap.d/20-packages
yadm add --chmod=-x .config/yadm/bootstrap.d/20-packages
```
 
### Package lists
 
Package names live in `.config/yadm/packages.d/<group>.<family>` — one name per
line, blank lines and `#` comments ignored. The groups are `core` (shell, git,
CLI tools), `desktop` (sway and everything its config calls), and `aur`, which
is optional and only present where the distro carries packages its own package
manager cannot install. A missing `core` or `desktop` list is an error; a missing
`aur` list is not. Adding a group means a new step and the matching list files;
adding a distro family means only list files, plus a case for it in
`install_packages`.

`aur.<family>` is installed with `paru` or `yay` when one is on `PATH`, and not
through sudo — both helpers refuse to run as root. With neither installed the
group is skipped with a warning, because these are extras and failing on them
would stop the rest of the bootstrap. On Arch that currently means
`sway-systemd`, whose config paths sway's main config includes.

Sound servers are out of scope: the lists install the `pactl` client used by the
volume bindings and the waybar pulseaudio module, not PipeWire or its session
manager.
 
## Bootstrap extension points
 
Deliberate limitations, noted rather than solved.
 
- **Linux only.** `detect_distro` reads `/etc/os-release`, which does not exist
  on macOS, so the run aborts there rather than guessing. Supporting Darwin
  would need a `uname -s` branch, plus `install_packages` gaining a Homebrew
  arm that does **not** run under sudo — `sudo brew` is unsupported and breaks
  ownership of `/opt/homebrew`.
- **Sudo is requested up front** by the runner. On a machine where every package
  is already installed, that prompt is unnecessary. Moving it into the steps
  that actually need root would fix this.
- **Package manager is chosen from the distro family**, not from what the
  machine has. Dispatching on `command -v brew/dnf/pacman` instead would let new
  distros work without a family table.
- **Systemd-specific work does not port.** Fetching submodules, creating
  directories and `chsh` would run anywhere, but a step enabling a systemd user
  unit (`swayidle.service`) assumes a systemd user session and would have to
  skip itself on any host without one.

## Updating plugins
 
Submodules are pinned to a specific commit. To update:
 
```sh
yadm submodule update --remote --merge
yadm add .config/zsh/plugins
yadm commit -m "Update zsh plugins"
```

