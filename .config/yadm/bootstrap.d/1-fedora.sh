#!/bin/bash

set -e

# Check if the current distro is Fedora, otherwise exit without error and continue
if [[ $(lsb_release -si) != "Fedora" ]]; then
  printf "Not Fedora, skipping to next distro file"
  exit 0
fi

# ensure rpm fusion is installed
printf "Ensure RPMFusion repo is installed\n"
if [ $EUID != 0 ]; then
  sudo dnf install --assumeyes --quiet  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
else
  dnf install --assumeyes --quiet https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
fi


# list all packages that need to be installed
printf "Checking %s/fedora_packages.txt for packages to install...\n" "${PACKAGE_DIR}"
packages_to_install=()
mapfile -t package_list < "${PACKAGE_DIR}/fedora_packages.txt"
for package in "${package_list[@]}"; do
	if [[ $(rpm -q "${package}" > /dev/null) ]]; then
		printf "Need to install: %s\n" "${package}"
		packages_to_install+=("${package}")
	else
		printf "Already installed: %s\n" "${package}"
	fi
done

# install the missing packages
if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
	printf "Installing packages: %s\n" "${packages_to_install[*]}"
	if [ $EUID != 0 ]; then
	  sudo dnf install --assumeyes --quiet "${packages_to_install[*]}"
        else
          dnf install "${packages_to_install[@]}"
	fi
fi

