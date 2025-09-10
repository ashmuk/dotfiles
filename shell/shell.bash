
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
