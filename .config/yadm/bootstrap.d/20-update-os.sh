#!/usr/bin/env bash
# 21-update-os
# Updates the base OS packages

set -euo pipefail

print_msg INFO "Updating base OS packages"

case "${BOOTSTRAP_OS:-}" in
    fedora)
        print_msg INFO "Updating Fedora system packages..."
        require_sudo
        sudo dnf upgrade --assumeyes --quiet --refresh
        ;;
    ubuntu|debian)
        print_msg INFO "Updating ${BOOTSTRAP_OS^} system packages..."
        require_sudo
        sudo apt update -y
        sudo apt upgrade -y
        ;;
    *)
        print_msg WARN "Base OS update not supported for $BOOTSTRAP_OS. Skipping..."
        ;;
esac

print_msg INFO "Base OS packages update complete."
