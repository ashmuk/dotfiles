#!/bin/bash
#
# Vim設定ファイル配置スクリプト
# macOS / Windows 対応
#

# dotfiles ディレクトリのパス
DOTFILES_DIR="$HOME/dotfiles"
VIM_DIR="$DOTFILES_DIR/vim"

# 色付きメッセージ用関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# ディレクトリ作成
create_directories() {
    print_info "Creating directories..."

    # vim一時ファイル用ディレクトリ（プラットフォーム対応）
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows
        mkdir -p "$HOME/vimfiles/tmp"
    else
        # macOS/Linux
        mkdir -p "$HOME/.vim/tmp"
    fi

    print_success "Directories created"
}

# 既存ファイルのバックアップ
backup_existing_files() {
    print_info "Backing up existing files..."

    local backup_dir="$HOME/dotfiles/backup/.vim_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup vim configuration files (platform-aware)
    if [[ "$PLATFORM" == "win" ]]; then
        # Windows-style filenames
        for file in _vimrc _gvimrc _ideavimrc; do
            if [[ -f "$HOME/$file" ]]; then
                cp "$HOME/$file" "$backup_dir/"
                print_info "Backed up $file to $backup_dir"
            fi
        done
    else
        # Unix-style filenames
        for file in .vimrc .gvimrc .ideavimrc; do
            if [[ -f "$HOME/$file" ]]; then
                cp "$HOME/$file" "$backup_dir/"
                print_info "Backed up $file to $backup_dir"
            fi
        done
    fi
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        vim_dir="$HOME/vimfiles"
    else
        vim_dir="$HOME/.vim"
    fi
    
    if [[ -d "$vim_dir" && ! -L "$vim_dir" ]]; then
        print_info "Backing up existing vim directory: $vim_dir"
        cp -r "$vim_dir" "$backup_dir/$(basename "$vim_dir")"
        print_info "Backed up $(basename "$vim_dir") to $backup_dir"
    fi
}

# プラットフォーム検出
detect_platform() {
    case "$OSTYPE" in
        darwin*)  echo "mac" ;;
        linux*)   echo "linux" ;;
        msys*|cygwin*) echo "win" ;;
        *)        echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
print_info "Detected platform: $PLATFORM"

# シンボリックリンクの作成
create_symlinks() {
    print_info "Creating Symbolic links in home directory..."

    # Windows では _vimrc, _gvimrc を使用
    if [[ "$PLATFORM" == "win" ]]; then
        ln -sf "$DOTFILES_DIR/vimrc.$PLATFORM" "$HOME/_vimrc"
        ln -sf "$DOTFILES_DIR/gvimrc.$PLATFORM" "$HOME/_gvimrc"
        ln -sf "$DOTFILES_DIR/ideavimrc.$PLATFORM" "$HOME/_ideavimrc"
        print_info "Created Windows-style symlinks: _vimrc, _gvimrc, _ideavimrc"
    else
        # Unix/macOS/Linux では .vimrc, .gvimrc を使用
        ln -sf "$DOTFILES_DIR/vimrc.$PLATFORM" "$HOME/.vimrc"
        ln -sf "$DOTFILES_DIR/gvimrc.$PLATFORM" "$HOME/.gvimrc"
        ln -sf "$DOTFILES_DIR/ideavimrc.$PLATFORM" "$HOME/.ideavimrc"
        print_info "Created Unix-style symlinks: .vimrc, .gvimrc, .ideavimrc"
    fi

    print_success "Symbolic links created in home directory"
}

# プラットフォーム対応ファイルの作成（dotfilesディレクトリ内）
create_platform_files() {
    print_info "Creating platform-dependent files in dotfiles root..."

    # .vimrc の作成
    cat > "$DOTFILES_DIR/vimrc.$PLATFORM" << 'EOF'
" 共通設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.common'))
  source ~/dotfiles/vim/vimrc.common
endif

" ターミナル版専用設定を読み込み
if !has('gui_running') && filereadable(expand('~/dotfiles/vim/vimrc.terminal'))
  source ~/dotfiles/vim/vimrc.terminal
endif

" プラットフォーム固有設定
if has('win32')
  " Windows固有設定
  set directory=$HOME/vimfiles/tmp
  set backupdir=$HOME/vimfiles/tmp
  set undodir=$HOME/vimfiles/tmp
else
  " macOS/Linux固有設定
  set directory=$HOME/.vim/tmp
  set backupdir=$HOME/.vim/tmp
  set undodir=$HOME/.vim/tmp
endif

" viminfo ファイルを無効化
set viminfo=

" ファイル形式設定（プラットフォーム対応）
if has('win32')
  set fileformat=dos
  set fileformats=dos,unix
else
  set fileformat=unix
  set fileformats=unix,dos
endif
EOF

    # .gvimrc の作成
    cat > "$DOTFILES_DIR/gvimrc.$PLATFORM" << 'EOF'
" 共通設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.common'))
  source ~/dotfiles/vim/vimrc.common
endif

" GUI版専用設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.gui'))
  source ~/dotfiles/vim/vimrc.gui
endif

" 共通キーマップを読み込み
if filereadable(expand('~/dotfiles/vim/mappings.common'))
  source ~/dotfiles/vim/mappings.common
endif
EOF

    # .ideavimrc の作成
    cat > "$DOTFILES_DIR/ideavimrc.$PLATFORM" << 'EOF'
" 共通設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.common'))
  source ~/dotfiles/vim/vimrc.common
endif

" IdeaVim専用設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.idea'))
  source ~/dotfiles/vim/vimrc.idea
endif

" 共通キーマップを読み込み
if filereadable(expand('~/dotfiles/vim/mappings.common'))
  source ~/dotfiles/vim/mappings.common
endif
EOF

    print_success "Configuration files created in dotfiles directory"
}

# Create vimfiles symlink (environment-aware)
create_vimfiles_symlink() {
    print_info "Setting up vim plugin directory symlink..."
    
    local vim_dir=""
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        vim_dir="$HOME/vimfiles"
    else
        vim_dir="$HOME/.vim"
    fi
    
    # If existing directory is a symlink pointing to our dotfiles, skip
    if [[ -L "$vim_dir" ]]; then
        local link_target=$(readlink "$vim_dir")
        if [[ "$link_target" == "$DOTFILES_DIR/vim/vimfiles" ]]; then
            print_info "Vim plugin directory already correctly symlinked"
            return 0
        else
            print_warning "Removing existing symlink: $vim_dir -> $link_target"
            rm "$vim_dir"
        fi
    fi
    
    # If existing directory exists, integrate content
    if [[ -d "$vim_dir" ]]; then
        print_info "Integrating existing vim directory content..."
        
        # Copy user content to dotfiles vim/vimfiles, avoiding conflicts
        local integration_needed=false
        
        for subdir in autoload colors pack ftplugin syntax plugin; do
            if [[ -d "$vim_dir/$subdir" ]]; then
                print_info "Found existing $subdir directory"
                if [[ ! -d "$DOTFILES_DIR/vim/vimfiles/$subdir" ]]; then
                    mkdir -p "$DOTFILES_DIR/vim/vimfiles/$subdir"
                fi
                
                # Copy files that don't conflict
                local files_copied=0
                for file in "$vim_dir/$subdir"/*; do
                    if [[ -f "$file" ]]; then
                        local filename=$(basename "$file")
                        local dest_file="$DOTFILES_DIR/vim/vimfiles/$subdir/$filename"
                        
                        if [[ ! -f "$dest_file" ]]; then
                            cp "$file" "$dest_file"
                            files_copied=$((files_copied + 1))
                            print_info "Integrated: $subdir/$filename"
                        else
                            print_warning "Skipped conflicting file: $subdir/$filename"
                        fi
                    fi
                done
                
                if [[ $files_copied -gt 0 ]]; then
                    integration_needed=true
                fi
            fi
        done
        
        # Preserve user's tmp directory structure
        if [[ -d "$vim_dir/tmp" && ! -d "$DOTFILES_DIR/vim/vimfiles/tmp" ]]; then
            mkdir -p "$DOTFILES_DIR/vim/vimfiles/tmp"
        fi
        
        # Remove old directory after integration
        print_info "Removing old vim directory: $vim_dir"
        rm -rf "$vim_dir"
        
        if [[ $integration_needed == true ]]; then
            print_success "Successfully integrated existing vim plugins and configurations"
        fi
    fi
    
    # Create the symlink
    print_info "Creating symlink: $vim_dir -> $DOTFILES_DIR/vim/vimfiles"
    ln -sf "$DOTFILES_DIR/vim/vimfiles" "$vim_dir"
    
    print_success "Vim plugin directory symlink created"
}

# Check and restore generated vim files if no actual changes
check_generated_vim_files() {
    print_info "Checking for actual changes in generated vim files..."
    
    local files_restored=0
    
    for file in "vimrc.$PLATFORM" "gvimrc.$PLATFORM" "ideavimrc.$PLATFORM"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            # Check if file is tracked by git and has changes
            if git -C "$DOTFILES_DIR" ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                # File is tracked, check for actual content differences
                if ! git -C "$DOTFILES_DIR" diff --quiet "$file" 2>/dev/null; then
                    # File has changes, check if they are meaningful
                    local temp_diff=$(git -C "$DOTFILES_DIR" diff --ignore-space-change --ignore-blank-lines "$file" 2>/dev/null)
                    if [[ -z "$temp_diff" ]]; then
                        # No meaningful differences, restore the file
                        print_info "No actual differences in $file, restoring..."
                        git -C "$DOTFILES_DIR" restore "$file" 2>/dev/null || true
                        files_restored=$((files_restored + 1))
                    fi
                fi
            fi
        fi
    done
    
    if [[ $files_restored -gt 0 ]]; then
        print_success "Restored $files_restored generated vim file(s) with no actual differences"
    else
        print_info "All generated vim files have meaningful changes or are unchanged"
    fi
}

# メイン処理
main() {
    print_info "Starting Vim configuration setup..."

    # dotfiles ディレクトリの確認
    if [[ ! -d "$VIM_DIR" ]]; then
        print_error "Vim dotfiles directory not found: $VIM_DIR"
        print_info "Please ensure your dotfiles are cloned to $DOTFILES_DIR"
        exit 1
    fi

    backup_existing_files
    create_directories
    create_platform_files
    check_generated_vim_files
    create_vimfiles_symlink
    create_symlinks

    print_success "Vim configuration setup completed!"
    print_info "Restart your Vim/IDE to apply new settings"
}

# スクリプト実行
main "$@"
