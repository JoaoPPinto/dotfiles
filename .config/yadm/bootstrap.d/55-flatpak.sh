#!/bin/bash

set -e

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


