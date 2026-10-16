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
```

## Updating plugins
 
Submodules are pinned to a specific commit. To update:
 
```sh
yadm submodule update --remote --merge
yadm add .config/zsh/plugins
yadm commit -m "Update zsh plugins"
```

