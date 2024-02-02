#!/bin/bash


# list all packages that need to be installed
printf "Checking ${PACKAGE_DIR}/fedora_packages.txt for packages to install...\n"
packages_to_install=()
mapfile -t package_list < "${PACKAGE_DIR}/fedora_packages.txt"
for package in ${package_list[@]}; do
	if [[ ! $(rpm -q "${package}" > /dev/null) ]]; then
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
	  sudo dnf install ${packages_to_install[*]}
        else
          dnf install ${packages_to_install[@]}
	fi
fi
