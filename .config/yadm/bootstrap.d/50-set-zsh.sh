#!/usr/bin/env bash

# 50-set-zsh
# Changes the current user's shell to Zsh if not already

set -euo pipefail

print_msg INFO "Setting Zsh as default shell"

# Ensure Zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
    print_msg WARN "Zsh not installed. Skipping shell change."
    return 0
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$(command -v zsh)" ]]; then
    print_msg INFO "Zsh is already the default shell for $USER"
    return 0
fi

print_msg INFO "Changing default shell for $USER to Zsh"

# Non-root user, can change own shell
chsh -s "$(command -v zsh)"

print_msg INFO "Default shell changed to Zsh. You may need to log out and log back in."
