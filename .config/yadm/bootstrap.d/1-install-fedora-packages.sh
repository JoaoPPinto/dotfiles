#!/bin/bash

set -e

FLATHUB_REPO="https://dl.flathub.org/repo/flathub.flatpakrepo"

# ensure rpm fusion is installed
printf "Ensure RPMFusion repo is installed\n"
if [ $EUID != 0 ]; then
  sudo dnf install --assumeyes --quiet  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
  dnf install --assumeyes --quiet https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi


# list all packages that need to be installed
printf "Checking ${PACKAGE_DIR}/fedora_packages.txt for packages to install...\n"
packages_to_install=()
mapfile -t package_list < "${PACKAGE_DIR}/fedora_packages.txt"
for package in ${package_list[@]}; do
	if [[ $(rpm -q "${package}" > /dev/null) ]]; then
		printf "Need to install: %s\n" "${package}"
		packages_to_install+=("${package}")
	else
		printf "Already installed: %s\n" "${package}"
	fi
done

# install the missing packages
if [[ ${#packages_to_install[@]} -gt 0 ]]; then
	printf "Installing packages: %s\n" "${packages_to_install[*]}"
	if [ $EUID != 0 ]; then
	  sudo dnf install --assumeyes --quiet ${packages_to_install[*]}
        else
          dnf install ${packages_to_install[@]}
	fi
fi

# Ensure Flatpak is installed
if [[ $( rpm -q flatpak > /dev/null ) ]]; then
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

# Install Rust
if [[ ! $(command -v rustup) ]]; then
  printf "Installing rustup\n"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
