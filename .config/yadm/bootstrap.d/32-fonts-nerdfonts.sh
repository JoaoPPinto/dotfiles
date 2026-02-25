#!/usr/bin/env bash

# 32-fonts-nerdfonts
# Installs needed nerdfonts on linux

set -euo pipefail

[[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]] || return 0

FONT_NAME="SourceCodePro Nerd Font"
FONT_DIR="${HOME}/.local/share/fonts"
REPO="ryanoasis/nerd-fonts"
RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"

print_msg INFO "Installing ${FONT_NAME}..."

# Check if already installed
if fc-list | grep -iq "SauceCodePro Nerd"; then
    print_msg INFO "${FONT_NAME} already installed"
    return 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

print_msg INFO "Fetching latest release of Nerd Fonts"

DOWNLOAD_URL="$(
    curl -fsSL "$RELEASE_URL" \
        | grep browser_download_url \
        | grep 'SourceCodePro.zip' \
        | cut -d '"' -f 4 \
        | head -n1
)"

[[ -n "$DOWNLOAD_URL" ]] || abort "Could not determine latest Source Code Pro Nerd Font release URL"

print_msg DEBUG "Downloading font archive from $DOWNLOAD_URL"
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/sourcecodepro.zip" \
    || abort "Failed to download font zip"

print_msg DEBUG "Extracting font archive"
unzip -q "$TMP_DIR/sourcecodepro.zip" -d "$TMP_DIR" \
    || abort "Failed to extract font zip"

print_msg INFO "Installing fonts to ${FONT_DIR}"
mkdir -p "$FONT_DIR"

# Copy all .ttf files to user font directory
find "$TMP_DIR" -type f -iname "*.ttf" -exec cp {} "$FONT_DIR/" \;

# Refresh font cache
if command -v fc-cache >/dev/null 2>&1; then
    print_msg INFO "Updating font cache"
    fc-cache -fv "$FONT_DIR" >/dev/null
else
    print_msg WARN "fc-cache not found; you may need to update your font cache manually"
fi

print_msg INFO "${FONT_NAME} installed successfully"
