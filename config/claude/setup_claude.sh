#!/bin/bash
# Claude configuration setup script
# This script sets up Claude configuration files in the user's home directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source common functions
if [[ -f "$DOTFILES_DIR/lib/common.sh" ]]; then
    # shellcheck disable=SC1091
    source "$DOTFILES_DIR/lib/common.sh"
else
    echo "Error: Common functions library not found at $DOTFILES_DIR/lib/common.sh" >&2
    exit 1
fi

# Set up error handling
setup_error_handling "$@"

print_status "Setting up Claude configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Validate environment
validate_dotfiles_dir "$DOTFILES_DIR" || exit 1
validate_required_commands ln mkdir || exit 1

# Detect platform
PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# Create Claude configuration directory
create_claude_directory() {
    print_status "Creating Claude configuration directory..."

    # Create ~/.claude directory if it doesn't exist
    if [[ ! -d "$HOME/.claude" ]]; then
        mkdir -p "$HOME/.claude"
        print_status "Created $HOME/.claude directory"
    fi

    # Create logs directory
    if [[ ! -d "$HOME/.claude/logs" ]]; then
        mkdir -p "$HOME/.claude/logs"
        print_status "Created $HOME/.claude/logs directory"
    fi

    return 0
}

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlink to Claude configuration
    ln -sf "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"

    # Create symlink to Claude statusline script
    ln -sf "$DOTFILES_DIR/config/claude/statusline.sh" "$HOME/.claude/statusline.sh"

    print_success "Symbolic links created in home directory"
}

# Backup existing files
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "claude"); then
        return 1
    fi

    local files=(.claude/settings.json .claude/settings.local.json)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$(basename "$file")"
    done

    return 0
}

# Validate Claude configuration
validate_claude_config() {
    print_status "Validating Claude configuration..."

    # Check if configuration file exists and is valid JSON
    local config_file="$DOTFILES_DIR/config/claude/settings.json"
    if [[ ! -f "$config_file" ]]; then
        print_error "Claude configuration file not found: $config_file"
        return 1
    fi

    # Validate JSON syntax using python or jq if available
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$config_file" >/dev/null 2>&1; then
            print_error "Claude configuration has invalid JSON syntax"
            return 1
        fi
        print_success "Claude configuration JSON syntax is valid"
    elif command -v python3 >/dev/null 2>&1; then
        if ! python3 -m json.tool "$config_file" >/dev/null 2>&1; then
            print_error "Claude configuration has invalid JSON syntax"
            return 1
        fi
        print_success "Claude configuration JSON syntax is valid"
    else
        print_warning "No JSON validator found (jq or python3). Skipping syntax validation."
    fi

    return 0
}

# Main execution
main() {
    print_status "Starting Claude configuration setup..."

    if ! backup_existing_files; then
        print_error "Failed to backup existing files"
        return 1
    fi

    if ! validate_claude_config; then
        print_error "Claude configuration validation failed"
        return 1
    fi

    if ! create_claude_directory; then
        print_error "Failed to create Claude directory"
        return 1
    fi

    if ! create_symlinks; then
        print_error "Failed to create symlinks"
        return 1
    fi

    print_success "Claude configuration setup completed!"
    print_status ""
    print_status "Configuration files:"
    print_status "  - $HOME/.claude/settings.json (main configuration)"
    if [[ -f "$HOME/.claude/settings.local.json" ]]; then
        print_status "  - $HOME/.claude/settings.local.json (local overrides)"
    fi
    print_status "  - $HOME/.claude/statusline.sh (status display)"
    print_status "  - $HOME/.claude/logs/ (log directory)"
    print_status ""
    print_status "Features enabled:"
    print_status "  - Claude Opus 4.1 model"
    print_status "  - Cross-platform development support"
    print_status "  - Security-focused permission system"
    print_status "  - Automatic backup and validation"
    print_status "  - Japanese documentation available"
    print_status ""

    return 0
}

# Run main function
main "$@"
