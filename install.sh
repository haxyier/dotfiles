#! /bin/bash

FONT_BOLD="\033[1m"
# COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_CYAN="\033[36m"
OUTPUT_RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


section() {
    echo -e "${FONT_BOLD}${COLOR_CYAN}\n$1\n${OUTPUT_RESET}"
}

info() {
    echo -e "[INFO]    $1"
}

warn() {
    echo -e "${COLOR_YELLOW}[WARNING] $1${OUTPUT_RESET}"
}

setup_home() {
    section "Setup home directory..."

    ### Setup home directory. ###
    HOME_DIR="${SCRIPT_DIR}/home"
    CONFIG_DIR_NAME=".config"
    find "${HOME_DIR}" -type d -name "${CONFIG_DIR_NAME}" -prune -o -type f -print0 | while IFS= read -r -d '' file
    do
        target="${HOME}/$(basename "${file}")"  # path of file installed.

        if [ -e "${target}" ]; then
            warn "${target}: already exists. Skipped."
        else
            ln -s "${file}" "${target}"
            info "Created symlink: ${target} -> ${file}"
        fi

        if [ "$(basename "${file}")" = ".zshenv" ]; then
            source "$file"
            info "Loaded ${target}"
        fi
    done

    ### Setup XDG_CONFIG_HOME ($HOME/.config). ###
    CONFIG_DIR="${HOME_DIR}/${CONFIG_DIR_NAME}"
    find "${CONFIG_DIR}" -type f -print0 | while IFS= read -r -d '' file
    do
        relative_path="${file##"${CONFIG_DIR}/"}"               # relative path from "home/.config"
        target="${HOME}/${CONFIG_DIR_NAME}/${relative_path}"   # path of file installed.
        application_dir="$(dirname "${target}")"                # dirname of file installed.

        if [ -e "${target}" ]; then
            warn "${target}: already exists. Skipped."
        else
            mkdir -p "${application_dir}"
            ln -s "${file}" "${target}"
            info "Created symlink: ${target} -> ${file}"
        fi
    done
}

setup_git() {
    section "Setup git config..."

    name=$(git config --global user.name)
    email=$(git config --global user.email)

    default_name=${name:-"noname"}
    default_email=${email:-"noname@example.com"}

    read -rp "Enter name. [${default_name}]: " name
    read -rp "Enter email. [${default_email}]: " email

    git config --global user.name "${name:-$default_name}"
    git config --global user.email "${email:-$default_email}"
}


setup_home
setup_git
section "Installation is Completed!"
