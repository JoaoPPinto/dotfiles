#!/usr/bin/env bash

set -euo pipefail

# Only run on Fedora
if [[ "${BOOTSTRAP_OS:-}" != "fedora" ]]; then
    print_msg DEBUG "Skipping Fedora package installation (not Fedora)"
    return 0
fi

print_msg INFO "Installing Fedora packages..."

PACKAGE_FILE="${PACKAGE_DIR}/fedora.txt"

print_msg DEBUG "Checking ${PACKAGE_DIR}/fedora.txt for packages to install..."

PACKAGE_FILE="${PACKAGE_DIR}/fedora.txt"
[[ -f "$PACKAGE_FILE" ]] || abort "Missing package file: $PACKAGE_FILE"

mapfile -t package_list < <(
    grep -Ev '^\s*#|^\s*$' "$PACKAGE_FILE"
)

packages_to_install=()

for package in "${package_list[@]}"; do
    if ! rpm -q "$package" >/dev/null 2>&1; then
        packages_to_install+=("$package")
    fi
done

if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
    print_msg INFO "Installing packages: ${packages_to_install[*]}"

    if [[ "$EUID" -ne 0 ]]; then
        sudo dnf install --assumeyes --quiet --allowerasing "${packages_to_install[@]}"
    else
        dnf install --assumeyes --quiet --allowerasing "${packages_to_install[@]}"
    fi
else
    print_msg INFO "All Fedora packages already installed"
fi

print_msg INFO "Fedora package installation complete"
