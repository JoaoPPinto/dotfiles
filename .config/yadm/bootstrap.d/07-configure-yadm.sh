#!/usr/bin/env bash
# 07-yadm-configuration
# Configures yadm identity and repository settings

set -euo pipefail

print_msg INFO "Configuring yadm ..."

declare -a CLASSES=()

CLASSES+=("${BOOTSTRAP_PLATFORM}")

[[ "${HAS_NVIDIA:-0}" -eq 1 ]] && CLASSES+=("nvidia")
[[ "${IS_LAPTOP:-0}" -eq 1 ]] && CLASSES+=("laptop")

print_msg INFO "Applying yadm classes: ${CLASSES[*]}"

while yadm config --get local.class >/dev/null 2>&1; do
    yadm config --unset local.class || break
done

for CLASS in "${CLASSES[@]}"; do
    print_msg DEBUG "Adding local.class=$CLASS"
    yadm config --add local.class "$CLASS"
done

EXPECTED_REMOTE="git@github.com:JoaoPPinto/dotfiles.git"
CURRENT_REMOTE="$(yadm remote get-url origin 2>/dev/null || true)"

if [[ "$CURRENT_REMOTE" != "$EXPECTED_REMOTE" ]]; then
    print_msg INFO "Updating yadm remote URL"
    yadm remote set-url origin "$EXPECTED_REMOTE"
fi
