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
  local fonts="$@"
  for font in ${fonts[@]}; do
    download_font "${family}" "${font}-BoldItalic.ttf"
    download_font "${family}" "${font}-Bold.ttf"
    download_font "${family}" "${font}-Italic.ttf"
    download_font "${family}" "${font}-Regular.ttf"
  done
}

SOURCE_CODE_PRO_FONT_TYPES=("SauceCodeProNerdFont" "SauceCodeProNerdFontMono" "SauceCodeProNerdFontPropo")

download_font_family "SourceCodePro" "${SOURCE_CODE_PRO_FONT_TYPES[@]}"

