#!/usr/bin/env bash
# 21-update-os
# Updates the base OS packages

set -euo pipefail

print_msg INFO "Updating base OS packages"

REBOOT_REQUIRED=0

case "${BOOTSTRAP_OS:-}" in
    fedora)
        print_msg INFO "Updating Fedora system packages..."
        require_sudo
        sudo dnf upgrade --assumeyes --quiet --refresh
        if sudo dnf needs-restarting -r >/dev/null 2>&1; then
            REBOOT_REQUIRED=1
        fi
        ;;
    ubuntu|debian)
        print_msg INFO "Updating ${BOOTSTRAP_OS^} system packages..."
        require_sudo
        sudo apt update -y
        sudo apt upgrade -y
        if [[ -f /var/run/reboot-required ]]; then
            REBOOT_REQUIRED=1
        fi
        ;;
    *)
        print_msg WARN "Base OS update not supported for $BOOTSTRAP_OS. Skipping..."
        ;;
esac

if [[ "$REBOOT_REQUIRED" -eq 1 ]]; then
    print_msg WARN "A kernel or critical system update was installed."
    print_msg WARN "Please reboot the system before continuing the bootstrap process."
    print_msg WARN "Run: sudo reboot"
    exit 0
fi

print_msg INFO "Base OS packages update complete."
