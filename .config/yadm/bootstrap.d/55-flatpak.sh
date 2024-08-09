#!/bin/bash

set -e

printf "Starting Flatpak setup\n"

FLATHUB_REPO="https://dl.flathub.org/repo/flathub.flatpakrepo"

# Ensure Flatpak is installed
if ! rpm -q flatpak > /dev/null; then
  printf "Installing Flatpak\n"
  if [ $EUID != 0 ]; then
    sudo dnf install --assumeyes --quiet flatpak
  else
    dnf install --assumeyes --quiet flatpak
  fi
fi

# Set Flathub repo
printf "Setting Flathub repo\n"
flatpak remote-add --if-not-exists flathub ${FLATHUB_REPO}

# Check if flatpak packages are installed
printf "Checking %s/flatpak.txt for packages to install...\n" "${PACKAGE_DIR}"
packages_to_install=()
mapfile -t package_list < <( grep -vE '^$|#' "${PACKAGE_DIR}/flatpak.txt" )
for package in "${package_list[@]}"; do
	if ! flatpack list | grep -q "$package"; then
		packages_to_install+=("${package}")
	fi
done

# install the missing packages
if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
	printf "Installing packages: %s\n" "${packages_to_install[*]}"
	if [ $EUID != 0 ]; then
		printf "%s\n" "${packages_to_install[@]}" | xargs sudo flatpak install --noninteractive
	else
		prints "%s\n" "${packages_to_install[@]}" | xargs flatpak install --noninteractive
	fi
fi

printf "End Flatpak Setup\n"
