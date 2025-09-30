# Vim Configuration

A comprehensive vim configuration system with environment-specific settings for terminal, GUI, and IDE environments.

## 📁 File Structure

```
vim/
├── setup_vimrc.sh      # Installation script for vim configurations
├── vimrc.common        # Common vim settings (all environments)
├── vimrc.gui           # GUI vim settings (GVim, MacVim)
├── vimrc.terminal      # Terminal vim settings
├── vimrc.idea          # IdeaVim settings (IntelliJ IDEA, PyCharm)
├── plugins.vim         # vim-plug plugin management configuration
├── mappings.common     # Common key mappings
├── local.example.vim   # Example local vim customization
├── README_vim.md       # This documentation file
└── vimfiles/           # Vim plugin files and data
    ├── autoload/       # Vim autoload functions (includes vim-plug)
    ├── plugged/        # Installed plugins directory
    │   ├── vim-fugitive/    # Git integration plugin
    │   ├── ale/            # Async linting engine
    │   ├── nerdtree/       # File explorer
    │   ├── vim-airline/    # Status line enhancement
    │   └── ...             # Other plugins
    ├── colors/         # Color schemes (solarized)
    ├── bitmaps/        # Bitmap files
    └── doc/            # Plugin documentation
```

## 🚀 Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles including vim
make install

# Install only vim configuration
make install-vim

# Install programming fonts for gvim (optional but recommended)
make install-fonts

# Check if fonts are installed
make check-fonts
```

### Manual Installation
```bash
# Run the vim setup script
./vim/setup_vimrc.sh

# Install fonts manually (cross-platform)
# Windows: powershell -ExecutionPolicy Bypass -File fonts/install_fonts.ps1
# macOS/Linux: bash fonts/install_fonts.sh
```

## 🎯 Configuration Files

### `vimrc.common`
**Universal settings for all vim environments**

- **Search behavior**: Case-insensitive search with smart case detection
- **Editing settings**: Tab expansion, auto-indentation, line wrapping
- **Display options**: Line numbers, syntax highlighting, status line
- **File handling**: Encoding, file format detection
- **Enhanced completion**: Improved TAB completion with wildmode and completeopt
- **Plugin integration**: Loads and configures vim-plug plugin manager
- **Performance**: Lazy loading, optimized settings

### `vimrc.gui`
**GUI-specific settings (GVim, MacVim)**

- **Color scheme**: Solarized theme with dark background
- **Font settings**: Platform-specific font configurations
- **Window settings**: Size, position, menu customization
- **GUI-specific features**: Toolbar, scrollbars, dialogs

### `vimrc.terminal`
**Terminal-specific settings**

- **Terminal compatibility**: Terminfo validation and correction
- **Color support**: 256-color terminal optimization
- **Terminal-specific features**: Mouse support, clipboard integration
- **Performance**: Optimized for terminal environments

### `vimrc.idea`
**IdeaVim-specific settings (IntelliJ IDEA, PyCharm)**

- **IDE integration**: Search highlighting, status indicators
- **IDE-specific features**: Join behavior, status icon colors
- **Compatibility**: Optimized for IDE environments
- **Customization**: IDE-specific color schemes

### `plugins.vim`
**vim-plug Plugin Management**

- **Essential plugins**: Curated selection of productivity-enhancing plugins
- **Git integration**: vim-fugitive for advanced git operations (`:Gdiffsplit`, `:Git status`)
- **File explorer**: NERDTree for directory navigation
- **Async linting**: ALE for real-time syntax checking
- **Status enhancement**: vim-airline for improved status line
- **Auto-installation**: Automatically installs vim-plug if not present
- **Cross-platform**: Handles Windows/Unix directory differences

### `mappings.common`
**Universal key mappings**

- **Search shortcuts**: Enhanced search behavior
- **Movement**: Screen-line aware navigation
- **Editing**: Efficient text manipulation
- **Git operations**: Quick access to vim-fugitive commands
- **Plugin shortcuts**: NERDTree toggle, FZF integration

## 🎨 Features

### Color Scheme
- **Solarized theme**: Consistent color scheme across all environments
- **Dark/Light modes**: Automatic background detection
- **Syntax highlighting**: Enhanced code readability
- **Search highlighting**: Clear search result indication

### Key Mappings
- **Enhanced search**: `*` searches forward and positions cursor at beginning
- **Clear highlights**: `ESC ESC` clears search highlighting
- **Screen-line movement**: `j`/`k` move by screen lines, `gj`/`gk` move by actual lines
- **Git operations**: `<leader>gs` (git status), `<leader>gd` (git diff), `<leader>gc` (git commit)
- **File navigation**: `<F2>` toggles NERDTree, `<leader>p` opens file finder
- **Plugin shortcuts**: `<leader>f` for ripgrep search, `<leader>b` for buffer list
- **EasyMotion**: `<leader><leader>w` (word), `<leader><leader>s` (2-char search), `<leader><leader>j/k` (line jump)

## 🔤 Font Management

The vim configuration includes intelligent font selection for gvim across all platforms.

### Automatic Font Selection

The system automatically detects and applies the best available programming font:

**Windows:**
- JetBrains Mono Nerd Font (preferred)
- Fira Code Nerd Font
- Cascadia Code PL
- Consolas (fallback)

**macOS:**
- JetBrains Mono Nerd Font (preferred)
- Fira Code Nerd Font
- Menlo (fallback)

**Linux:**
- JetBrains Mono Nerd Font (preferred)
- Fira Code Nerd Font
- DejaVu Sans Mono (fallback)

### Font Installation

```bash
# Install recommended programming fonts
make install-fonts

# Check current font availability
make check-fonts

# Font installation is also checked during prerequisite validation
make check-prereqs
```

### Manual Font Management

Fonts are managed through:
- **Installation scripts**: `fonts/install_fonts.ps1` (Windows), `fonts/install_fonts.sh` (macOS/Linux)
- **Auto-detection**: `vim/vimfiles/autoload/gui_font.vim`
- **Integration**: Automatically called from `vimrc.gui`

### CJK Support

The system includes wide font support for CJK characters:
- **Windows**: Yu Gothic UI
- **macOS**: Hiragino Sans
- **Linux**: Noto Sans CJK JP

### Plugin Ecosystem
- **vim-fugitive**: Complete git integration (`:Gdiffsplit`, `:Git status`, `:Git commit`)
- **NERDTree**: File explorer with customizable settings
- **vim-airline**: Enhanced status line with git branch info
- **ALE**: Async linting for real-time error checking
- **FZF**: Fuzzy file finder integration (if available)
- **Auto-pairs**: Automatic bracket/quote pairing
- **EasyMotion**: Lightning-fast cursor movement with minimal keystrokes

### Environment-Specific Optimizations
- **Terminal**: Optimized for terminal performance and compatibility
- **GUI**: Enhanced visual experience with fonts and colors
- **IDE**: Seamless integration with IntelliJ IDEA and PyCharm

## 🔧 Customization

### Adding Custom Settings

Create local configuration files for personal vim customizations:
- `~/.vim/local.vim` (Unix/macOS)
- `~/vimfiles/local.vim` (Windows)
- `~/.config/nvim/local.vim` (Neovim)
- `~/dotfiles/vim/local.vim`

Use the example as a template:
```bash
cp vim/local.example.vim ~/.vim/local.vim
vim ~/.vim/local.vim
```

### Plugin Customization
Add personal plugins to your local configuration:
```vim
" Add to ~/.vim/local.vim
Plug 'tpope/vim-commentary'    " Comment/uncomment shortcuts
Plug 'junegunn/fzf.vim'        " Enhanced fuzzy finding
```

### Global Settings Override
After installation, you can also add settings to:
- `~/.vimrc` - Additional vim settings
- `~/_vimrc` - Windows vim settings
- `~/_gvimrc` - Windows GUI vim settings

### Environment-Specific Customizations
- **Terminal**: Add to `~/.vimrc` or create `~/.vimrc.terminal`
- **GUI**: Add to `~/.vimrc` or create `~/.vimrc.gui`
- **IDE**: Add to `~/.vimrc` or create `~/.vimrc.idea`

## 📋 Installation Details

The vim setup creates symlinks to:
- `~/.vimrc` → Main vim configuration
- `~/_vimrc` → Windows vim configuration
- `~/_gvimrc` → Windows GUI vim configuration
- `~/vimrc.common` → Common vim settings
- `~/vimrc.gui` → GUI-specific settings
- `~/vimrc.terminal` → Terminal-specific settings
- `~/vimrc.idea` → IdeaVim-specific settings
- `~/mappings.common` → Common key mappings

## 🌍 Environment Support

### Terminal Vim
- **Linux/Unix**: Full support with 256-color optimization
- **macOS**: Terminal.app and iTerm2 support
- **Windows**: WSL, Git Bash, and native terminal support

### GUI Vim
- **GVim**: Linux/Windows GUI vim
- **MacVim**: macOS GUI vim
- **Cross-platform**: Consistent experience across platforms

### IDE Integration
- **IntelliJ IDEA**: Full IdeaVim support
- **PyCharm**: Complete vim emulation
- **Other JetBrains IDEs**: Compatible with IdeaVim plugin

## 🚀 Plugin Management

### vim-plug Integration
The configuration uses vim-plug for plugin management:

**Install plugins:**
```vim
:PlugInstall
```

**Update plugins:**
```vim
:PlugUpdate
```

**Clean unused plugins:**
```vim
:PlugClean
```

**Current plugin list:**
- **tpope/vim-sensible**: Sensible defaults
- **tpope/vim-fugitive**: Git wrapper (:Gdiffsplit support!)
- **tpope/vim-surround**: Surround text objects
- **tpope/vim-commentary**: Comment/uncomment shortcuts
- **tpope/vim-repeat**: Repeat plugin commands
- **preservim/nerdtree**: File tree explorer
- **vim-airline/vim-airline**: Status line enhancement
- **dense-analysis/ale**: Async linting engine
- **junegunn/fzf.vim**: Fuzzy finder integration
- **easymotion/vim-easymotion**: Quick cursor movement
- **jiangmiao/auto-pairs**: Auto-close brackets
- **godlygeek/tabular**: Text alignment

### Adding New Plugins
Add to your local vim configuration:
```vim
" In ~/.vim/local.vim
Plug 'your-username/your-plugin'
```

## 🚀 EasyMotion Quick Reference

EasyMotion provides lightning-fast cursor movement with visual feedback. All commands use `<leader><leader>` prefix (default leader is `\`, or space if configured).

### Basic Usage

1. Press the EasyMotion key combination
2. Type the target character(s)
3. Press the highlighted letter to jump

### Key Mappings

**Character Search:**
- `<leader><leader>s{char}{char}` - Search for 2 characters
- `<leader><leader>t{char}{char}` - Search till (before) 2 characters

**Word Movement:**
- `<leader><leader>w` - Jump to word forward
- `<leader><leader>b` - Jump to word backward
- `<leader><leader>e` - Jump to word end forward
- `<leader><leader>ge` - Jump to word end backward

**Line Movement:**
- `<leader><leader>j` - Jump to line below
- `<leader><leader>k` - Jump to line above
- `<leader><leader>l` - Jump forward in line
- `<leader><leader>h` - Jump backward in line

**Search Motion:**
- `<leader><leader>/` - EasyMotion search (like `/` but with jump labels)

**Repeat:**
- `<leader><leader>.` - Repeat last EasyMotion command

### Configuration

EasyMotion is configured with:
- **Smart case**: Case-insensitive by default, case-sensitive when using uppercase
- **Uppercase labels**: Uses uppercase letters for jump targets (easier to see)
- **Column preservation**: Keeps cursor column when using JK motions
- **Smart sign matching**: Matches similar characters (1 matches !, etc.)

## 🛠️ Advanced Configuration

### Color Scheme Customization
```vim
" Override color scheme
colorscheme solarized
set background=dark

" Custom colors
highlight Search ctermbg=yellow ctermfg=black
highlight IncSearch ctermbg=red ctermfg=white
```

### Key Mapping Customization
```vim
" Add custom mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
```

## 🔄 Updating

```bash
# Update vim configuration
make update
make install-vim
```

## 🗑️ Uninstalling

```bash
# Remove vim configuration
make clean
```

## 📚 Additional Resources

- [Vim Documentation](https://vimdoc.sourceforge.net/)
- [IdeaVim Plugin](https://plugins.jetbrains.com/plugin/164-ideavim)
- [Solarized Color Scheme](https://ethanschoonover.com/solarized/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in different environments
5. Submit a pull request

## 📄 License

This configuration is part of the dotfiles project and is available under the [MIT License](../LICENSE).
