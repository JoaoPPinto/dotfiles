#!/bin/bash


FLATHUB_REPO="https://dl.flathub.org/repo/flathub.flatpakrepo"

# Ensure Flatpak is installed
[[ $(rpm -q flatpak) ]] || dnf install flatpak -y

# Set Flathub repo
flatpak remote-add --if-not-exists flathub ${FLATHUB_REPO}
