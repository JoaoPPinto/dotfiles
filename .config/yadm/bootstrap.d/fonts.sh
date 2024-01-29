#!/bin/bash


declare -r FONT_DIR="${HOME}/.local/share/fonts"

[[ -n "${HOME}" && ! -d "${FONT_DIR}" ]] && mkdir -p "${FONT_DIR}"

function download_font() {
  local url="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts"
  local family="$1"
  local file="$2"
  curl -s -fLO "${url}/${family}/${file}" --output-dir "${FONT_DIR}"
}

function download_font_family() {
  local family="$1"
  shift
  local fonts=( $@ )
  local font_weights=("Bold" "BoldItalic" "Italic" "Regular")
  for font in "${fonts[@]}"; do
    for font_weight in "${font_weights[@]}"; do
      if [[ ! -f "${FONT_DIR}/${font}-${font_weight}.ttf" ]]; then
        printf "Font ${font}-${font_weight} not found. Downloading...\n"
        download_font "${family}" "${font}-${font_weight}.ttf"
      fi
    done
  done
}

SOURCE_CODE_PRO_FONT_TYPES=("SauceCodeProNerdFont" "SauceCodeProNerdFontMono" "SauceCodeProNerdFontPropo")

download_font_family "SourceCodePro" "${SOURCE_CODE_PRO_FONT_TYPES[@]}"

