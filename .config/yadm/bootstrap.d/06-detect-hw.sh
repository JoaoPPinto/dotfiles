#!/usr/bin/env bash

# 06-detect-hw
# Detect specific hardware configurations
# Exposes the following variables for use by other bootstrap scripts
# HAS_NVIDIA = 0 | 1
# IS_RTX = 0 | 1
# IS_LAPTOP = 0 | 1
# SECUREBOOT_ENABLED = 0 | 1

set -euo pipefail

print_msg INFO "Detecting hardware capabilities ..."

HAS_NVIDIA=0
IS_RTX=0
IS_LAPTOP=0
SECUREBOOT_ENABLED=0

if [[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]]; then
    # Nvidia GPU Detection
    if command -v lspci >/dev/null 2>&1; then
        gpu_line="$(lspci -nnk | grep -Ei 'VGA|3D' | grep -i nvidia || true)"
        if [[ -n "$gpu_line" ]]; then
            HAS_NVIDIA=1

            if echo "$gpu_line" | grep -qi 'RTX'; then
                IS_RTX=1
            fi
        fi
    fi

    # Fallback: kernel driver path
    if [[ "$HAS_NVIDIA" -eq 0 && -d /proc/driver/nvidia ]]; then
        HAS_NVIDIA=1
    fi

    # Laptop Detection
    if compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
        IS_LAPTOP=1
    # Fallback: DMI chassis type
    elif [[ -r /sys/class/dmi/id/chassis_type ]]; then
        read -r chassis_type < /sys/class/dmi/chassis_type
        case "$chassis_type" in
            8|9|10|14) # Portable, Laptop, Notebook, Sub-notebook
                IS_LAPTOP=1
                ;;
        esac
    fi

    # Secure Boot detection
    if command -v mokutil >/dev/null 2>&1; then
        if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
            SECUREBOOT_ENABLED=1
        fi
    elif [[ -d /sys/firmware/efi ]]; then
        print_msg WARN "mokutil is not available - cannot determine Secure Boot state."
    fi
fi

export HAS_NVIDIA IS_RTX IS_LAPTOP SECUREBOOT_ENABLED
readonly HAS_NVIDIA IS_RTX IS_LAPTOP SECUREBOOT_ENABLED

if [[ "$HAS_NVIDIA" -eq 1 ]]; then
    print_msg INFO "NVIDIA GPU detected"
    [[ "$IS_RTX" -eq 1 ]] && print_msg INFO "NVIDIA GPU is RTX"
else
    print_msg INFO "No NVIDIA GPU detected"
fi

if [[ "$IS_LAPTOP" -eq 1 ]]; then
    print_msg INFO "Laptop detected"
else
    print_msg INFO "Not a laptop"
fi

[[ "$SECUREBOOT_ENABLED" -eq 1 ]] && \
    print_msg INFO "Secure Boot enabled" || \
    print_msg INFO "Secure Boot disabled or not detected"
