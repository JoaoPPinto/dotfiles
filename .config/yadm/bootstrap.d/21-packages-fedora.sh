#!/usr/bin/env bash

# 20-fedora-packages
# Install requested packages on fedora installations

set -euo pipefail

# Only run on Fedora
if [[ "${BOOTSTRAP_OS:-}" != "fedora" ]]; then
    print_msg DEBUG "Skipping Fedora package installation (not Fedora)"
    return 0
fi

print_msg INFO "Installing Fedora packages..."
print_msg DEBUG "Checking ${PACKAGE_DIR}/fedora.txt for packages to install..."

PACKAGE_FILE_FEDORA="${PACKAGE_DIR}/fedora.txt"
[[ -f "$PACKAGE_FILE_FEDORA" ]] || abort "Missing package file: $PACKAGE_FILE_FEDORA"

mapfile -t desired_packages < <(
    sed -e 's/\r$//' \
        -e 's/#.*//' \
        -e '/^[[:space:]]*$/d' \
        "$PACKAGE_FILE_FEDORA"
)

declare -A installed_map
while read -r pkg; do
    installed_map["$pkg"]=1
done < <(rpm -qa --qf '%{NAME}\n')

packages_to_install=()

for pkg in "${desired_packages[@]}"; do
    if [[ -z "${installed_map[$pkg]+x}" ]]; then
        packages_to_install+=("$pkg")
    fi
done

if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
    print_msg INFO "Installing ${#packages_to_install[@]} packages"
    print_msg DEBUG "Packages: ${packages_to_install[*]}"

    require_sudo
    sudo dnf install --assumeyes --quiet --allowerasing "${packages_to_install[@]}"
else
    print_msg INFO "All Fedora packages already installed"
fi

print_msg INFO "Fedora package installation complete"
