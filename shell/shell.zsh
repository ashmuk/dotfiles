
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

# =============================================================================
# Auto completion
# =============================================================================

# Enable auto completion
autoload -Uz compinit
compinit

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
ZSH_VER=$(zsh --version | head -n1 | awk '{print $2}')
# shellcheck disable=SC2034  # PROMPT_BASE is used in zsh prompt system
PROMPT_BASE="%F{cyan}zsh-${ZSH_VER}-%n %F{green}%~%f"$'\n'"%# "
# shellcheck disable=SC2034  # PROMPT is used by zsh
PROMPT="%F{green}[INSERT]%f $PROMPT_BASE"

# Enable vi mode
bindkey -v

# Display indicator of vi mode in prompt
# shellcheck disable=SC2034  # PROMPT is used by zsh prompt system in case branches
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

# Adding this at the end of ~/.zshrc (e.g. get the setting back even after logout bash)
# Actually, this is trapped at the end of .bashrc...
if [[ -f "$HOME/etc/mintty-colors-solarized/sol.light" ]]; then
  # shellcheck disable=SC1091  # Optional theme file may not exist
  source "$HOME/etc/mintty-colors-solarized/sol.light"
fi

# =============================================================================
# Zsh specific
# =============================================================================

# Just to overwrite the setting made by Oh-my-zsh
unsetopt AUTO_PUSHD
unsetopt PUSHD_MINUS

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
