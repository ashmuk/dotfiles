#!/bin/bash
# Git configuration setup script
# This script sets up git configuration files in the user's home directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [[ -L "$target" ]]; then
        print_warning "$name already exists as symlink, removing..."
        rm "$target"
    elif [[ -f "$target" ]]; then
        print_warning "$name already exists as file, creating backup..."
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    print_status "Creating symlink for $name..."
    ln -s "$source" "$target"
    print_success "$name symlink created"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

print_status "Setting up git configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Detect platform
detect_platform() {
    case "$OSTYPE" in
        darwin*)  echo "mac" ;;
        linux*)   echo "linux" ;;
        msys*|cygwin*) echo "win" ;;
        *)        echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# 既存ファイルのバックアップ
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    backup_dir="$HOME/dotfiles/backup/.git_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for file in .gitignore .gitconfig .gitattributes ; do
        if [[ -f "$HOME/$file" ]]; then
            cp -L "$HOME/$file" "$backup_dir/"
            print_status "Backed up $file to $backup_dir"
        fi
    done
}

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlinks to platform-specific files
    ln -sf "$DOTFILES_DIR/git/gitconfig.common" "$HOME/.gitconfig"
    ln -sf "$DOTFILES_DIR/git/gitignore.common" "$HOME/.gitignore"
    ln -sf "$DOTFILES_DIR/git/gitattributes.common" "$HOME/.gitattributes"

    print_success "Symbolic links created in home directory"
}

# Create platform-specific files in dotfiles directory
create_platform_files() {
    print_status "Creating platform-dependent files in dotfiles root..."

    # Create gitconfig.$PLATFORM
    cat > "$DOTFILES_DIR/gitconfig.$PLATFORM" << 'EOF'
# Git configuration for platform
# This file is managed by dotfiles project

# Include common git configuration
[include]
    path = ~/dotfiles/git/gitconfig.common

# User-specific settings (override common settings if needed)
# Add your personal settings here
EOF

    # Create gitignore.$PLATFORM
    cat > "$DOTFILES_DIR/gitignore.$PLATFORM" << 'EOF'
# Global gitignore for platform
# This file is managed by dotfiles project

# Include common gitignore patterns
# Add your personal ignore patterns here
EOF

    # Create gitattributes.$PLATFORM
    cat > "$DOTFILES_DIR/gitattributes.$PLATFORM" << 'EOF'
# Global gitattributes for platform
# This file is managed by dotfiles project

# Include common gitattributes patterns
# Add your personal attributes here
EOF

    print_success "Platform-dependent files created in dotfiles directory"
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
#    create_platform_files
   create_symlinks

    print_success "Git configuration setup completed!"
#    print_status "Platform-specific files created:"
#    print_status "  - $DOTFILES_DIR/gitconfig.$PLATFORM"
#    print_status "  - $DOTFILES_DIR/gitignore.$PLATFORM"
#    print_status "  - $DOTFILES_DIR/gitattributes.$PLATFORM"
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
