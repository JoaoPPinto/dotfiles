#!/bin/bash
# Install Jetbrains Toolbox App
# Heavily lifted from https://github.com/nagygergo/jetbrains-toolbox-install

set -e

printf "Starting Jetbrains Toolbox Install\n"

INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox/bin"
SYMLINK_DIR="$HOME/.local/bin"

printf "Downloading archive...\n"
ARCHIVE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")i
rm "$TMP_DIR/$ARCHIVE_FILENAME" 2>/dev/null || true
wget -q --show-progress -cO "/tmp/$ARCHIVE_FILENAME" "$ARCHIVE_URL"

printf "Extracting to installation directory...\n"
mkdir -p "$INSTALL_DIR"
rm "$INSTALL_DIR/jetbrains-toolbox" 2>/dev/null || true
tar -xzf "/tmp/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
rm "/tmp/$ARCHIVE_FILENAME"
chmod +x "$INSTALL_DIR/jetbrains-toolbox"
# Symlink
mkdir -p $SYMLINK_DIR
rm "$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
ln -s "$INSTALL_DIR/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

printf "End Jetbrains Toolbox Install\n"
