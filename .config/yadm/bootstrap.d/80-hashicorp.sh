#!/bin/bash

set -e

printf "bootstrap.d - hashicorp start\n"

HASHICORP_FEDORA_REPO="https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
PACKAGES=("vault" "nomad" "consul" "terraform" "packer")

if [[ $(lsb_release -si) = "Fedora" ]]; then
  printf "Adding Fedora Hashicorp repo ...\n"
  if [ $EUID != 0 ]; then
    dnf config-manager --add-repo "$HASHICORP_FEDORA_REPO"
  else
    sudo dnf config-manager --add-repo "$HASHICORP_FEDORA_REPO"
fi

 printf "Installing packages: %s\n" "${PACKAGES[*]}"
if [ $EUID != 0 ]; then
    printf "%s\n" "${PACKAGES[@]}" | xargs sudo dnf install --assumeyes --quiet --allowerasing
else
    printf "%s\n" "${PACKAGES[@]}" | xargs dnf install --assumeyes --quiet --allowerasing
fi
