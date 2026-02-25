#!/usr/bin/env bash

# 06-detect-hw
# Detect specific hardware configurations

set -euo pipefail

print_msg INFO "Detecting hardware capabilities ..."

HAS_NVIDIA=0
IS_LAPTOP=0

if [[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]]; then
    if command -v lspci >/dev/null 2>&1; then
        if lspci | grep -qi 'nvidia'; then
            HAS_NVIDIA=1
        fi
    fi

    # Fallback: kernel driver path
    if [[ "$HAS_NVIDIA" -eq 0 && -d /proc/driver/nvidia ]]; then
        HAS_NVIDIA=1
    fi
fi

if [[ "${BOOTSTRAP_PLATFORM:-}" == "linux" ]]; then
    if compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
        IS_LAPTOP=1
    else
        # Fallback: DMI chassis type
        if [[ -r /sys/class/dmi/id/chassis_type ]]; then
            case "$(cat /sys/class/dmi/id/chassis_type)" in
                8|9|10|14) # Portable, Laptop, Notebook, Sub-notebook
                    IS_LAPTOP=1
                    ;;
            esac
        fi
    fi
fi

export HAS_NVIDIA
export IS_LAPTOP

if [[ "$HAS_NVIDIA" -eq 1 ]]; then
    print_msg INFO "NVIDIA GPU detected"
else
    print_msg INFO "No NVIDIA GPU detected"
fi

if [[ "$IS_LAPTOP" -eq 1 ]]; then
    print_msg INFO "Laptop detected"
else
    print_msg INFO "Not a laptop"
fi
