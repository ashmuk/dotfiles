
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
  # shellcheck disable=SC1091
  source /usr/local/etc/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
fi

# Bash prompt customization (colored, distinct from zsh style)
# Color definitions - using different colors to distinguish from zsh
if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
  # Enable colors - bash version in magenta to distinguish from zsh cyan
  export PS1='\[\033[35m\]bash-${BASH_VERSION%%[^0-9.]*} \[\033[32m\]\u@\h \[\033[34m\]\w\[\033[0m\]\n\[\033[1;35m\]❯\[\033[0m\] '
else
  # Fallback for terminals without color support
  export PS1='bash-${BASH_VERSION%%[^0-9.]*} \u@\h \w\n❯ '
fi

# Bash history settings
shopt -s histappend
shopt -s checkwinsize

# Kiro integration
# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

# =============================================================================
# Bash Functions
# =============================================================================
# to be defined if any applicable
