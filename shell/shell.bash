
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

# Kiro integration
# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

# =============================================================================
# Bash Functions
# =============================================================================
# to be defined if any applicable
