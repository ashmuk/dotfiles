# Vim Configuration

A comprehensive vim configuration system with environment-specific settings for terminal, GUI, and IDE environments.

## 📁 File Structure

```
vim/
├── setup_script.sh     # Installation script for vim configurations
├── vimrc.common        # Common vim settings (all environments)
├── vimrc.gui           # GUI vim settings (GVim, MacVim)
├── vimrc.terminal      # Terminal vim settings
├── vimrc.idea          # IdeaVim settings (IntelliJ IDEA, PyCharm)
├── mappings.common     # Common key mappings
└── README_vim.md       # This documentation file
```

## 🚀 Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles including vim
make install

# Install only vim configuration
make install-vim
```

### Manual Installation
```bash
# Run the vim setup script
./vim/setup_script.sh
```

## 🎯 Configuration Files

### `vimrc.common`
**Universal settings for all vim environments**

- **Search behavior**: Case-insensitive search with smart case detection
- **Editing settings**: Tab expansion, auto-indentation, line wrapping
- **Display options**: Line numbers, syntax highlighting, status line
- **File handling**: Encoding, file format detection
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

### `mappings.common`
**Universal key mappings**

- **Search shortcuts**: Enhanced search behavior
- **Movement**: Screen-line aware navigation
- **Editing**: Efficient text manipulation
- **Utility**: Quick access to common functions

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
- **Efficient navigation**: Optimized cursor movement

### Environment-Specific Optimizations
- **Terminal**: Optimized for terminal performance and compatibility
- **GUI**: Enhanced visual experience with fonts and colors
- **IDE**: Seamless integration with IntelliJ IDEA and PyCharm

## 🔧 Customization

### Adding Custom Settings
After installation, you can add custom settings to:
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

## 🛠️ Advanced Configuration

### Plugin Management
The configuration is designed to work with popular plugin managers:
- **Vim-Plug**: Add plugins to `~/.vimrc`
- **Pathogen**: Place plugins in `~/.vim/bundle/`
- **Vundle**: Configure in `~/.vimrc`

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
