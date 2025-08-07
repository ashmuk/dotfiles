# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.2-4

# /etc/bash.bashrc: executed by bash(1) for interactive shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/bash.bashrc

# Modifying /etc/bash.bashrc directly will prevent
# setup from updating it.

# System-wide bashrc file

# Check that we haven't already been sourced.
#[[ -z ${CYG_SYS_BASHRC} ]] && CYG_SYS_BASHRC="1" || return

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Exclude *dlls from TAB expansion
export EXECIGNORE="*.dll"

# Get the version of Bash
BASH_VER=$(bash --version | head -n1 | awk '{print $4}' | awk -F'[-]' '{print $1}')

# Get the path of Bash in use
BASH_PATH=$(which bash)
echo -e "bash is $BASH_PATH"

# Set a default prompt of: user@host and current_directory
PS1='\[\033[32m\]bash-${BASH_VER}-\u \[\033[33m\]\w\[\033[0m\]\n\$ '
#PS1='\[\e[32m\]\u \[\e[33m\]\w\[\e[0m\]\n\$ '
#PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '

# Source
# ref: http://naktatty64.hatenablog.com/entry/2016/02/23/022837
# prompt$ cd ~/etc
# prompt$ git clone https://github.com/mavnn/mintty-colors-solarized
if [ "$SHELL" = "/bin/zsh" ]; then
    # mac
    source $HOME/etc/mintty-colors-solarized/sol.dark
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

if [ "$OS_TYPE" = "cygwin" ]; then
    # Windows
    source /cygdrive/c/home/etc/mintty-colors-solarized/sol.dark
fi

# Uncomment to use the terminal colours set in DIR_COLORS
# ref: http://naktatty64.hatenablog.com/entry/2016/02/23/022837
# prompt$ cd ~/etc
# prompt$ git clone https://github.com/seebi/dircolors-solarized
eval `dircolors ~/etc/dircolors-solarized/dircolors.ansi-dark`

# Alias
alias ls='ls --color'
alias ll='ls -l --color'
alias lla='ls -la --color'
alias pu='pushd'
alias pu2='pushd +2'
alias po='popd'
alias pdir='dir'

# alias grep='grep -R -i --color=auto --include="*.java"'
alias grep='grep -R -i --color=auto'

# Finally
set -o vi

# Hook the process with EXIT, to execute source to make it back to the host shell (zsh)
trap '[ -f "$HOME/etc/mintty-colors-solarized/sol.light" ] && source "$HOME/etc/mintty-colors-solarized/sol.light"' EXIT

# Memo:
# https://usagidaioh.exblog.jp/17578556/
