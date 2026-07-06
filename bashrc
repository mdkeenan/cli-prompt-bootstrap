# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
   *i*) ;;
     *) return ;;
esac

# History settings
HISTCONTROL=ignoreboth              # ignore duplicates and leading-space commands
shopt -s histappend                 # append to the history file, don't overwrite it
HISTSIZE=50000
HISTFILESIZE=100000

# Keep different sessions' history in sync (PROMPT_COMMAND extended below after _prompt_dir_short)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability
#force_color_prompt=yes

if [ -n "${force_color_prompt:-}" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# ANSI color codes
RS="\[\033[0m\]"    # reset
HC="\[\033[1m\]"    # hicolor
UL="\[\033[4m\]"    # underline
INV="\[\033[7m\]"   # inverse background and foreground
FBLK="\[\033[30m\]"
FRED="\[\033[31m\]"
FGRN="\[\033[32m\]"
FYEL="\[\033[33m\]"
FBLE="\[\033[34m\]"
FMAG="\[\033[35m\]"
FCYN="\[\033[36m\]"
FWHT="\[\033[37m\]"
FDGRY="\[\033[90m\]"  # dim gray
BBLK="\[\033[40m\]"
BRED="\[\033[41m\]"
BGRN="\[\033[42m\]"
BYEL="\[\033[43m\]"
BBLE="\[\033[44m\]"
BMAG="\[\033[45m\]"
BCYN="\[\033[46m\]"
BWHT="\[\033[47m\]"

# Shorten each path segment to 3 characters for the prompt directory display
_prompt_dir_short() {
    local part
    if [[ "$PWD" == "$HOME" ]]; then
        _prompt_dir='~'
        return
    fi
    if [[ "$PWD" == "$HOME"/* ]]; then
        _prompt_dir='~'
        local IFS='/'
        read -ra _path_parts <<< "${PWD#$HOME/}"
        for part in "${_path_parts[@]}"; do
            [[ -n "$part" ]] && _prompt_dir+="/${part:0:3}"
        done
        return
    fi
    _prompt_dir=''
    if [[ "$PWD" == /* ]]; then
        local IFS='/'
        read -ra _path_parts <<< "${PWD#/}"
        for part in "${_path_parts[@]}"; do
            [[ -n "$part" ]] && _prompt_dir+="/${part:0:3}"
        done
        [[ -z "$_prompt_dir" ]] && _prompt_dir='/'
    else
        _prompt_dir="${PWD:0:3}"
    fi
}

# Privilege label: admuser if root or in sudo/wheel/admin group
_is_admuser=0
if [ "$EUID" -eq 0 ]; then
    _is_admuser=1
else
    _groups=$(id -nG 2>/dev/null) || _groups=
    case " $_groups " in
        *" sudo "*|*" wheel "*|*" admin "*) _is_admuser=1 ;;
    esac
fi

if [ "$_is_admuser" -eq 1 ]; then
    _priv="${FRED}admuser"
    _priv_label=admuser
else
    _priv="${FDGRY}stduser"
    _priv_label=stduser
fi

if [ "${color_prompt:-}" = yes ]; then
    PS1="${HC}${FYEL}[${RS}\A${FYEL}:${FGRN}${debian_chroot:+($debian_chroot)}\u${FYEL}:${_priv}${FYEL}:${FCYN}\h${FYEL}:${FBLE}\${_prompt_dir}${FYEL}]\$ ${RS}"
else
    PS1='${debian_chroot:+($debian_chroot)}\u:'"$_priv_label"':\h:${_prompt_dir}$ '
fi
unset _is_admuser _groups _priv _priv_label _path_parts
unset color_prompt force_color_prompt

# Keep different sessions' history in sync
if [[ -z "${PROMPT_COMMAND:-}" ]]; then
  PROMPT_COMMAND='_prompt_dir_short; history -a; history -n'
else
  PROMPT_COMMAND='_prompt_dir_short; history -a; history -n; '"$PROMPT_COMMAND"
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Load user aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
