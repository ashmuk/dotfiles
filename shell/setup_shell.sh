#!/bin/bash
# Shell configuration setup script
# This script sets up shell configuration files in the user's home directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

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
    # Use create_symlink_safe for Cygwin compatibility (falls back to copy if symlinks fail)
    create_symlink_safe "$DOTFILES_DIR/bashrc.generated" "$HOME/.bashrc" ".bashrc"
    create_symlink_safe "$DOTFILES_DIR/zshrc.generated" "$HOME/.zshrc" ".zshrc"

    # Create symlinks to profile files
    print_status "Creating profile file symlinks..."
    create_symlink_safe "$DOTFILES_DIR/shell/profile/bash_logout" "$HOME/.bash_logout" ".bash_logout"
    create_symlink_safe "$DOTFILES_DIR/shell/profile/bash_profile" "$HOME/.bash_profile" ".bash_profile"
    create_symlink_safe "$DOTFILES_DIR/shell/profile/zprofile" "$HOME/.zprofile" ".zprofile"
    create_symlink_safe "$DOTFILES_DIR/shell/profile/zlogout" "$HOME/.zlogout" ".zlogout"

    # Create symlink to p10k configuration
    if [[ -f "$DOTFILES_DIR/shell/dot.p10k.zsh" ]]; then
        print_status "Creating p10k configuration symlink..."
        create_symlink_safe "$DOTFILES_DIR/shell/dot.p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"
    fi

    print_success "Symbolic links created in home directory"
}

# Setup MintTY colors for Cygwin
# Installs Solarized Dark theme for MintTY terminal
setup_mintty_colors() {
    # Only run on Cygwin with MintTY
    if [[ "$OSTYPE" != cygwin* ]]; then
        return 0
    fi

    print_status "Setting up MintTY colors..."

    local mintty_colors_dir="$DOTFILES_DIR/etc/mintty-colors-solarized"
    local minttyrc_source="$mintty_colors_dir/.minttyrc.dark"
    local minttyrc_target="$HOME/.minttyrc"

    # Check if the color theme source exists
    if [[ ! -f "$minttyrc_source" ]]; then
        print_warning "MintTY color theme not found: $minttyrc_source"
        return 0
    fi

    # Backup existing .minttyrc if it exists and is different
    if [[ -f "$minttyrc_target" ]]; then
        if ! diff -q "$minttyrc_source" "$minttyrc_target" >/dev/null 2>&1; then
            local backup_name
            backup_name="${minttyrc_target}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$minttyrc_target" "$backup_name"
            print_status "Backed up existing .minttyrc to $backup_name"
        fi
    fi

    # Copy the color theme (MintTY reads .minttyrc, not a symlink target)
    cp "$minttyrc_source" "$minttyrc_target"
    print_success "MintTY Solarized Dark theme installed to $minttyrc_target"

    # Also set up the etc directory for shell sourcing
    local etc_target="$HOME/etc/mintty-colors-solarized"
    if [[ ! -d "$etc_target" ]]; then
        mkdir -p "$HOME/etc"
        create_symlink_safe "$mintty_colors_dir" "$etc_target" "mintty-colors-solarized"
    fi

    print_success "MintTY color configuration complete"
}

# 既存ファイルのバックアップ
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir
    if ! backup_dir=$(create_backup_dir "shell"); then
        return 1
    fi

    local files=(.bashrc .zshrc .bash_logout .bash_profile .zprofile .zlogout .p10k.zsh)
    for file in "${files[@]}"; do
        backup_file "$HOME/$file" "$backup_dir" "$file"
    done

    return 0
}

# Create platform-specific files in dotfiles directory
create_platform_files() {
    print_status "Creating platform-dependent files in dotfiles root..."

    local temp_files=()

    # Create bashrc.generated (universal - platform detection handled internally)
    local bashrc_files=("$DOTFILES_DIR/shell/shell.common" "$DOTFILES_DIR/shell/shell.bash")
    for file in "${bashrc_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required shell file not found: $file"
            return 1
        fi
    done

    concatenate_files_with_shebang "$DOTFILES_DIR/bashrc.generated" "#!/bin/bash" "${bashrc_files[@]}" || return 1
    temp_files+=("$DOTFILES_DIR/bashrc.generated")

    # Create zshrc.generated (universal - platform detection handled internally)
    zshrc_files=("$DOTFILES_DIR/shell/shell.common" "$DOTFILES_DIR/shell/shell.ohmy.zsh" "$DOTFILES_DIR/shell/shell.zsh")

    for file in "${zshrc_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required shell file not found: $file"
            return 1
        fi
    done

    concatenate_files_with_shebang "$DOTFILES_DIR/zshrc.generated" "#!/bin/zsh" "${zshrc_files[@]}" || return 1
    temp_files+=("$DOTFILES_DIR/zshrc.generated")

    print_success "Platform-dependent files created in dotfiles directory"
    return 0
}

# Check and restore generated files if no actual changes
check_generated_files() {
    print_status "Checking for actual changes in generated files..."

    local files_restored=0
    local files=("bashrc.generated" "zshrc.generated")

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

    # Setup MintTY colors on Cygwin
    setup_mintty_colors

    print_success "Shell configuration setup completed!"
    print_status ""
    print_status "Symlinks created in home directory:"
    print_status "  - $HOME/.bashrc"
    print_status "  - $HOME/.zshrc"
    print_status "  - $HOME/.bash_logout"
    print_status "  - $HOME/.bash_profile"
    print_status "  - $HOME/.zprofile"
    print_status "  - $HOME/.zlogout"
    if [[ -L "$HOME/.p10k.zsh" ]]; then
        print_status "  - $HOME/.p10k.zsh (powerlevel10k config)"
    fi
    print_status ""

    return 0
}

# Run main function
main "$@"
