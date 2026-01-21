
# shellcheck disable=SC2148

###############################################################################
#
# Zsh-specific configuration
# This file contains zsh-specific settings and functions
#
###############################################################################

# =============================================================================
# Zsh-specific Settings
# =============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History setting
export HISTFILE=~/.zsh_history

# Zsh options
setopt AUTO_CD
#setopt AUTO_PUSHD
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
setopt PROMPT_SUBST

# =============================================================================
# Auto completion
# =============================================================================

# Enable auto completion
# Performance optimization: use completion cache to speed up startup
autoload -Uz compinit
# Only run full compinit if completion cache is older than 24 hours
# shellcheck disable=SC1036,SC1072,SC1073,SC1009  # zsh-specific glob qualifier syntax
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # Skip check, use cache (much faster)
fi

# Show auto completion like 'menu'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Kiro integration
# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# =============================================================================
# Prompt
# =============================================================================

# zsh prompt (colored / 2-line)
# Performance optimization: use built-in ZSH_VERSION instead of running zsh --version
ZSH_VER="${ZSH_VERSION%.*}"

# Git branch name function
# Performance optimization: cache git branch with 2-second timeout to avoid slow git calls on every prompt
git_branch() {
  # Use TMPDIR for temp files (handles Cygwin /tmp permission quirks)
  local _tmpdir="${TMPDIR:-/tmp}"
  local branch cache_file="$_tmpdir/zsh_git_branch_$$"
  local cache_age current_dir_hash

  # Use directory hash for per-directory caching (portable hash generation)
  if command -v md5sum >/dev/null 2>&1; then
    current_dir_hash=$(echo "$PWD" | md5sum 2>/dev/null | cut -d' ' -f1)
  elif command -v md5 >/dev/null 2>&1; then
    current_dir_hash=$(echo "$PWD" | md5 -q 2>/dev/null)
  else
    # Fallback: use process ID if no hash command available
    current_dir_hash="$$"
  fi
  cache_file="$_tmpdir/zsh_git_branch_${current_dir_hash:-$$}"
  
  # Check cache (if exists and < 2 seconds old)
  if [[ -f "$cache_file" ]]; then
    # Get file modification time (portable across systems)
    if [[ "$OSTYPE" == darwin* ]]; then
      cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)))
    else
      cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
    fi
    if [[ $cache_age -lt 2 ]]; then
      branch=$(cat "$cache_file" 2>/dev/null)
      if [[ -n "$branch" ]]; then
        echo "%F{yellow}(${branch})%f"
        return
      fi
    fi
  fi
  
  # Get branch (with timeout for large repos - 0.5 second max)
  # Use timeout command if available, otherwise rely on git's own timeout
  if command -v timeout >/dev/null 2>&1; then
    branch=$(timeout 0.5 git symbolic-ref --short HEAD 2>/dev/null || echo "")
  else
    # Fallback: use git directly (may be slow in large repos)
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  fi
  
  # Cache result (only if we got a branch)
  if [[ -n "$branch" ]]; then
    echo "$branch" > "$cache_file" 2>/dev/null
    echo "%F{yellow}(${branch})%f"
  fi
}

# Base prompt (with git branch)
# shellcheck disable=SC2034  # PROMPT_BASE is used in zsh prompt system
PROMPT_BASE="%F{cyan}zsh-${ZSH_VER}-%n $(git_branch) %F{green}%~%f"$'\n'"%# "

# shellcheck disable=SC2034  # PROMPT is used by zsh
# shellcheck disable=SC2016  # Variable expansion intentionally deferred for zsh PROMPT_SUBST
PROMPT='%F{green}[INSERT]%f ${PROMPT_BASE}' # Do not expand variables when substituted by single quote

# Enable vi mode
bindkey -v

# Display indicator of vi mode in prompt
# shellcheck disable=SC2034  # PROMPT is used by zsh prompt system in case branches
function zle-keymap-select {
  # shellcheck disable=SC2016  # PROMPT_BASE to be expanded when updated
  case $KEYMAP in
    vicmd)  PROMPT='%F{red}[NORMAL]%f ${PROMPT_BASE}' ;;
    main|viins) PROMPT='%F{green}[INSERT]%f ${PROMPT_BASE}' ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select

# Optional: update prompt after each command (useful when switching git dirs)
autoload -Uz add-zsh-hook
add-zsh-hook precmd update_prompt
function update_prompt {
  # shellcheck disable=SC2034  # PROMPT_BASE is used in zsh prompt system
  PROMPT_BASE="%F{cyan}zsh-${ZSH_VER}-%n $(git_branch) %F{green}%~%f"$'\n'"%# "
}

# =============================================================================
# Theme
# =============================================================================

# Adding this at the end of ~/.zshrc (e.g. get the setting back even after logout bash)
# Actually, this is trapped at the end of .bashrc...
if [[ -f "$HOME/etc/mintty-colors-solarized/sol.dark" ]]; then
  # shellcheck disable=SC1091  # Optional theme file may not exist
  source "$HOME/etc/mintty-colors-solarized/sol.dark"
fi

# =============================================================================
# Zsh specific
# =============================================================================

# Just to overwrite the setting made by Oh-my-zsh
unsetopt AUTO_PUSHD
unsetopt PUSHD_MINUS

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=("$HOME/.docker/completions" "${fpath[@]}")
# Don't call compinit here, as it is already called prior.

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Auto-detect powerlevel10k installation path
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  # Use HOMEBREW_PREFIX if set by Homebrew
  _p10k_path="${HOMEBREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  # Apple Silicon Mac
  _p10k_path="/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  # Intel Mac or Linux with Homebrew in /usr/local
  _p10k_path="/usr/local/share/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  # Linux with Homebrew in standard location
  _p10k_path="/home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f "$HOME/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  # Linux with Homebrew in home directory
  _p10k_path="$HOME/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

# Source p10k theme if found
if [[ -n "${_p10k_path:-}" ]] && [[ -f "$_p10k_path" ]]; then
  source "$_p10k_path"
  # Source p10k config if exists
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi
unset _p10k_path

# End of Docker CLI completions
