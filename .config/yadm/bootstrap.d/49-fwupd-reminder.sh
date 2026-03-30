#!/usr/bin/env bash
# 49-fwupd-reminder
# Reminds the user to check for firmware updates using fwupdmgr

set -euo pipefail

stage "Firmware Update Reminder"

# Only run on Linux
[[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]] || return 0

if ! command -v fwupdmgr >/dev/null 2>&1; then
    print_msg WARN "fwupdmgr not installed. Ensure you install it to enable firmware updates. Skipping."
    return 0
fi

# Check if there are available updates
AVAILABLE_UPDATES="$(fwupdmgr get-updates 2>/dev/null || true)"

if [[ -n "$AVAILABLE_UPDATES" ]]; then
    print_msg WARN "Firmware updates are available!"
    echo
    echo "Run the following command to update your system firmware:"
    echo "  sudo fwupdmgr update"
    echo
    print_msg INFO "You may need to reboot after firmware updates."
else
    print_msg INFO "No firmware updates available at this time."
fi
