#!/bin/zsh
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
# Zsh-specific configuration
# This file contains zsh-specific settings and functions
#
###############################################################################

# =============================================================================
# Zsh-specific Settings
# =============================================================================

# History setting
export HISTFILE=~/.zsh_history

# Zsh options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt CORRECT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# =============================================================================
# Auto completion
# =============================================================================

# Enable auto completion
autoload -Uz compinit
compinit

# Show auto completion like 'menu'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# =============================================================================
# Zsh Functions
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

# Function to show directory history
dh() {
  dirs -v
}

# Function to jump to directory by number
j() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    local dir=$(dirs -l | sed -n "${1}p" | cut -d' ' -f2-)
    if [[ -n $dir ]]; then
      cd "$dir"
    else
      echo "Directory not found"
    fi
  else
    echo "Usage: j <number>"
  fi
}

gvim() {
  # macOS
  if [[ "$OSTYPE" == darwin* ]]; then
    if command -v mvim >/dev/null 2>&1; then
      command mvim "$@"
    elif [[ -x "/Applications/MacVim.app/Contents/bin/mvim" ]]; then
      "/Applications/MacVim.app/Contents/bin/mvim" "$@"
    else
      if command -v open >/dev/null 2>&1; then
        open -a "MacVim" --args "$@"
      else
        vim -g "$@"
      fi
    fi
    return
  fi

  # WSL (Windows Subsystem for Linux)
  if grep -qi microsoft /proc/version 2>/dev/null; then
    local win_gvim="/mnt/c/Program Files/vim/gvim.exe"
    if [[ -x "$win_gvim" ]]; then
      local args=()
      if command -v wslpath >/dev/null 2>&1; then
        for a in "$@"; do
          if [[ -e "$a" || "$a" == /* ]]; then
            args+=("$(wslpath -w -- "$a")")
          else
            args+=("$a")
          fi
        done
      else
        args=("$@")
      fi
      "$win_gvim" "${args[@]}" >/dev/null 2>&1 &
      disown
      return
    fi
  fi

  # MSYS/Cygwin on Windows
  case "$OSTYPE" in
    msys*|cygwin*)
      local win_gvim="/c/Program Files/vim/gvim.exe"
      if [[ -x "$win_gvim" ]]; then
        local args=()
        if command -v cygpath >/dev/null 2>&1; then
          for a in "$@"; do
            if [[ -e "$a" || "$a" == /* ]]; then
              args+=("$(cygpath -w -- "$a")")
            else
              args+=("$a")
            fi
          done
        else
          args=("$@")
        fi
        "$win_gvim" "${args[@]}" >/dev/null 2>&1 &
        disown
        return
      fi
      ;;
  esac

  # Fallbacks: native gvim or terminal GUI mode
  if command -v gvim >/dev/null 2>&1; then
    command gvim "$@" & disown
  else
    vim -g "$@"
  fi
}
###############################################################################
#
# Oh-my-zsh
#
###############################################################################

# Added by Mukai
# Enable plugins installed by homebrew ... -> This is not really necessary as installed by git clone instead
# See the installation in the folder: $HOME/.oh-my-zsh/custom/plugins
#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
# Added by Mukai
plugins=(
  git
  z
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# FIXME: this could be improved better while writing in another file
# =============================================================================
# Prompt
# =============================================================================

# zsh prompt (colored / 2-line)
ZSH_VER=$(zsh --version | head -n1 | awk '{print $2}')
PROMPT_BASE="%F{cyan}zsh-${ZSH_VER}-%n %F{green}%~%f"$'\n'"%# "
PROMPT="%F{green}[INSERT]%f $PROMPT_BASE"

# Enable vi mode
bindkey -v

# Display indicator of vi mode in prompt
function zle-keymap-select {
  case $KEYMAP in
    vicmd) PROMPT="%F{red}[NORMAL]%f $PROMPT_BASE" ;;
    main|viins) PROMPT="%F{green}[INSERT]%f $PROMPT_BASE" ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select

# =============================================================================
# Theme
# =============================================================================

# FIXME: this could be clarified if really needed
# Adding this at the end of ~/.zshrc (e.g. get the setting back even after logout bash)
# Actually, this is trapped at the end of .bashrc...
if [[ -f "$HOME/etc/mintty-colors-solarized/sol.light" ]]; then
  source "$HOME/etc/mintty-colors-solarized/sol.light"
fi
