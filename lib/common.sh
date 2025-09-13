#!/bin/bash
###############################################################################
#
# Common functions library for dotfiles setup scripts
# This file contains shared functions used across all setup scripts
#
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Output Functions
# =============================================================================

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

# =============================================================================
# Platform Detection
# =============================================================================

detect_platform() {
    case "$OSTYPE" in
        darwin*)  echo "mac" ;;
        linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        msys*|cygwin*) echo "win" ;;
        *)        echo "unknown" ;;
    esac
}

# Detect Windows environment more precisely
detect_windows_env() {
    if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo "msys"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "cygwin"
    elif command -v powershell.exe >/dev/null 2>&1; then
        echo "native"
    else
        echo "unknown"
    fi
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_dotfiles_dir() {
    local dotfiles_dir="$1"

    if [[ ! -d "$dotfiles_dir" ]]; then
        print_error "Dotfiles directory not found: $dotfiles_dir"
        return 1
    fi

    if [[ ! -f "$dotfiles_dir/Makefile" ]]; then
        print_error "Invalid dotfiles directory (no Makefile found): $dotfiles_dir"
        return 1
    fi

    return 0
}

validate_required_commands() {
    local commands=("$@")
    local missing=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing required commands: ${missing[*]}"
        return 1
    fi

    return 0
}

# =============================================================================
# Backup Functions
# =============================================================================

create_backup_dir() {
    local backup_type="$1"
    local backup_dir
    backup_dir="$HOME/dotfiles/backup/.${backup_type}_backup_$(date +%Y%m%d_%H%M%S)"

    if ! mkdir -p "$backup_dir"; then
        print_error "Failed to create backup directory: $backup_dir"
        return 1
    fi

    echo "$backup_dir"
}

backup_file() {
    local source_file="$1"
    local backup_dir="$2"
    local relative_path="${3:-$(basename "$source_file")}"

    if [[ ! -f "$source_file" ]]; then
        return 0  # Nothing to backup
    fi

    local backup_file="$backup_dir/$relative_path"
    local backup_parent_dir
    backup_parent_dir=$(dirname "$backup_file")

    if ! mkdir -p "$backup_parent_dir"; then
        print_error "Failed to create backup parent directory: $backup_parent_dir"
        return 1
    fi

    if ! cp -L "$source_file" "$backup_file"; then
        print_error "Failed to backup $source_file to $backup_file"
        return 1
    fi

    print_status "Backed up $(basename "$source_file") to $backup_dir"
    return 0
}

backup_directory() {
    local source_dir="$1"
    local backup_dir="$2"
    local relative_path="${3:-$(basename "$source_dir")}"

    if [[ ! -d "$source_dir" ]] || [[ -L "$source_dir" ]]; then
        return 0  # Nothing to backup or it's a symlink
    fi

    local backup_target="$backup_dir/$relative_path"

    if ! cp -r "$source_dir" "$backup_target"; then
        print_error "Failed to backup directory $source_dir to $backup_target"
        return 1
    fi

    print_status "Backed up directory $(basename "$source_dir") to $backup_dir"
    return 0
}

# =============================================================================
# Symlink Functions
# =============================================================================

create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    local backup_dir="$4"

    # Validate source exists
    if [[ ! -e "$source" ]]; then
        print_error "Source file does not exist: $source"
        return 1
    fi

    # Handle existing target
    if [[ -L "$target" ]]; then
        local current_target
        current_target=$(readlink "$target")
        if [[ "$current_target" == "$source" ]]; then
            print_status "$name symlink already correct"
            return 0
        fi
        print_warning "$name already exists as symlink, removing..."
        rm "$target"
    elif [[ -f "$target" ]] || [[ -d "$target" ]]; then
        if [[ -n "$backup_dir" ]]; then
            if [[ -f "$target" ]]; then
                backup_file "$target" "$backup_dir" "$(basename "$target")" || return 1
            else
                backup_directory "$target" "$backup_dir" "$(basename "$target")" || return 1
            fi
        else
            print_warning "$name already exists, creating backup..."
            local backup_name
            backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target" "$backup_name" || {
                print_error "Failed to backup existing $name"
                return 1
            }
        fi
    fi

    # Create target directory if needed
    local target_dir
    target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir" || {
            print_error "Failed to create target directory: $target_dir"
            return 1
        }
    fi

    # Create symlink
    if ! ln -s "$source" "$target"; then
        print_error "Failed to create symlink: $target -> $source"
        return 1
    fi

    print_success "$name symlink created: $target -> $source"
    return 0
}

create_symlink_with_backup() {
    local source="$1"
    local target="$2"
    local name="$3"
    local backup_dir="$4"

    create_symlink "$source" "$target" "$name" "$backup_dir"
}

# =============================================================================
# Git Functions
# =============================================================================

check_git_changes() {
    local file="$1"
    local git_dir="$2"

    if [[ ! -f "$file" ]]; then
        return 1  # File doesn't exist
    fi

    # Check if file is tracked by git
    if ! git -C "$git_dir" ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        return 1  # File not tracked
    fi

    # Check if file has meaningful changes
    if git -C "$git_dir" diff --quiet "$file" 2>/dev/null; then
        return 1  # No changes
    fi

    # Check if changes are only whitespace
    local diff_output
    diff_output=$(git -C "$git_dir" diff --ignore-space-change --ignore-blank-lines "$file" 2>/dev/null)
    if [[ -z "$diff_output" ]]; then
        return 2  # Only whitespace changes
    fi

    return 0  # Has meaningful changes
}

restore_git_file_if_no_changes() {
    local file="$1"
    local git_dir="$2"

    check_git_changes "$file" "$git_dir"
    local result=$?

    case $result in
        2)  # Only whitespace changes
            print_status "No meaningful changes in $(basename "$file"), restoring..."
            git -C "$git_dir" restore "$file" 2>/dev/null || true
            return 0
            ;;
        1)  # No changes or not tracked
            return 1
            ;;
        0)  # Has meaningful changes
            return 1
            ;;
    esac
}

# =============================================================================
# File Generation Functions
# =============================================================================

generate_file_from_template() {
    local template_file="$1"
    local output_file="$2"
    local substitutions="$3"  # Associative array name

    if [[ ! -f "$template_file" ]]; then
        print_error "Template file not found: $template_file"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    cp "$template_file" "$temp_file"

    # Apply substitutions if provided
    if [[ -n "$substitutions" ]]; then
        local -n subs_ref="$substitutions"
        for key in "${!subs_ref[@]}"; do
            sed -i.bak "s|{{$key}}|${subs_ref[$key]}|g" "$temp_file"
        done
        rm -f "$temp_file.bak"
    fi

    mv "$temp_file" "$output_file"
    print_status "Generated $(basename "$output_file") from template"
}

concatenate_files() {
    local output_file="$1"
    shift
    local input_files=("$@")

    for file in "${input_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Input file not found: $file"
            return 1
        fi
    done

    cat "${input_files[@]}" > "$output_file"
    print_status "Generated $(basename "$output_file") from ${#input_files[@]} files"
}

concatenate_files_with_shebang() {
    local output_file="$1"
    local shebang="$2"
    shift 2
    local input_files=("$@")

    for file in "${input_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Input file not found: $file"
            return 1
        fi
    done

    # Write shebang first, then concatenate files
    echo "$shebang" > "$output_file"
    cat "${input_files[@]}" >> "$output_file"
    print_status "Generated $(basename "$output_file") with shebang from ${#input_files[@]} files"
}

# =============================================================================
# Directory Functions
# =============================================================================

ensure_directory() {
    local dir="$1"
    local mode="${2:-755}"

    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir"; then
            print_error "Failed to create directory: $dir"
            return 1
        fi
        chmod "$mode" "$dir"
        print_status "Created directory: $dir"
    fi
    return 0
}

# =============================================================================
# Error Handling
# =============================================================================

cleanup_on_error() {
    local temp_files=("$@")

    print_error "An error occurred, cleaning up..."
    for file in "${temp_files[@]}"; do
        if [[ -f "$file" ]] || [[ -d "$file" ]]; then
            rm -rf "$file"
            print_status "Cleaned up: $file"
        fi
    done
}

# Trap function for cleanup
setup_error_handling() {
    local temp_files=("$@")
    trap 'cleanup_on_error ${temp_files[*]}' ERR
}
