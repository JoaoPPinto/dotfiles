#!/usr/bin/env bash

# 10-repos-fedora
# Adds additional repositories (RPM Fusion)

[[ "$BOOTSTRAP_OS" == "fedora" ]] || return 0

print_msg INFO "Adding extra Fedora repositories (RPM Fusion)..."

if ! dnf repo list | awk '{print $1}' | grep -q '^rpmfusion-free'; then
    print_msg INFO "Enabling RPM Fusion Free repository..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
else
    print_msg INFO "RPM Fusion Free already enabled"
fi

if ! dnf repo list | awk '{print $1}' | grep -q '^rpmfusion-nonfree'; then
    print_msg INFO "Enabling RPM Fusion Non-Free repository..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    print_msg INFO "RPM Fusion Non-Free already enabled"
fi
