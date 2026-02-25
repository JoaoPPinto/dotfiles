#!/usr/bin/env bash

# 31-theme-gruvbox-icons
# Installs and applies Gruvbox Plus Icon Theme

set -euo pipefail

[[ "$BOOTSTRAP_PLATFORM" == "linux" ]] || return 0

print_msg INFO "Installing Gruvbox Plus icon pack..."

ICON_DARK="Gruvbox-Plus-Dark"
ICON_LIGHT="Gruvbox-Plus-Light"
ICON_BASE_DIR="/usr/share/icons"
REPO="SylEleuth/gruvbox-plus-icon-pack"
RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"

install_needed=0

[[ -d "${ICON_BASE_DIR}/${ICON_DARK}" ]] || install_needed=1
[[ -d "${ICON_BASE_DIR}/${ICON_LIGHT}" ]] || install_needed=1

if [[ "$install_needed" -eq 0 ]]; then
    print_msg INFO "Gruvbox Plus icon pack already installed"
else
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    print_msg INFO "Fetching latest release"

    DOWNLOAD_URL="$(
        curl -fsSL "$RELEASE_URL" \
        | grep browser_download_url \
        | grep '\.zip' \
        | cut -d '"' -f 4 \
        | head -n1
    )"

    [[ -n "$DOWNLOAD_URL" ]] \
        || abort "Could not determine latest release download URL"

    print_msg DEBUG "Downloading latest release"
    curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/icons.zip" \
        || abort "Failed to download icon pack"

    print_msg DEBUG "Extracting archive"
    unzip -q "$TMP_DIR/icons.zip" -d "$TMP_DIR" \
        || abort "Failed to extract icon pack"

    print_msg INFO "Installing icon theme to /usr/share/icons"
    sudo mkdir -p /usr/share/icons

    for ICON in "$ICON_DARK" "$ICON_LIGHT"; do
        if [[ -d "$TMP_DIR/$ICON" ]]; then
            sudo cp -r "$TMP_DIR/$ICON" "$ICON_BASE_DIR/" \
                || abort "Failed to install $ICON"
        else
            abort "Could not find $ICON in the extracted archive"
        fi
    done

    sudo gtk-update-icon-cache "${ICON_BASE_DIR}/${ICON_DARK}" || true
    sudo gtk-update-icon-cache "${ICON_BASE_DIR}/${ICON_LIGHT}" || true

    print_msg INFO "Gruvbox Plus icon pack installed (Dark & Light)"
fi

DEFAULT_ICON="${ICON_DARK}"

if command -v gsettings >/dev/null 2>&1; then
    CURRENT_ICONS="$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")"

    if [[ "$CURRENT_ICONS" != "$DEFAULT_ICON" ]]; then
        print_msg INFO "Applying default icon theme: ${DEFAULT_ICON}"
        gsettings set org.gnome.desktop.interface icon-theme "$DEFAULT_ICON"
    else
        print_msg INFO "Icon theme already set to ${DEFAULT_ICON}"
    fi
else
    print_msg WARN "gsettings not available; cannot apply icon theme automatically"
fi
