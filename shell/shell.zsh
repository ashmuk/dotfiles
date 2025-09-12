
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
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# =============================================================================
# Zsh specific
# =============================================================================
# to be defined if any applicable
