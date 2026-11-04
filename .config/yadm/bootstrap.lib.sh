#!/usr/bin/env bash
# ~/.config/yadm/bootstrap.lib.sh
#
# Shared helpers, sourced by the bootstrap runner and by every step:

log()   { printf '==> %s\n' "$*" >&2; }
warn()  { printf 'WARN: %s\n' "$*" >&2; }
abort() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

require_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log "Requesting sudo access"
        sudo -v
    fi
}

# Sets BOOTSTRAP_DISTRO and BOOTSTRAP_DISTRO_FAMILY following yadm's own rules,
# so the steps and the templates always agree:
#   - a local.distro / local.distro-family override wins outright
#   - otherwise distro is lsb_release -si, falling back to ID
#   - otherwise family is ID_LIKE, falling back to ID
# The values are kept raw; nothing here rewrites or interprets them.
# BOOTSTRAP_ rather than YADM_ because yadm does not export these to the
# bootstrap; they are this script's reading of the same sources.
detect_distro() {
    BOOTSTRAP_DISTRO="$(yadm config --get local.distro 2>/dev/null || true)"
    [[ -z "$BOOTSTRAP_DISTRO" ]] && BOOTSTRAP_DISTRO="$(query_distro)"

    BOOTSTRAP_DISTRO_FAMILY="$(yadm config --get local.distro-family 2>/dev/null || true)"
    [[ -z "$BOOTSTRAP_DISTRO_FAMILY" ]] && BOOTSTRAP_DISTRO_FAMILY="$(query_distro_family)"
}

query_distro() {
    local distro="" line
    if has lsb_release; then
        distro="$(lsb_release -si 2>/dev/null || true)"
    elif [[ -r /etc/os-release ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" = ID=* ]]; then
                distro="${line#ID=}"
                distro="${distro//\"/}"
                break
            fi
        done < /etc/os-release
    fi
    printf '%s' "$distro"
}

query_distro_family() {
    local family="" line
    if [[ -r /etc/os-release ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" = ID_LIKE=* ]]; then
                family="${line#ID_LIKE=}"
                break
            elif [[ "$line" = ID=* ]]; then
                family="${line#ID=}"   # fallback only, when ID_LIKE is absent
            fi
        done < /etc/os-release
    fi
    printf '%s' "${family//\"/}"
}

# Sets BOOTSTRAP_HOSTNAME and BOOTSTRAP_CLASSES, again following yadm: a
# local.hostname or local.class override wins; otherwise uname -n with any
# domain trimmed. Classes are newline separated because the environment cannot
# carry an array between the runner and its steps; use classes_list to read
# them back.
detect_classes() {
    BOOTSTRAP_HOSTNAME="$(yadm config --get local.hostname 2>/dev/null || true)"
    if [[ -z "$BOOTSTRAP_HOSTNAME" ]]; then
        BOOTSTRAP_HOSTNAME="$(uname -n)"
        BOOTSTRAP_HOSTNAME="${BOOTSTRAP_HOSTNAME%%.*}"
    fi

    BOOTSTRAP_CLASSES="$(yadm config --get-all local.class 2>/dev/null || true)"
}

classes_list() {
    [[ -n "${BOOTSTRAP_CLASSES:-}" ]] || return 0
    printf '%s\n' "$BOOTSTRAP_CLASSES"
}

has_class() {
    local want="$1" class
    while IFS= read -r class; do
        [[ "$class" == "$want" ]] && return 0
    done < <(classes_list)
    return 1
}

# Reads a yes/no answer on the terminal, even when stdin is redirected.
# Anything other than an affirmative counts as no.
confirm() {
    local prompt="${1:-Continue? [y/N] }" answer
    if [[ -t 0 ]]; then
        read -r -p "$prompt" answer </dev/tty
    else
        printf '%s' "$prompt" >&2
        read -r answer || answer=""
    fi
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# Path of the directory holding the package lists, e.g. core.fedora,
# core.arch. Set by the runner; overridable for testing.
packages_dir() {
    local lib_dir="${BOOTSTRAP_LIB%/*}"
    [[ "$lib_dir" != "$BOOTSTRAP_LIB" ]] || lib_dir="."
    printf '%s' "${BOOTSTRAP_PACKAGES_DIR:-${lib_dir}/packages.d}"
}

# Prints the entries of a package list file, one per line: one package name per
# line, blank lines and lines starting with '#' ignored.
read_package_list() {
    local list="$1" line
    [[ -r "$list" ]] || abort "package list not found: $list"

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#"${line%%[![:space:]]*}"}"   # trim leading whitespace
        line="${line%"${line##*[![:space:]]}"}"   # trim trailing whitespace
        [[ -z "$line" || "$line" == \#* ]] && continue
        printf '%s\n' "$line"
    done < "$list"
}

install_packages_from() {
    local list="$1"
    local -a packages=()

    mapfile -t packages < <(read_package_list "$list")
    (( ${#packages[@]} )) || abort "package list is empty: $list"

    log "Installing ${#packages[@]} packages: ${packages[*]}"
    install_packages "${packages[@]}"
}

# First AUR helper available, if any.
aur_helper() {
    local candidate
    for candidate in paru yay; do
        if has "$candidate"; then
            printf '%s' "$candidate"
            return 0
        fi
    done
    return 1
}

# Installs a list of packages that the official repositories do not carry.
# Deliberately not fatal when no helper exists: these are extras, and a hard
# failure would stop the rest of the bootstrap.
install_aur_from() {
    local list="$1" helper
    local -a packages=()

    mapfile -t packages < <(read_package_list "$list")
    (( ${#packages[@]} )) || abort "package list is empty: $list"

    if ! helper="$(aur_helper)"; then
        warn "no AUR helper found (paru or yay); not installing: ${packages[*]}"
        return 0
    fi

    log "Installing ${#packages[@]} AUR packages with ${helper}: ${packages[*]}"
    # AUR helpers refuse to run as root, so this one is not prefixed with sudo.
    "$helper" --needed --noconfirm -S "${packages[@]}"
}

# Installs packages through the family's package manager. Both are idempotent,
# so re-running is harmless.
install_packages() {
    (( $# )) || return 0

    case "$BOOTSTRAP_DISTRO_FAMILY" in
        fedora) sudo dnf install -y "$@" ;;
        arch)   sudo pacman -S --needed --noconfirm "$@" ;;
        *)      abort "install_packages: unsupported family: ${BOOTSTRAP_DISTRO_FAMILY:-unset}" ;;
    esac
}
