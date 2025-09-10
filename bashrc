#!/bin/bash
###############################################################################
#
# Shell common configuration
# This file contains common shell settings that work for both bash and zsh
#
###############################################################################

# =============================================================================
# Path Settings
# =============================================================================

# Add common paths
export PATH="/usr/local/bin:$HOME/bin:$HOME/.local/bin:$PATH"
# Homebrew (Intel/macOS 用) 調整
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# =============================================================================
# Basic Shell Settings
# =============================================================================

# History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups

# Editor settings
export EDITOR=vim
export VISUAL=vim

# Language settings
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# =============================================================================
# Grep Configuration
# =============================================================================

# Build grep command with options
grep_options="--color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}"

# Determine which grep to use and build the command
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep'
  grep_command="ggrep $grep_options"
elif command -v /usr/local/bin/grep >/dev/null 2>&1; then
  alias grep='/usr/local/bin/grep'
  grep_command="/usr/local/bin/grep $grep_options"
elif command -v /opt/homebrew/bin/grep >/dev/null 2>&1; then
  alias grep='/opt/homebrew/bin/grep'
  grep_command="/opt/homebrew/bin/grep $grep_options"
else
  grep_command="grep $grep_options"
fi
export grep_command

# =============================================================================
# Source Common Aliases
# =============================================================================
export DOTFILES_DIR=$HOME/dotfiles

# Source common aliases (works for both bash and zsh)
if [[ -f "$DOTFILES_DIR/shell/aliases.common" ]]; then
  source "$DOTFILES_DIR/shell/aliases.common"
fi

# Source shell-specific aliases (after grep_command is set)
if [[ -f "$DOTFILES_DIR/shell/aliases.shell" ]]; then
  source "$DOTFILES_DIR/shell/aliases.shell"
fi

###############################################################################
#
# Bash-specific configuration
# This file contains bash-specific settings and functions
#
###############################################################################

# =============================================================================
# Bash-specific Settings
# =============================================================================

# Enable programmable completion
if [[ -f /usr/local/etc/bash_completion ]]; then
  source /usr/local/etc/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Bash prompt customization
export PS1='\u@\h:\w\$ '

# Bash history settings
shopt -s histappend
shopt -s checkwinsize

# =============================================================================
# Bash Functions
# =============================================================================

# Function to extract archives
extract() {
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Function to create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}
