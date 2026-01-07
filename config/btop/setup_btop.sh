#!/bin/bash
# btop configuration setup script
# This script sets up btop configuration files in the user's home directory

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

print_status "Setting up btop configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Validate environment
validate_dotfiles_dir "$DOTFILES_DIR" || exit 1
validate_required_commands ln mkdir || exit 1

# Detect platform
PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# Create btop configuration directories
create_btop_directories() {
    print_status "Creating btop configuration directories..."

    # Create ~/.config/btop directory if it doesn't exist
    if [[ ! -d "$HOME/.config/btop" ]]; then
        mkdir -p "$HOME/.config/btop"
        print_status "Created $HOME/.config/btop directory"
    fi

    # Create ~/.config/btop/themes directory if it doesn't exist
    if [[ ! -d "$HOME/.config/btop/themes" ]]; then
        mkdir -p "$HOME/.config/btop/themes"
        print_status "Created $HOME/.config/btop/themes directory"
    fi

    return 0
}

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlink to btop configuration
    ln -sf "$DOTFILES_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
    print_status "Created symlink: ~/.config/btop/btop.conf"

    # Create symlink to custom theme
    if [[ -f "$DOTFILES_DIR/config/btop/theme/solarized_dark.theme" ]]; then
        ln -sf "$DOTFILES_DIR/config/btop/theme/solarized_dark.theme" "$HOME/.config/btop/themes/solarized_dark.theme"
        print_status "Created symlink: ~/.config/btop/themes/solarized_dark.theme"
    fi

    print_success "Symbolic links created"
}

# Backup existing files
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "btop"); then
        return 1
    fi

    local files=(.config/btop/btop.conf .config/btop/themes/solarized_dark.theme)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$(basename "$file")"
    done

    return 0
}

# Validate btop configuration
validate_btop_config() {
    print_status "Validating btop configuration..."

    # Check if configuration file exists
    local config_file="$DOTFILES_DIR/config/btop/btop.conf"
    if [[ ! -f "$config_file" ]]; then
        print_error "btop configuration file not found: $config_file"
        return 1
    fi

    # Check if custom theme exists
    local theme_file="$DOTFILES_DIR/config/btop/theme/solarized_dark.theme"
    if [[ ! -f "$theme_file" ]]; then
        print_warning "Custom theme file not found: $theme_file"
    fi

    # Check if btop is installed
    if ! command -v btop >/dev/null 2>&1; then
        print_warning "btop is not installed. Configuration will be ready when btop is installed."
        return 0
    fi

    print_success "btop configuration validated"
    return 0
}

# Main execution
main() {
    print_status "Starting btop configuration setup..."

    if ! backup_existing_files; then
        print_error "Failed to backup existing files"
        return 1
    fi

    if ! validate_btop_config; then
        print_error "btop configuration validation failed"
        return 1
    fi

    if ! create_btop_directories; then
        print_error "Failed to create btop directories"
        return 1
    fi

    if ! create_symlinks; then
        print_error "Failed to create symlinks"
        return 1
    fi

    print_success "btop configuration setup completed!"
    print_status ""
    print_status "Configuration files:"
    print_status "  - $HOME/.config/btop/btop.conf (main configuration)"
    print_status "  - $HOME/.config/btop/themes/solarized_dark.theme (custom theme)"
    print_status ""
    print_status "Features enabled:"
    print_status "  - Vim keybindings (h,j,k,l,g,G navigation)"
    print_status "  - Solarized dark theme"
    print_status "  - Braille graph symbols for high resolution"
    print_status "  - Custom layout presets"
    print_status ""
    if ! command -v btop >/dev/null 2>&1; then
        print_status "Next steps:"
        print_status "  - Install btop:"
        case "$PLATFORM" in
            mac)
                print_status "    brew install btop"
                ;;
            linux)
                print_status "    sudo apt install btop (Ubuntu/Debian)"
                print_status "    sudo dnf install btop (Fedora)"
                ;;
            wsl)
                print_status "    sudo apt install btop"
                ;;
            win)
                print_status "    scoop install btop"
                ;;
        esac
        print_status "  - Launch btop: btop"
        print_status ""
    fi

    return 0
}

# Run main function
main "$@"
