# Sway config

This is heavily lifted from fedora sway spin's default configuration.
If using Fedora with the way and sway-systemd packages, the manual setup steps
are not needed
It is recommended to start sway with the `start-sway` script
`session/start-sway` should be placed in `/usr/bin/`
`session/sway.desktop` should be placed in `/usr/share/wayland-sessions/`
`session/environment` should be placed in `/etc/sway/`

Relies on the following being installed:
- sway utilities (swaybg, swaylock, swayidle)
- sway-contrib and sway-systemd (on fedora and arch)
- waybar
- rofi
- foot
- brightnessctl >= 0.5.1
- libpulse (for pactl used in libexec/sway/volume-helper)
- libnotify (for notify-send)
- playerctl
- lxqt-policykit
- xdg-user-dirs
- xdg-desktop-portal-wlr
- xorg-xwayland
