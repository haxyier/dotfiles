# shellcheck disable=SC2034,SC2154

### Set environment variables. ###
export PATH=/opt/homebrew/bin:$PATH
export CLICOLOR=1
export LESS="-FiMqRX"
export LSCOLORS=gxfxcxdxcxegedabagfxfx
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=35:ow=35'
export XDG_CONFIG_HOME=$HOME/.config

### Configure alias. ###
alias la='ls -a'
alias ll='ls -hl'
alias lla='ls -ahl'


### Set zsh options. ###
setopt correct      # correct typo.
setopt nobeep
setopt nohistbeep
setopt nolistbeep


### Declere variables for key bindings. ###
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


### Configure complement. ###
setopt auto_list            # Display completion list.
setopt auto_menu            # Select completion pressing tab key.
setopt list_packed          # Narrowing the spacing of completion candidates
setopt list_types           # Show file types in completion list.
setopt magic_equal_subst    # Enable completion of path after equal.

FPATH=~/.zsh:$FPATH
autoload -Uz compinit && compinit

# Display completion list in color.
zstyle ':completion:*' list-colors "${LS_COLORS}"
# If completion candidates are not found, convert lowercase to uppercase. In case still cannot find it, convert uppercase to lowercase.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}' 


### Configure history. ###
# command
HISTFILE=$XDG_CONFIG_HOME/zsh/.zsh_history
HISTSIZE=1000
SAVEHIST=100000
setopt inc_append_history   # Append history file immediately.
setopt share_history        # Share history file immediately.

# directory
DIRSTACKSIZE=100
setopt auto_pushd           # Make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups

# Search history from current buffer.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search


### Format prompt style. ###
source ~/.zsh/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

setopt prompt_subst

# prompt appearance
name_host_fg_color='255'    # text color (username and hostname)
name_host_bg_color='055'    # background color (username and hostname)
path_fg_color='000'         # text color (current directory)
path_bg_color='079'         # background color (current directory)
branch_fg_color='000'       # text color (branch name)
branch_bg_color='220'       # background color (branch name)

name_host_fg="%{\e[38;5;${name_host_fg_color}m%}"
name_host_bg="%{\e[30;48;5;${name_host_bg_color}m%}"

right_arrow_fg1="%{\e[38;5;${name_host_bg_color}m%}"

path_fg="%{\e[38;5;${path_fg_color}m%}"
path_bg="%{\e[30;48;5;${path_bg_color}m%}"

right_arrow_fg2="%{\e[38;5;${path_bg_color}m%}"

branch_fg="%{\e[38;5;${branch_fg_color}m%}"
branch_bg="%{\e[30;48;5;${branch_bg_color}m%}"

right_arrow_fg3="%{\e[38;5;${branch_bg_color}m%}"

right_arrow="\uE0B0"
branch_icon="\uE0A0 "
reset='%{\e[0m%}'

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
    prompt_str="${name_host_bg}${name_host_fg} %n@%m ${path_bg}${right_arrow_fg1}${right_arrow} "
    # current directory
    prompt_str+="${path_bg}${path_fg}\$(pwd | sed -e "s@^$HOME@~@" | sed -e 's@^/@@' | sed -e 's@/@  @g') ${reset}"
    # current branch
    prompt_str+="\$(get_branch_or_blank)"

    echo -e "\n${prompt_str}"
    echo "%# "
}

PROMPT=$(format_prompt)


### Load external configrations. ###

EXTERNAL_CONFIG_DIR="${XDG_CONFIG_HOME}/external"
EXTERNAL_ZSHRC="${EXTERNAL_CONFIG_DIR}/zsh/.zshrc"

[ -r "${EXTERNAL_ZSHRC}" ] && source "${EXTERNAL_ZSHRC}"
