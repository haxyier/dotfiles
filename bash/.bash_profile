# shellcheck shell=bash

export PATH=$PATH
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "${HOME}/.bashrc" ]; then
        source "${HOME}/.bashrc"
    fi
fi


### Load external configrations. ###
EXTERNAL_CONFIG_DIR="${XDG_CONFIG_HOME}/external"
[ -r "${EXTERNAL_CONFIG_DIR}/bash/.bash_profile" ] && source "${EXTERNAL_CONFIG_DIR}/bash/.bash_profile"
