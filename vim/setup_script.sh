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
    
    local backup_dir="$HOME/.vim_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    for file in .vimrc .gvimrc .ideavimrc; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$backup_dir/"
            print_info "Backed up $file to $backup_dir"
        fi
    done
}

# シンボリックリンクの作成
create_symlinks() {
    print_info "Creating symlinks..."
    
    # .vimrc の作成
    cat > "$HOME/.vimrc" << 'EOF'
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
    cat > "$HOME/.gvimrc" << 'EOF'
" 共通設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.common'))
  source ~/dotfiles/vim/vimrc.common
endif

" GUI版専用設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.gui'))
  source ~/dotfiles/vim/vimrc.gui
endif
EOF

    # .ideavimrc の作成
    cat > "$HOME/.ideavimrc" << 'EOF'
" 共通設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.common'))
  source ~/dotfiles/vim/vimrc.common
endif

" IdeaVim専用設定を読み込み
if filereadable(expand('~/dotfiles/vim/vimrc.idea'))
  source ~/dotfiles/vim/vimrc.idea
endif
EOF

    print_success "Configuration files created"
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
    create_symlinks
    
    print_success "Vim configuration setup completed!"
    print_info "Restart your Vim/IDE to apply new settings"
}

# スクリプト実行
main "$@"