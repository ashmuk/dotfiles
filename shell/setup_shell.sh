#!/bin/bash
# Shell configuration setup script
# This script sets up shell configuration files in the user's home directory

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

print_status "Setting up shell configuration..."
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

# Create symlinks in home directory
create_symlinks() {
    print_status "Creating symbolic links in home directory..."

    # Create symlinks to platform-specific generated files
    ln -sf "$DOTFILES_DIR/bashrc.generated" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/zshrc.generated" "$HOME/.zshrc"
    
    # Create symlinks to profile files
    print_status "Creating profile file symlinks..."
    ln -sf "$DOTFILES_DIR/shell/profile/bash_logout" "$HOME/.bash_logout"
    ln -sf "$DOTFILES_DIR/shell/profile/bash_profile" "$HOME/.bash_profile"
    ln -sf "$DOTFILES_DIR/shell/profile/zprofile" "$HOME/.zprofile"

    print_success "Symbolic links created in home directory"
}

# 既存ファイルのバックアップ
backup_existing_files() {
    print_status "Backing up existing files..."

    local backup_dir="$HOME/dotfiles/backup/.shell_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for file in .bashrc .zshrc .bash_logout .bash_profile .zprofile ; do
        if [[ -f "$HOME/$file" ]]; then
            cp -L "$HOME/$file" "$backup_dir/"
            print_status "Backed up $file to $backup_dir"
        fi
    done
}

# Create platform-specific files in dotfiles directory
create_platform_files() {
    print_status "Creating platform-dependent files in dotfiles root..."

    # Create bashrc.generated
    cat $DOTFILES_DIR/shell/shell.common $DOTFILES_DIR/shell/shell.bash > "$DOTFILES_DIR/bashrc.generated"
    if [[ -f "$DOTFILES_DIR/bashrc.generated" ]]; then
        case "$PLATFORM" in
            mac*)   sed -i '' '1i\
#!/bin/bash' "$DOTFILES_DIR/bashrc.generated" ;;
            *)      sed -i '1i#!/bin/bash' "$DOTFILES_DIR/bashrc.generated" ;;
        esac
    fi

    # Create zshrc.generated
    cat $DOTFILES_DIR/shell/shell.common $DOTFILES_DIR/shell/shell.zsh $DOTFILES_DIR/shell/shell.ohmy.zsh > "$DOTFILES_DIR/zshrc.generated"
    if [[ -f "$DOTFILES_DIR/zshrc.generated" ]]; then
        case "$PLATFORM" in
            mac*)   sed -i '' '1i\
#!/bin/zsh' "$DOTFILES_DIR/zshrc.generated" ;;
            *)      sed -i '1i#!/bin/zsh' "$DOTFILES_DIR/zshrc.generated" ;;
        esac

    fi

    print_success "Platform-dependent files created in dotfiles directory"
}

# Check and restore generated files if no actual changes
check_generated_files() {
    print_status "Checking for actual changes in generated files..."
    
    local files_restored=0
    
    for file in "bashrc.generated" "zshrc.generated"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            # Check if file is tracked by git and has changes
            if git -C "$DOTFILES_DIR" ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                # File is tracked, check for actual content differences
                if ! git -C "$DOTFILES_DIR" diff --quiet "$file" 2>/dev/null; then
                    # File has changes, check if they are meaningful
                    local temp_diff=$(git -C "$DOTFILES_DIR" diff --ignore-space-change --ignore-blank-lines "$file" 2>/dev/null)
                    if [[ -z "$temp_diff" ]]; then
                        # No meaningful differences, restore the file
                        print_status "No actual differences in $file, restoring..."
                        git -C "$DOTFILES_DIR" restore "$file" 2>/dev/null || true
                        files_restored=$((files_restored + 1))
                    fi
                fi
            fi
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

    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi

    backup_existing_files
    create_platform_files
    check_generated_files
    create_symlinks

    print_success "Shell configuration setup completed!"
    print_status ""
    print_status "Symlinks created in home directory:"
    print_status "  - $HOME/.bashrc"
    print_status "  - $HOME/.zshrc"
    print_status "  - $HOME/.bash_logout"
    print_status "  - $HOME/.bash_profile"
    print_status "  - $HOME/.zprofile"
    print_status ""
}

# Run main function
main "$@"
