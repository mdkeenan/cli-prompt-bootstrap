# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
   *i*) ;;
     *) return ;;
esac

# History settings
HISTCONTROL=ignoreboth              # ignore duplicates and leading-space commands
shopt -s histappend                 # append to the history file, don't overwrite it
HISTSIZE=50000                      # CHANGED: larger in-memory history [web:30]
HISTFILESIZE=100000                 # CHANGED: larger history file [web:24]

# Keep different sessions' history in sync [web:21][web:30]
if [[ -z "${PROMPT_COMMAND:-}" ]]; then
  PROMPT_COMMAND='history -a; history -n'
else
  PROMPT_COMMAND='history -a; history -n; '"$PROMPT_COMMAND"
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
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
BBLK="\[\033[40m\]"
BRED="\[\033[41m\]"
BGRN="\[\033[42m\]"
BYEL="\[\033[43m\]"
BBLE="\[\033[44m\]"
BMAG="\[\033[45m\]"
BCYN="\[\033[46m\]"
BWHT="\[\033[47m\]"

# Prompt
if [ "${color_prompt:-}" = yes ]; then
    if [ "$EUID" -eq 0 ]; then                  # CHANGED: use EUID [web:18]
        PS1="$HC$FYEL[$RS\A$FYEL:$FRED${debian_chroot:+($debian_chroot)}\u$FYEL:$FCYN\h$FYEL:$FBLE\W$FYEL]\\$ $RS"
    else
        PS1="$HC$FYEL[$RS\A$FYEL:$FGRN${debian_chroot:+($debian_chroot)}\u$FYEL:$FCYN\h$FYEL:$FBLE\W$FYEL]\\$ $RS"
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\W\$ '
fi
unset color_prompt force_color_prompt

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
