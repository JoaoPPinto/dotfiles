# This file is sourced on all invocations of the shell.
# If the -f flag is present or if the NO_RCS option is
# set within this file, all other initialization files
# are skipped.
# Global Order: zshenv, zprofile, zshrc, zlogin

export EDITOR=nvim
export PAGER=less
export LESS="R --ignore-case --LONG-PROMPT --QUIET --chop-long-lines --quit-if-one-screen --no-init"
export TERMINAL='foot'

# XDG Base Directories - fall back to defaults if the session hasn't provided them
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

