#!/usr/bin/env bash

# 10-repos-fedora
# Adds additional repositories (RPM Fusion)

set -euo pipefail

[[ "$BOOTSTRAP_OS" == "fedora" ]] || return 0

print_msg INFO "Adding extra Fedora repositories (RPM Fusion)..."

FEDORA_VERSION="$(rpm -E %fedora)"

if ! rpm -q rpmfusion-free-release &>/dev/null; then
    print_msg INFO "Enabling RPM Fusion Free repository..."
    sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
        || abort "Failed to enable RPM Fusion Free"
else
    print_msg INFO "RPM Fusion Free already enabled"
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    print_msg INFO "Enabling RPM Fusion Non-Free repository..."
    sudo dnf install -y \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm" \
        || abort "Failed to enable RPM Fusion Non-Free"
else
    print_msg INFO "RPM Fusion Non-Free already enabled"
fi

