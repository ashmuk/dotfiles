#!/bin/bash
# Shell configuration setup script
# This script sets up shell configuration files in the user's home directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source common functions
if [[ -f "$DOTFILES_DIR/lib/common.sh" ]]; then
    source "$DOTFILES_DIR/lib/common.sh"
else
    echo "Error: Common functions library not found at $DOTFILES_DIR/lib/common.sh" >&2
    exit 1
fi

# Set up error handling
setup_error_handling "$@"

print_status "Setting up shell configuration..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Validate environment
validate_dotfiles_dir "$DOTFILES_DIR" || exit 1
validate_required_commands git ln cat sed || exit 1

# Detect platform
PLATFORM=$(detect_platform)
print_status "Detected platform: $PLATFORM"

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlinks to platform-specific generated files
    ln -sf "$DOTFILES_DIR/bashrc.generated.$PLATFORM" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/zshrc.generated.$PLATFORM" "$HOME/.zshrc"

    # Create symlinks to profile files
    print_status "Creating profile file symlinks..."
    ln -sf "$DOTFILES_DIR/shell/profile/bash_logout" "$HOME/.bash_logout"
    ln -sf "$DOTFILES_DIR/shell/profile/bash_profile" "$HOME/.bash_profile"
    ln -sf "$DOTFILES_DIR/shell/profile/zprofile" "$HOME/.zprofile"
    ln -sf "$DOTFILES_DIR/shell/profile/zlogout" "$HOME/.zlogout"

    print_success "Symbolic links created in home directory"
}

# 既存ファイルのバックアップ
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "shell"); then
        return 1
    fi

    local files=(.bashrc .zshrc .bash_logout .bash_profile .zprofile .zlogout)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$file"
    done

    return 0
}

# Create platform-specific files in dotfiles directory
create_platform_files() {
    print_status "Creating platform-dependent files in dotfiles root..."

    local temp_files=()

    # Create bashrc.generated.$PLATFORM
    local bashrc_files=("$DOTFILES_DIR/shell/shell.common" "$DOTFILES_DIR/shell/shell.bash")
    for file in "${bashrc_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required shell file not found: $file"
            return 1
        fi
    done

    concatenate_files_with_shebang "$DOTFILES_DIR/bashrc.generated.$PLATFORM" "#!/bin/bash" "${bashrc_files[@]}" || return 1
    temp_files+=("$DOTFILES_DIR/bashrc.generated.$PLATFORM")

    # Create zshrc.generated.$PLATFORM
    local zshrc_files=("$DOTFILES_DIR/shell/shell.common" "$DOTFILES_DIR/shell/shell.zsh" "$DOTFILES_DIR/shell/shell.ohmy.zsh")
    for file in "${zshrc_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required shell file not found: $file"
            return 1
        fi
    done

    concatenate_files_with_shebang "$DOTFILES_DIR/zshrc.generated.$PLATFORM" "#!/bin/zsh" "${zshrc_files[@]}" || return 1
    temp_files+=("$DOTFILES_DIR/zshrc.generated.$PLATFORM")

    print_success "Platform-dependent files created in dotfiles directory"
    return 0
}

# Check and restore generated files if no actual changes
check_generated_files() {
    print_status "Checking for actual changes in generated files..."

    local files_restored=0
    local files=("bashrc.generated.$PLATFORM" "zshrc.generated.$PLATFORM")

    for file in "${files[@]}"; do
        if restore_git_file_if_no_changes "$DOTFILES_DIR/$file" "$DOTFILES_DIR"; then
            files_restored=$((files_restored + 1))
        fi
    done

    if [[ $files_restored -gt 0 ]]; then
        print_success "Restored $files_restored generated file(s) with no actual differences"
    else
        print_status "All generated files have meaningful changes or are unchanged"
    fi
}

# Main execution
main() {
    print_status "Starting shell configuration setup..."

    # All validation is done at the top of the script now

    if ! backup_existing_files; then
        print_error "Failed to backup existing files"
        return 1
    fi

    if ! create_platform_files; then
        print_error "Failed to create platform files"
        return 1
    fi

    check_generated_files

    if ! create_symlinks; then
        print_error "Failed to create symlinks"
        return 1
    fi

    print_success "Shell configuration setup completed!"
    print_status ""
    print_status "Symlinks created in home directory:"
    print_status "  - $HOME/.bashrc"
    print_status "  - $HOME/.zshrc"
    print_status "  - $HOME/.bash_logout"
    print_status "  - $HOME/.bash_profile"
    print_status "  - $HOME/.zprofile"
    print_status "  - $HOME/.zlogout"
    print_status ""

    return 0
}

# Run main function
main "$@"
