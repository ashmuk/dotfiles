#!/bin/bash
# Git configuration setup script
# This script sets up git configuration files in the user's home directory

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source common functions library for cross-platform utilities
if [[ -f "$DOTFILES_DIR/lib/common.sh" ]]; then
    # shellcheck disable=SC1091
    source "$DOTFILES_DIR/lib/common.sh"
else
    echo "Error: Common functions library not found at $DOTFILES_DIR/lib/common.sh" >&2
    exit 1
fi

print_status "Setting up git configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Detect platform (using function from lib/common.sh)
PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# 既存ファイルのバックアップ
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    backup_dir="$DOTFILES_DIR/backup/.git_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for file in .gitignore .gitconfig .gitattributes ; do
        if [[ -f "$HOME/$file" ]]; then
            cp -L "$HOME/$file" "$backup_dir/"
            print_status "Backed up $file to $backup_dir"
        fi
    done
}

# Create symlinks in home directory
# Uses create_symlink_safe for Cygwin compatibility (falls back to copy if symlinks fail)
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlinks to platform-specific files
    create_symlink_safe "$DOTFILES_DIR/git/gitconfig.common" "$HOME/.gitconfig" ".gitconfig"
    create_symlink_safe "$DOTFILES_DIR/git/gitignore.common" "$HOME/.gitignore" ".gitignore"
    create_symlink_safe "$DOTFILES_DIR/git/gitattributes.common" "$HOME/.gitattributes" ".gitattributes"

    print_success "Symbolic links created in home directory"
}

# Configure Cygwin-specific git settings
# NTFS is case-insensitive and doesn't preserve Unix permissions
configure_cygwin_git() {
    if [[ "$OSTYPE" != cygwin* ]]; then
        return 0
    fi

    print_status "Configuring Cygwin-specific git settings..."

    # NTFS is case-insensitive; ignorecase=true prevents checkout failures
    # and merge conflicts caused by case-only filename differences
    git config --global core.ignorecase true
    print_status "  Set core.ignorecase = true (NTFS is case-insensitive)"

    # NTFS doesn't preserve Unix file permissions; filemode=false prevents
    # spurious diffs due to permission changes
    git config --global core.filemode false
    print_status "  Set core.filemode = false (NTFS doesn't preserve Unix permissions)"

    # Ensure proper line ending handling
    # autocrlf=input is already set in gitconfig.common, but verify it
    local current_autocrlf
    current_autocrlf=$(git config --global core.autocrlf 2>/dev/null || echo "")
    if [[ "$current_autocrlf" != "input" ]]; then
        print_status "  Note: Consider setting core.autocrlf = input for Cygwin"
    fi

    print_success "Cygwin-specific git settings configured"
}

# Main execution
main() {
    print_status "Starting git configuration setup..."

    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi

    backup_existing_files
    create_symlinks
    configure_cygwin_git

    print_success "Git configuration setup completed!"
    print_status ""
    print_status "Symlinks created in home directory:"
    print_status "  - $HOME/.gitconfig"
    print_status "  - $HOME/.gitignore"
    print_status "  - $HOME/.gitattributes"
    print_status ""
    print_status "To apply changes, restart your terminal or run: git config --list"
}

# Run main function
main "$@"
