# Sway config

This is heavily lifted from fedora sway spin's default configuration.
If using Fedora with the way and sway-systemd packages, the manual setup steps
are not needed
It is recommended to start sway with the `start-sway` script
`libexec` contents should be placed in `/usr/libexec/` as several config files depend on these utilities.
`session/start-sway` should be placed in `/usr/bin/`
`session/sway.desktop` should be placed in `/usr/share/wayland-sessions/`
`session/environment` should be placed in `/etc/sway/`
