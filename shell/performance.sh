#!/bin/bash
# Performance optimization utilities for shell configuration
# This file provides lazy-loading and performance enhancement utilities

# =============================================================================
# Lazy Loading Framework
# =============================================================================

# Function to create lazy-loaded aliases
# Usage: lazy_alias <alias_name> <command_to_run_on_first_use>
lazy_alias() {
    local alias_name="$1"
    local real_command="$2"

    # Create a wrapper function that replaces itself
    eval "
    $alias_name() {
        unset -f $alias_name
        $real_command
        $alias_name \"\$@\"
    }"
}

# Function to lazy-load functions from files
# Usage: lazy_load_file <function_name> <file_path>
lazy_load_file() {
    local func_name="$1"
    local file_path="$2"

    if [[ -f "$file_path" ]]; then
        eval "
        $func_name() {
            unset -f $func_name
            source '$file_path'
            if type $func_name &>/dev/null; then
                $func_name \"\$@\"
            else
                echo 'Function $func_name not found in $file_path' >&2
                return 1
            fi
        }"
    fi
}

# Function to lazy-load command with dependency check
# Usage: lazy_command <alias_name> <command> <install_hint>
lazy_command() {
    local alias_name="$1"
    local real_command="$2"
    local install_hint="$3"

    eval "
    $alias_name() {
        if command -v ${real_command%% *} >/dev/null 2>&1; then
            unset -f $alias_name
            alias $alias_name='$real_command'
            $real_command \"\$@\"
        else
            echo 'Command ${real_command%% *} not found.' >&2
            echo 'Install hint: $install_hint' >&2
            return 127
        fi
    }"
}

# =============================================================================
# Performance Monitoring
# =============================================================================

# Function to benchmark command execution time
benchmark() {
    local cmd="$*"
    if [[ -z "$cmd" ]]; then
        echo "Usage: benchmark <command>" >&2
        return 1
    fi

    echo "Benchmarking: $cmd"
    time eval "$cmd"
}

# Function to profile shell startup time
profile_startup() {
    local shell_type="${1:-$SHELL}"
    local config_file

    case "$(basename "$shell_type")" in
        bash) config_file="$HOME/.bashrc" ;;
        zsh)  config_file="$HOME/.zshrc" ;;
        *)    config_file="$HOME/.profile" ;;
    esac

    if [[ -f "$config_file" ]]; then
        echo "Profiling startup time for $(basename "$shell_type")..."
        time "$shell_type" -c "source '$config_file'; exit"
    else
        echo "Configuration file not found: $config_file" >&2
        return 1
    fi
}

# =============================================================================
# Cache Management
# =============================================================================

# Simple cache directory setup
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
mkdir -p "$CACHE_DIR"

# Function to cache command output
cache_command() {
    local cache_key="$1"
    local cache_duration="${2:-3600}" # Default 1 hour
    shift 2
    local cmd="$*"

    local cache_file="$CACHE_DIR/$cache_key"
    local cache_time_file="$cache_file.time"

    # Check if cache exists and is still valid
    if [[ -f "$cache_file" ]] && [[ -f "$cache_time_file" ]]; then
        local cache_time
        cache_time=$(cat "$cache_time_file" 2>/dev/null || echo 0)
        local current_time
        current_time=$(date +%s)

        if (( current_time - cache_time < cache_duration )); then
            cat "$cache_file"
            return 0
        fi
    fi

    # Execute command and cache result
    if eval "$cmd" > "$cache_file" 2>/dev/null; then
        date +%s > "$cache_time_file"
        cat "$cache_file"
        return 0
    else
        rm -f "$cache_file" "$cache_time_file"
        return 1
    fi
}

# Function to clear cache
clear_cache() {
    local pattern="${1:-*}"
    if [[ "$pattern" == "all" ]]; then
        rm -rf "${CACHE_DIR:?}"/*
        echo "All cache cleared"
    else
        rm -f "$CACHE_DIR"/"$pattern"*
        echo "Cache cleared for pattern: $pattern"
    fi
}

# =============================================================================
# Lazy-Loaded Aliases for Expensive Operations
# =============================================================================

# Lazy-load node version manager if available
if [[ -d "$HOME/.nvm" ]]; then
    lazy_load_file nvm "$HOME/.nvm/nvm.sh"
fi

# Lazy-load rbenv if available
if [[ -d "$HOME/.rbenv" ]]; then
    lazy_alias rbenv "export PATH=\"$HOME/.rbenv/bin:$PATH\" && eval \"$(rbenv init -)\""
fi

# Lazy-load pyenv if available
if [[ -d "$HOME/.pyenv" ]]; then
    lazy_alias pyenv "export PATH=\"$HOME/.pyenv/bin:$PATH\" && eval \"$(pyenv init -)\" && eval \"$(pyenv virtualenv-init -)\""
fi

# Lazy-load Docker completion
lazy_command docker-compose 'docker-compose' 'Install Docker Desktop or docker-compose'

# Lazy-load kubectl completion
lazy_command kubectl 'kubectl' 'Install kubectl: https://kubernetes.io/docs/tasks/tools/'

# =============================================================================
# Performance-Optimized Alternatives
# =============================================================================

# Fast directory listing (if exa is available)
if command -v exa >/dev/null 2>&1; then
    alias ll='exa -la --git'
    alias lt='exa -T'
elif command -v ls >/dev/null 2>&1; then
    # Fallback to regular ls with optimizations
    if ls --color=auto / >/dev/null 2>&1; then
        alias ll='ls -la --color=auto'
    else
        alias ll='ls -la'
    fi
fi

# Fast find alternative (if fd is available)
lazy_command fd 'fd' 'Install fd: cargo install fd-find or brew install fd'

# Fast grep alternative (rg is already handled in aliases.shell)

# =============================================================================
# Startup Performance Optimization
# =============================================================================

# Skip loading completions in non-interactive shells
if [[ $- != *i* ]]; then
    return 0
fi

# Defer loading of completion systems
if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh-specific optimizations
    lazy_load_completion() {
        autoload -Uz compinit
        # Only regenerate completion cache once per day
        local zcompdump="${HOME}/.zcompdump"
        if [[ -f "$zcompdump" && $(find "$zcompdump" -mtime +1 2>/dev/null) ]]; then
            compinit
        else
            compinit -C
        fi
    }

    # Defer compinit loading
    lazy_alias compinit 'lazy_load_completion'
fi

# =============================================================================
# Environment Variable Optimization
# =============================================================================

# Cache PATH deduplication
if [[ -z "$PATH_DEDUPE_DONE" ]]; then
    # Remove duplicate PATH entries
    if [[ -n "$ZSH_VERSION" ]]; then
        # shellcheck disable=SC2034  # path is automatically synchronized with PATH in zsh
        typeset -aU path  # This is used by zsh for PATH deduplication
    else
        # Bash PATH deduplication
        PATH=$(echo "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf ":"; printf $1 }')
        export PATH
    fi
    export PATH_DEDUPE_DONE=1
fi
