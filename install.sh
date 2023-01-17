#! /bin/bash

FONT_BOLD="\033[1m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_CYAN="\033[36m"
OUTPUT_RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_BACKUP_DIR="${HOME}/dotfiles-backup_$(date +%Y%m%d%H%M%S)"


section() {
    echo -e "${FONT_BOLD}${COLOR_CYAN}\n$1${OUTPUT_RESET}"
}

info() {
    echo -e "[INFO]    $1"
}

warn() {
    echo -e "${COLOR_YELLOW}[WARNING] $1${OUTPUT_RESET}"
}

error() {
    echo -e "${FONT_BOLD}${COLOR_RED}[ERROR]   $1${OUTPUT_RESET}"
}

parse_options() {
    local positional_params=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            # Parse long options.
            --backup) BACKUP_ENABLED=true; [[ ! $2 =~ ^- ]] && BACKUP_PATH=$2 && shift; shift;;
            --shell)  SHELL_SPECIFIED=true; [[ ! $2 =~ ^- ]] && SELECTED_SHELL=$2 && shift; shift;;

            # Quit parsing options.
            --) shift; positional_params+=("$@"); set --;;

            # In case it does not match any long options.
            --*) error "Invalid option: $1"; exit 1;;

            # Parse short options. (Allow multiple short options.)
            -*)
                 local options=${1:1}
                 local arg_count=${#options}
                 for (( i=0; i<arg_count; i++ )); do
                     case "-${options:$i:1}" in
                        -b)
                            BACKUP_ENABLED=true

                            # Parse option argument if the option is last one.
                            if [[ $((i + 1)) -eq ${arg_count} && ! $2 =~ ^- ]]; then
                                BACKUP_PATH=$2; shift
                            fi;;

                        -s)
                            SHELL_SPECIFIED=true

                            # Parse option argument if the option is last one.
                            if [[ $((i + 1)) -eq ${arg_count} && ! $2 =~ ^- ]]; then
                                SELECTED_SHELL=$2; shift
                            fi;;

                        # In case it does not match any short options.
                        *) error "Invalid option: -${options:$i:1}"; exit 1;;
                     esac
                 done
                 shift;;

            # Parse positional params.
            *) positional_params+=("$1"); shift;;
        esac
    done

    set -- "${positional_params[@]}"

    # Check args.
    if [ "${SHELL_SPECIFIED}" ]; then
        if [[ ! "${SELECTED_SHELL}" =~ ^(bash|zsh)$ ]]; then
            error "Invalid option: --shell or -s option is must be provided value of \"bash\" or \"zsh\"."
            exit 1
        fi
    fi
}

ensure_backup_dir() {
    section "Ensure backup directory..."

    if [ -z "${BACKUP_ENABLED}" ]; then
        warn "Backup is disabled. Installation of existing config files will be skipped."
        return 0
    fi

    backup_dir="${BACKUP_PATH:-$DEFAULT_BACKUP_DIR}"
    local backup_base_dir
    backup_base_dir="$(dirname "${backup_dir}")"

    if [ ! -e "${backup_base_dir}" ]; then
        error "${backup_base_dir} is not exist. No files changed."
        exit 1
    fi

    if [ -e "${backup_dir}" ]; then
        error "${backup_dir}: Already exists. No files changed."
        exit 1
    fi

    mkdir -p "${backup_dir}" && info "Ensured backup directory: ${backup_dir}"
}

# If --backup or -b option is specified, move file to backup directory.
# Args $1: file path to execute backup. 
# Returns:  0: Backup is completed.
#           1: Backup is not done.
backup_file() {
    if [ ! -e "$1" ]; then
        return 0
    fi

    if [ -z "${BACKUP_ENABLED}" ]; then
        return 1
    fi

    local backup_dst="${backup_dir}/$1";
    if mkdir -p "$(dirname "${backup_dst}")" && cp "$1" "${backup_dst}"; then
        info "Backup file: $1"
        return 0
    else
        error "$1: Failed to backup file."
        return 1
    fi
}

# Check specified variable is defined. if not, terminate script with error.
defined_or_terminate() {
    arg="$(eval "echo \"\$$1\"")"
    if [ -z "${arg}" ]; then
        error "$1 is not defined."
        exit 1
    fi
}

create_symlink() {
    ln -fs "$1" "$2" && info "Created symlink: $2 -> $1"
}

setup_shell() {
    section "Setup shell..."

    if [ "${SELECTED_SHELL}" = "bash" ]; then
        info "bash is selected for default shell."
        target_shell="bash"
        setup_bash
    elif [ "${SELECTED_SHELL}" = "zsh" ]; then
        info "zsh is selected for default shell."
        target_shell="zsh"
        setup_zsh
    else
        if [[ "${SHELL}" =~ bash$ ]]; then
            info "Detected login shell is bash."
            target_shell="bash"
            setup_bash
        elif [[ "${SHELL}" =~ zsh$ ]]; then
            info "Detected login shell is zsh."
            target_shell="zsh"
            setup_zsh
        else
            error "Could not detect login shell, or current login shell is not supported."
            exit 1
        fi
    fi
}

setup_zsh() {
    section "Setup zsh..."

    ### Setup .zshenv ###
    local ZSHENV_PATH=${HOME}/.zshenv
    if backup_file "${ZSHENV_PATH}"; then
        create_symlink "${SCRIPT_DIR}"/zsh/.zshenv "${ZSHENV_PATH}"
        source "${ZSHENV_PATH}" && info "Loaded ${ZSHENV_PATH}"
    else
        error ".zshenv must be installed to prevent installation from unexpected result. Please delete existing .zshenv before run this script or run with -b or --backup option."
        exit 1
    fi

    ### Setup ZDOTDIR ###
    defined_or_terminate "ZDOTDIR"
    mkdir -p "${ZDOTDIR}"
    local ZSHCONFIGS="${SCRIPT_DIR}"/zsh/zdotdir

    find "${ZSHCONFIGS}" -type f -print0 | while IFS= read -r -d '' file
    do
        target="${ZDOTDIR}/$(basename "${file}")"  # path of file installed.

        if backup_file "${target}"; then
            create_symlink "${file}" "${target}"
        else
            warn "${target}: Installation is skipped."
        fi
    done
}

setup_bash() {
    section "Setup bash..."

    ### Setup .bashrc ###
    local BASHPROFILE_PATH=${HOME}/.bash_profile
    if backup_file "${BASHPROFILE_PATH}"; then
        create_symlink "${SCRIPT_DIR}"/bash/.bash_profile "${BASHPROFILE_PATH}"
        source "${BASHPROFILE_PATH}"
        info "Loaded file: ${BASHPROFILE_PATH}"
    else
        error ".bash_profile must be installed to prevent installation from unexpected result. Please delete existing .bash_profile before run this script or run with -b or --backup option.";
        exit 1
    fi

    # Setup other config in home directory.
    find "${SCRIPT_DIR}/bash" -type f -print0 | while IFS= read -r -d '' file
    do
        if [ "$(basename "${file}")" = ".bash_profile" ]; then
            continue
        fi

        target="${HOME}/$(basename "${file}")"  # path of file installed.

        if backup_file "${target}"; then
            create_symlink "${file}" "${target}"
        else
            warn "${target}: Installation is skipped."
        fi
    done

    defined_or_terminate "XDG_STATE_HOME"
    mkdir -p "${XDG_STATE_HOME}"/bash && info "Created directory: ${XDG_STATE_HOME}/bash"
}

setup_home() {
    section "Setup home directory..."

    ### Setup home directory. ###
    HOMECONFIGS="${SCRIPT_DIR}/home"
    CONFIG_DIR_NAME=".config"

    find "${HOMECONFIGS}" -type d -name "${CONFIG_DIR_NAME}" -prune -o -type f -print0 | while IFS= read -r -d '' file
    do
        target="${HOME}/$(basename "${file}")"  # path of file installed.

        if backup_file "${target}"; then
            create_symlink "${file}" "${target}"
        else
            warn "${target}: Installation is skipped."
        fi
    done

    ### Setup XDG_CONFIG_HOME ###
    defined_or_terminate "XDG_CONFIG_HOME"
    CONFIG_DIR="${HOMECONFIGS}/${CONFIG_DIR_NAME}"

    find "${CONFIG_DIR}" -type f -print0 | while IFS= read -r -d '' file
    do
        relative_path="${file##"${CONFIG_DIR}/"}"               # relative path from "home/.config"
        target="${XDG_CONFIG_HOME}/${relative_path}"   # path of file installed.
        application_dir="$(dirname "${target}")"                # dirname of file installed.

        if backup_file "${target}"; then
            mkdir -p "${application_dir}"
            create_symlink "${file}" "${target}"
        else
            warn "${target}: Installation is skipped."
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

    mkdir -p "${HOME}/.git"

    info "Check git-prompt.sh"
    [ -f "${HOME}/.git/git-prompt.sh" ] || curl -o "${HOME}/.git/git-prompt.sh" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"

    info "Check git-completion"
    if [ $target_shell = "bash" ]; then
        [ -f "${HOME}/.git/git-completion.bash" ] || curl -o "${HOME}/.git/git-completion.bash" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
    elif [ $target_shell = "zsh" ]; then
        [ -f "${HOME}/.git/_git" ] || curl -o "${HOME}/.git/_git" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh"
    fi
}

setup_external_conf() {
    section "Setup external config..."

    defined_or_terminate "XDG_CONFIG_HOME"
    EXTERNAL_CONFIG_DIR="${SCRIPT_DIR}/external"

    find "${EXTERNAL_CONFIG_DIR}" -type f -print0 | while IFS= read -r -d '' file
    do
        relative_path="${file##"${EXTERNAL_CONFIG_DIR}/"}"  # relative path from "external/"
        target="${XDG_CONFIG_HOME}/external/${relative_path}"   # path of file installed.
        application_dir="$(dirname "${target}")"                # dirname of file installed.

        if backup_file "${target}"; then
            mkdir -p "${application_dir}"
            create_symlink "${file}" "${target}"
        else
            warn "${target}: Installation is skipped."
        fi
    done
}


parse_options "$@"
ensure_backup_dir
setup_shell
setup_external_conf
setup_home
setup_git
section "Installation is Completed!"
