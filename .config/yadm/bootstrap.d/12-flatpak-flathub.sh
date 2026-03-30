#!/usr/bin/env bash

# 11-flatpak-repos
# Configure Flatpak remotes (Flathub)

set -euo pipefail

[[ "${BOOTSTRAP_OS:-}" == "fedora" ]] || return 0

print_msg INFO "Configuring Flatpak repositories..."

if ! flatpak remote-list | grep -q '^flathub'; then
    print_msg INFO "Adding Flathub remote..."
    require_sudo
    sudo flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo
else
    print_msg INFO "Flathub already configured"
fi
