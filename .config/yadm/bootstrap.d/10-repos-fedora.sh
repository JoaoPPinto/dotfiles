#!/usr/bin/env bash

# 10-repos-fedora
# Adds additional repositories (RPM Fusion)

set -euo pipefail

[[ "$BOOTSTRAP_OS" == "fedora" ]] || return 0

print_msg INFO "Adding extra Fedora repositories (RPM Fusion)..."

FEDORA_VERSION="$(rpm -E %fedora)"

enable_repo() {
    local name="$1"
    local url="$2"

    if ! rpm -q "$name" &>/dev/null; then
        print_msg INFO "Enabling $name..."
        require_sudo
        sudo dnf install -y --setopt=install_weak_deps=False "$url" \
            || abort "Failed to enable $name"
    else
        print_msg INFO "$name already enabled"
    fi
}

enable_repo "rpmfusion-free-release" "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"

enable_repo "rpmfusion-nonfree-release" "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

