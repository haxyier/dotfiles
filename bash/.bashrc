# shellcheck shell=bash

export CLICOLOR=1
export LESS="-FiMqRX"
export LSCOLORS=gxfxcxdxcxegedabagfxfx
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=35:ow=35'


### Configure alias. ###
alias ls='ls --color'
alias la='ls -a'
alias ll='ls -hl'
alias lla='ls -ahl'


### configure shell options. ###
shopt -s extglob    # Enable extended globbing
shopt -s failglob   # In case no matches are found, an error message is printed and the command is not executed.
shopt -s globstar   # ** used as a single pattern will match all files and zero or more directories and subdirectories.


### Configure history. ###
# command
HISTFILE=$XDG_STATE_HOME/bash/.bash_history
HISTSIZE=1000
HISTFILESIZE=100000


### Format prompt style. ###
[ -r ~/.git/git-prompt.sh ] && source ~/.git/git-prompt.sh
[ -r ~/.git/git-completion.bash ] && source ~/.git/git-completion.bash

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

# prompt appearance
name_host_fg_color='255'    # text color (username and hostname)
name_host_bg_color='055'    # background color (username and hostname)
path_fg_color='000'         # text color (current directory)
path_bg_color='219'         # background color (current directory)
branch_fg_color='000'       # text color (branch name)
branch_bg_color='087'       # background color (branch name)

name_host_fg="\e[38;5;${name_host_fg_color}m"    
name_host_bg="\e[30;48;5;${name_host_bg_color}m"
path_fg="\e[38;5;${path_fg_color}m"
path_bg="\e[30;48;5;${path_bg_color}m"
branch_fg="\e[38;5;${branch_fg_color}m"
branch_bg="\e[30;48;5;${branch_bg_color}m"

right_arrow_fg1="\e[38;5;${name_host_bg_color}m"
right_arrow_fg2="\e[38;5;${path_bg_color}m"
right_arrow_fg3="\e[38;5;${branch_bg_color}m"

right_arrow=""
branch_icon=" "
reset='\e[0m'

function get_branch_or_blank() {
    branch_name=$(__git_ps1 %s)
    if [ -n "${branch_name}" ]; then
        echo -e "${branch_bg}${right_arrow_fg2}${right_arrow} ${branch_bg}${branch_fg}${branch_icon}${branch_name} ${reset}${right_arrow_fg3}${right_arrow}${reset}"
    else
        echo -e "${right_arrow_fg2}${right_arrow}${reset}"
    fi
}

function format_prompt() {
    # username@hostname
    prompt_str="${name_host_bg}${name_host_fg} \u@\h ${path_bg}${right_arrow_fg1}${right_arrow} "
    # current directory
    prompt_str+="${path_bg}${path_fg}\$(pwd | sed -e "s@^$HOME@~@" | sed -e 's@^/@@' | sed -e 's@/@  @g') ${reset}"
    # current branch
    prompt_str+="\$(get_branch_or_blank)"

    echo -e "\n${prompt_str}"
    echo "\$ "
}

PS1=$(format_prompt)

### Windows specific configurations. ###
uname_str=$(uname | tr '[:upper:]' '[:lower:]')

if [[ $uname_str = "mingw"* || $uname_str = "cygwin"* || $uname_str = "msys"* ]]; then
    # Enable symbolic link.
    export MSYS=winsymlinks:nativestrict
fi

### Load external configrations. ###
EXTERNAL_CONFIG_DIR="${XDG_CONFIG_HOME}/external"
[ -r "${EXTERNAL_CONFIG_DIR}/bash/.bashrc" ] && source "${EXTERNAL_CONFIG_DIR}/bash/.bashrc"
