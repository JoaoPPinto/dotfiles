#!/bin/bash

declare -r THEME_DIR="$HOME/.local/share/themes"

[[ -n "${HOME}" && ! -d "${THEME_DIR}" ]] && mkdir -p "${THEME_DIR}"

function download_catppuccin_theme() {
  local url="https://github.com/catppuccin/gtk/releases/download"
  local version="v0.7.1"
  local theme="$1"
  printf "Downloading %s theme...\n" "${theme}"
  curl -s -fLO "${url}/${version}/${theme}.zip" --output-dir "${THEME_DIR}"
  unzip -q "${THEME_DIR}/${theme}.zip" -d "${THEME_DIR}"
  rm -f "${THEME_DIR}/${theme}.zip"
}

download_catppuccin_theme "Catppuccin-Mocha-Standard-Blue-Dark"
download_catppuccin_theme "Catppuccin-Mocha-Standard-Teal-Dark"
download_catppuccin_theme "Catppuccin-Mocha-Standard-Peach-Dark"
download_catppuccin_theme "Catppuccin-Mocha-Standard-Yellow-Dark"
download_catppuccin_theme "Catppuccin-Mocha-Standard-Lavender-Dark"

# Ensure icon theme is installed
if [[ ! $( rpm -q numix-icon-theme > /dev/null ) ]]; then
  printf "Installing Numix icon theme\n"
  if [ $EUID != 0 ]; then
    sudo dnf install --assumeyes --quiet numix-icon-theme
  else
    dnf install --quiet --assumeyes numix-icon-theme
  fi
fi

printf "Setting themes in gsettings\n"
gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha-Standard-Blue-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Numix"
