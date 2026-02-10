#!/bin/bash
# Ghostty configuration setup script
# This script sets up Ghostty configuration files in the user's home directory

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

print_status "Setting up Ghostty configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Validate environment
validate_dotfiles_dir "$DOTFILES_DIR" || exit 1
validate_required_commands ln mkdir || exit 1

# Create Ghostty configuration directory
create_ghostty_directories() {
    print_status "Creating Ghostty configuration directory..."

    if [[ ! -d "$HOME/.config/ghostty" ]]; then
        mkdir -p "$HOME/.config/ghostty"
        print_status "Created $HOME/.config/ghostty directory"
    fi

    return 0
}

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlink to Ghostty configuration
    ln -sf "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
    print_status "Created symlink: ~/.config/ghostty/config"

    print_success "Symbolic links created"
}

# Backup existing files
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "ghostty"); then
        return 1
    fi

    local files=(.config/ghostty/config)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$(basename "$file")"
    done

    return 0
}

# Validate Ghostty configuration
validate_ghostty_config() {
    print_status "Validating Ghostty configuration..."

    # Check if configuration file exists
    local config_file="$DOTFILES_DIR/config/ghostty/config"
    if [[ ! -f "$config_file" ]]; then
        print_error "Ghostty configuration file not found: $config_file"
        return 1
    fi

    # Check if Ghostty is installed
    if ! command -v ghostty >/dev/null 2>&1; then
        print_warning "Ghostty is not installed. Configuration will be ready when Ghostty is installed."
        return 0
    fi

    print_success "Ghostty configuration validated"
    return 0
}

# Main execution
main() {
    print_status "Starting Ghostty configuration setup..."

    if ! backup_existing_files; then
        print_error "Failed to backup existing files"
        return 1
    fi

    if ! validate_ghostty_config; then
        print_error "Ghostty configuration validation failed"
        return 1
    fi

    if ! create_ghostty_directories; then
        print_error "Failed to create Ghostty directories"
        return 1
    fi

    if ! create_symlinks; then
        print_error "Failed to create symlinks"
        return 1
    fi

    print_success "Ghostty configuration setup completed!"
    print_status ""
    print_status "Configuration files:"
    print_status "  - $HOME/.config/ghostty/config (symlink)"
    print_status ""
    if ! command -v ghostty >/dev/null 2>&1; then
        print_status "Next steps:"
        print_status "  - Install Ghostty: https://ghostty.org/"
        print_status "  - Restart Ghostty to load the configuration"
        print_status ""
    fi

    return 0
}

# Run main function
main "$@"
