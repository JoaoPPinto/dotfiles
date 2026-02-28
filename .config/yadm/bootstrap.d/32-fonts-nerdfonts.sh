#!/usr/bin/env bash

# 32-fonts-nerdfonts
# Installs specified nerdfonts on linux

set -euo pipefail

[[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]] || return 0

# Define fonts as pairs: FONT_NAME|FONT_FAMILY
# example: "SourceCodePro|SauceCodePro Nerd Font"

nerd_fonts=(
    "SourceCodePro|SauceCodePro Nerd Font"
    "FiraCode|FiraCode Nerd Font"
)

print_msg INFO "Installing Nerd Fonts..."

FONT_DIR="${HOME}/.local/share/fonts"
mkdir -p "$FONT_DIR"

for font_pair in "${nerd_fonts[@]}"; do
    IFS='|' read -r FONT_NAME FONT_FAMILY <<< "$font_pair"

    DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_NAME.zip"

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    print_msg INFO "Installing ${FONT_NAME}"
    if command -v fc-list >/dev/null 2>&1; then
        if fc-list -q "$FONT_FAMILY"; then
            print_msg INFO "${FONT_NAME} already installed"
            continue
        fi
    else
        print_msg WARN "fc-list not found; cannot verify font installation. Proceeding..."
    fi

    ARCHIVE="${TMP_DIR}/${FONT_NAME}.zip"
    print_msg DEBUG "Downloading font archive from $DOWNLOAD_URL"
    curl -fsSL "$DOWNLOAD_URL" -o "$ARCHIVE" \
        || abort "Failed to download font zip"

    print_msg DEBUG "Extracting font archive"
    unzip -q "$ARCHIVE" -d "$TMP_DIR" \
        || abort "Failed to extract font zip"

    print_msg INFO "Installing fonts to ${FONT_DIR}"
    mkdir -p "$FONT_DIR"

    cp "$TMP_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null \
        || abort "No TTF files found in archive"

    if command -v fc-cache >/dev/null 2>&1; then
        print_msg INFO "Updating font cache"
        fc-cache -fv "$FONT_DIR" >/dev/null
    else
        print_msg WARN "fc-cache not found; you may need to update your font cache manually"
    fi

    print_msg INFO "${FONT_NAME} installed successfully"
done
