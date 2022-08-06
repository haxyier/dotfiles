#! /bin/bash

FONT_BOLD="\033[1m"
COLOR_RED="\033[31m"
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

    for dotfile in $(find $SCRIPT_DIR/home -type f); do
        target="${HOME}/$(basename "${dotfile}")"

        if [ -e "$target" ]; then
            warn "${target}: already exists. Skipped."
        else
            ln -s "${dotfile}" "${target}"
            info "Created symlink: ${target} -> ${dotfile}"
        fi
    done
}

setup_git() {
    section "Setup git config..."

    name=$(git config user.name)
    email=$(git config user.email)

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
