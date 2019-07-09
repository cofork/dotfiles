# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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

export PROMPT_DIRTRIM=5

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias llh='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias rm='rm -i'
alias ..='cd ..'
if command -v emacs &>/dev/null; then
    alias emacs='emacsclient -nw -a ""'
    alias em='emacs'
fi

alias ssh='ssh -o VisualHostKey=yes'

function godoc(){
    go doc "$@" | less
}

if command -v w3m > /dev/null; then
    alias w3m='w3m https://www.google.co.jp/'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
if command -v notify-send > /dev/null; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

export EDITOR=emacs

if command -v ccache > /dev/null; then
    if ! [ -d "$HOME/.ccache" ]; then
        mkdir "$HOME/.ccache"
    fi
    export USE_CCACHE=1
    export CCACHE_DIR="$HOME/.ccache"
    export CC='ccache gcc'
fi

# default to prompt when deleting existing crontab in case it is deleted unexpectedly.
if command -v crontab > /dev/null; then
    alias crontab="crontab -i"
fi

# Utilities
if command -v ffmpeg &>/dev/null; then
    function gengif() {
        local palettepath="/tmp/palette_$RANDOM.png"
        ffmpeg -i "$1" -vf palettegen "$palettepath"
        ffmpeg -i "$1" -i "$palettepath" -filter_complex paletteuse out.gif
        rm -f "$palettepath"
    }
fi

if command -v uplatex > /dev/null && command -v dvipdfmx > /dev/null; then
    function tex2pdf() {
        if [ ! $# -eq 1 ]; then
            echo 'Please specify a texname' >&2
            exit 1
        fi
        local source_path="$(realpath ${1%.tex})"
        local texname="$(basename "$source_path")"
        (
            cd /tmp
            uplatex "$source_path" && \
                dvipdfmx "/tmp/${texname}.dvi" && \
                mv "/tmp/${texname}.pdf" "${source_path}.pdf"
        )
    }
fi

if [ -e "$HOME/.bashrc-local" ]; then
    . "$HOME/.bashrc-local"
fi

if command -v pygmentize >/dev/null; then
    alias pcat='pygmentize'
fi

if command -v git >/dev/null; then
    alias gitgraph='git log --graph --decorate=full --all --date=iso --pretty="%C(yellow)%h%C(reset) %s %C(cyan)by %an%C(reset) %C(auto)%d%C(reset)%n%x09%C(blue)[%ad]%C(reset)"'
fi
