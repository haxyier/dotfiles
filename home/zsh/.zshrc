### Set environment variables. ###
export PATH=/opt/homebrew/opt/git/bin:$PATH:/opt/platform-tools
export CLICOLOR=1
export LSCOLORS=gxfxcxdxcxegedabagfxfx
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=35:ow=35'


### Configure alias. ###
alias lsa='ls -a'
alias ll='ls -hl'
alias lla='ls -ahl'


### Set zsh options. ###
setopt correct
setopt correct_all
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
setopt auto_list
setopt auto_menu
setopt list_packed
setopt list_types

FPATH=~/.zsh:$FPATH
autoload -Uz compinit && compinit

zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}' 


### Configure history. ###
# command
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=100000
setopt inc_append_history
setopt share_history

# directory
DIRSTACKSIZE=100
setopt auto_pushd
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

function format_prompt() {
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
    branch="\uE0A0 "
    reset='%{\e[0m%}'

    prompt_str="${name_host_bg}${name_host_fg} %n@%m ${path_bg}${right_arrow_fg1}${right_arrow} "                       # username@hostname
    prompt_str+="${path_bg}${path_fg}%~ ${reset}${branch_bg}${right_arrow_fg2}${right_arrow} "                          # current directory
    prompt_str+="${branch_bg}${branch_fg}\$(__git_ps1 '${branch}'%s) ${reset}${right_arrow_fg3}${right_arrow}${reset}"  # current branch
    echo "${prompt_str}"
    echo "%# "
}

PROMPT=$(format_prompt)
