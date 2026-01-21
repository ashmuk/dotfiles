#!/bin/bash
# Tmux configuration setup script
# This script sets up tmux configuration files in the user's home directory

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

# Set up error handling (no temp files to clean up)
setup_error_handling

print_status "Setting up tmux configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Validate environment
validate_dotfiles_dir "$DOTFILES_DIR" || exit 1
validate_required_commands ln || exit 1

# Detect platform
PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# Create symlinks and deploy tmuxinator templates
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlink to tmux configuration
    ln -sf "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.tmux.conf"

    # Create symlink for tmuxinator directory if it exists
    if [[ -d "$DOTFILES_DIR/config/tmux/tmuxinator" ]]; then
        print_status "Creating symlink for tmuxinator templates directory..."
        ln -sfn "$DOTFILES_DIR/config/tmux/tmuxinator" "$HOME/.tmuxinator"
        print_success "Tmuxinator directory symlinked"
    fi

    print_success "Symbolic links and templates deployed"
}

# Backup existing files
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "tmux"); then
        return 1
    fi

    local files=(.tmux.conf)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$file"
    done

    return 0
}

# Validate tmux configuration
validate_tmux_config() {
    print_status "Validating tmux configuration..."

    if ! command -v tmux >/dev/null 2>&1; then
        print_warning "tmux is not installed. Configuration will be ready when tmux is installed."
        return 0
    fi

    # Test tmux configuration syntax
    if tmux -f "$DOTFILES_DIR/config/tmux/tmux.conf" list-commands >/dev/null 2>&1; then
        print_success "tmux configuration syntax is valid"
    else
        print_error "tmux configuration has syntax errors"
        return 1
    fi

    return 0
}

# Main execution
main() {
    print_status "Starting tmux configuration setup..."

    if ! backup_existing_files; then
        print_error "Failed to backup existing files"
        return 1
    fi

    if ! validate_tmux_config; then
        print_error "tmux configuration validation failed"
        return 1
    fi

    if ! create_symlinks; then
        print_error "Failed to create symlinks"
        return 1
    fi

    print_success "Tmux configuration setup completed!"
    print_status ""
    print_status "Files deployed:"
    print_status "  - $HOME/.tmux.conf (symlink)"
    if [[ -d "$HOME/.tmuxinator" ]]; then
        print_status "  - $HOME/.tmuxinator/ (tmuxinator templates)"
        # List deployed templates
        for template in "$HOME/.tmuxinator"/*.yml; do
            if [[ -f "$template" ]]; then
                print_status "    - $(basename "$template")"
            fi
        done
    fi
    print_status ""
    print_status "Next steps:"
    if ! command -v tmux >/dev/null 2>&1; then
        print_status "  - Install tmux: brew install tmux (macOS) or apt install tmux (Linux)"
    fi
    if ! command -v tmuxinator >/dev/null 2>&1; then
        print_status "  - Install tmuxinator: gem install tmuxinator"
    fi
    print_status "  - Start a new tmux session: tmux new-session"
    print_status "  - Start tmuxinator session: tmuxinator start ai-dev"
    print_status "  - Reload config in running session: Ctrl-a + r"
    print_status ""

    return 0
}

# Run main function
main "$@"
