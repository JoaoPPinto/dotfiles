#!/usr/bin/env bash
# 45-nvidia-fedora
# Installs NVIDIA proprietary drivers on Fedora
# Handles Secure Boot and RTX detection

set -euo pipefail

[[ "${BOOTSTRAP_OS:-}" == "fedora" ]] || return 0
[[ "${HAS_NVIDIA:-0}" -eq 1 ]] || return 0
[[ "${HAS_RTX:-0}" -eq 1 ]] || {
    print_msg WARN "NVIDIA GPU detected but not RTX. Skipping proprietary driver setup."
    return 0
}

print_msg INFO "Installing NVIDIA Drivers (Fedora)"

if [[ "${SECUREBOOT_ENABLED:-0}" -eq 1 ]]; then
    print_msg WARN "Secure Boot is ENABLED."
    print_msg WARN "Manual key enrollment will be required after installation."
    echo
    read -rp "Continue with NVIDIA installation? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || {
        print_msg INFO "Skipping NVIDIA installation."
        return 0
    }
fi

NVIDIA_PACKAGES=(
    akmod-nvidia
    xorg-x11-drv-nvidia-cuda
)

if [[ "${SECUREBOOT_ENABLED:-0}" -eq 1 ]]; then
    NVIDIA_PACKAGES+=(
        kmodtool
        akmods
        mokutil
        openssl
    )
fi

TO_INSTALL=()
for pkg in "${NVIDIA_PACKAGES[@]}"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
        TO_INSTALL+=("$pkg")
    fi
done

if [[ "${#TO_INSTALL[@]}" -gt 0 ]]; then
    print_msg INFO "Installing packages: ${TO_INSTALL[*]}"
    require_sudo
    sudo dnf install -y --allowerasing "${TO_INSTALL[@]}" \
            || abort "Failed to install NVIDIA packages"
else
    print_msg INFO "Required NVIDIA packages already installed."
fi

print_msg INFO "Waiting for NVIDIA kernel module to build..."
print_msg INFO "Do NOT reboot until the build completes."

BUILD_TIMEOUT=300
SECONDS_WAITED=0

while ! modinfo -F version nvidia >/dev/null 2>&1; do
    sleep 10
    SECONDS_WAITED=$((SECONDS_WAITED + 5))

    if (( SECONDS_WAITED >= BUILD_TIMEOUT )); then
        print_msg WARN "Module not ready yet. It may still be building."
        break
    fi
done

if modinfo -F version nvidia >/dev/null 2>&1; then
    print_msg INFO "NVIDIA module successfully built."
else
    print_msg WARN "Could not confirm module build yet."
fi

if [[ "${SECUREBOOT_ENABLED:-0}" -eq 1 ]]; then
    cat <<EOF

============================================================
SECURE BOOT IS ENABLED — Manual Steps Required
============================================================

1. Generate signing key:
   sudo kmodgenca -a

2. Import the key (choose a memorable password, e.g., 0000):
   sudo mokutil --import /etc/pki/akmods/certs/public_key.der

3. Reboot the system.

4. On next boot, MOK Management (blue screen) will appear:
   - Press Enter
   - Select "Enroll MOK"
   - Choose "Continue"
   - Select "Yes"
   - Enter the password you created earlier

After enrollment, reboot again.

============================================================

EOF
fi

cat <<EOF
Ensure the following Environment variables are set in /etc/sway/environment
SWAY_EXTRA_ARGS="--unsupported-gpu"
WLR_RENDERER=vulkan
WLR_NO_HARDWARE_CURSOR=1

Otherwise, sway and sddm WILL NOT start and/or have weird artefacts.
EOF

print_msg INFO "IMPORTANT:"
print_msg INFO "Ensure akmod build has finished before rebooting."
print_msg INFO "A reboot is required for the NVIDIA driver to become active."
