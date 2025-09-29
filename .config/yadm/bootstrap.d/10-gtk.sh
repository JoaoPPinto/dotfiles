#!/bin/bash

set -e

printf "bootstrap.d - gtk starting\n"

declare -r THEME_DIR="$HOME/.local/share/themes"

CATPUCCIN_THEMES=(
  "catppuccin-mocha-blue-standard+default"
  "catppuccin-mocha-teal-standard+default"
  "catppuccin-mocha-peach-standard+default"
  "catppuccin-mocha-yellow-standard+default"
  "catppuccin-mocha-lavender-standard+default"
)

[[ -n "${HOME}" && ! -d "${THEME_DIR}" ]] && mkdir -p "${THEME_DIR}"

function download_catppuccin_theme() {
  local url="https://github.com/catppuccin/gtk/releases/download"
  local version="v1.0.3"
  local theme="$1"

  if [[ ! -d "${THEME_DIR}/${theme}" ]]; then
    printf "Downloading %s theme...\n" "${theme}"
    curl -s -fLO "${url}/${version}/${theme}.zip" --output-dir "${THEME_DIR}"
    unzip -q "${THEME_DIR}/${theme}.zip" -d "${THEME_DIR}"
    rm -f "${THEME_DIR}/${theme}.zip"
  fi
}

for theme in "${CATPUCCIN_THEMES[@]}"; do
  download_catppuccin_theme "$theme"
done

# Ensure icon theme is installed
if [[ $( rpm -q numix-icon-theme > /dev/null ) ]]; then
  printf "Installing Numix icon theme\n"
  if [ $EUID != 0 ]; then
    sudo dnf install --assumeyes --quiet numix-icon-theme
  else
    dnf install --quiet --assumeyes numix-icon-theme
  fi
fi

printf "Setting themes in gsettings\n"
#gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha-Standard-Blue-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Numix"

printf "bootstrap.d - gtk ending\n"
