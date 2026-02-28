#!/usr/bin/env bash

# 05-detect-os
# Detects the Operating System the bootstrap is currently running on
# and ensure it is supported
# Exposes the following variables for use by other bootstrap scripts
# BOOTSTRAP_PLATFORM = linux | macos
# BOOTSTRAP_OS = fedora | ubuntu | debian | macos
# BOOTSTRAP_ARCH = amd64 | arm64

set -euo pipefail

print_msg INFO "Detecting OS ..."

readonly UNAME_S="$(uname -s)"
readonly UNAME_M="$(uname -m)"

# ---- Architecture detection -------------------------------------------------

case "$UNAME_M" in
    x86_64|amd64)
        BOOTSTRAP_ARCH="amd64"
        ;;
    aarch64|arm64)
        BOOTSTRAP_ARCH="arm64"
        ;;
    *)
        abort "Unsupported architecture: $UNAME_M"
        ;;
esac

# ---- Platform detection -----------------------------------------------------

case "$UNAME_S" in
    Darwin)
        BOOTSTRAP_PLATFORM="macos"
        BOOTSTRAP_OS="macos"
        ;;
    Linux)
        BOOTSTRAP_PLATFORM="linux"
        ;;
    *)
        abort "Unsupported platform: $UNAME_S"
        ;;
esac

# ---- Linux distribution detection ------------------------------------------

if [[ "$BOOTSTRAP_PLATFORM" == "linux" ]]; then
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
    else
        abort "Cannot detect Linux distribution (missing /etc/os-release)"
    fi

    case "${ID:-}" in
        fedora)
            BOOTSTRAP_OS="fedora"
            ;;
        ubuntu)
            BOOTSTRAP_OS="ubuntu"
            ;;
        debian)
            BOOTSTRAP_OS="debian"
            ;;
        *)
            abort "Unsupported Linux distribution: ${ID:-unknown}"
            ;;
    esac
fi

export BOOTSTRAP_ARCH BOOTSTRAP_PLATFORM BOOTSTRAP_OS
readonly BOOTSTRAP_ARCH BOOTSTRAP_PLATFORM BOOTSTRAP_OS

print_msg INFO "Platform : $BOOTSTRAP_PLATFORM"
print_msg INFO "OS       : $BOOTSTRAP_OS"
print_msg INFO "Arch     : $BOOTSTRAP_ARCH"
