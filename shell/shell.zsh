
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
