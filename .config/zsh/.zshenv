# This file is sourced on all invocations of the shell.
# If the -f flag is present or if the NO_RCS option is
# set within this file, all other initialization files
# are skipped.
# Global Order: zshenv, zprofile, zshrc, zlogin

# Directories

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export SCREENSHOTS="${XDG_PICTURES_DIR}/Screenshots"


export EDITOR=nvim
export PAGER=less
export LESS="R --ignore-case --LONG-PROMPT --QUIET --chop-long-lines --quit-if-one-screen --no-init"
export TERMINAL='foot'

. "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"

