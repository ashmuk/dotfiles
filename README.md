# Dotfiles

A comprehensive dotfiles management system with modular configuration for shell environments and vim.

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repository-url> ~/dotfiles
cd ~/dotfiles

# Install all configurations
make install

# Check installation status
make status
```

## 📁 Project Structure

```
dotfiles/
├── Makefile                 # Main installation and management script
├── README.md               # This file
├── bashrc                  # Generated bash configuration file
├── zshrc                   # Generated zsh configuration file
├── _vimrc                  # Windows vim configuration
├── _gvimrc                 # Windows GUI vim configuration
├── vimrc.mac               # macOS-specific vim configuration
├── gvimrc.mac              # macOS-specific GUI vim configuration
├── ideavimrc.mac           # macOS-specific IdeaVim configuration
├── shell/                  # Shell configuration directory
│   ├── setup_shell.sh      # Shell installation script
│   ├── shell.common        # Common shell settings (bash/zsh)
│   ├── shell.bash          # Bash-specific configuration
│   ├── shell.zsh           # Zsh-specific configuration
│   ├── shell.ohmy.zsh      # Oh My Zsh specific configuration
│   ├── shellfirst.zsh     # Zsh initialization script
│   ├── aliases.common      # Universal aliases
│   ├── aliases.shell       # Shell-specific aliases
│   └── README_shell.md     # Shell configuration documentation
├── vim/                    # Vim configuration directory
│   ├── setup_vimrc.sh      # Vim installation script
│   ├── vimrc.common        # Common vim settings
│   ├── vimrc.gui           # GUI vim settings
│   ├── vimrc.terminal      # Terminal vim settings
│   ├── vimrc.idea          # IntelliJ IDEA vim settings
│   ├── mappings.common     # Common key mappings
│   └── README_vim.md       # Vim configuration documentation
├── git/                    # Git configuration directory
│   ├── setup_git.sh        # Git installation script
│   ├── gitconfig.common    # Common git settings and aliases
│   ├── gitignore.common    # Common gitignore patterns
│   ├── gitattributes.common # Common gitattributes patterns
│   └── README_git.md       # Git configuration documentation
├── config/                 # Application-specific configurations
│   └── cursor/             # Cursor IDE settings
│       └── user/
│           ├── keybindings.json
│           └── settings.json
├── etc/                    # Additional configuration files
│   ├── dircolors-solarized/ # Solarized color schemes
│   │   ├── dircolors.256dark
│   │   ├── dircolors.ansi-dark
│   │   ├── dircolors.ansi-light
│   │   └── dircolors.ansi-universal
│   └── mintty-colors-solarized/ # Mintty color schemes
│       ├── sol.dark
│       └── sol.light
├── vimfiles/               # Vim plugin files
│   ├── colors/             # Color schemes
│   │   └── solarized.vim
│   ├── autoload/           # Vim autoload functions
│   │   └── togglebg.vim
│   ├── bitmaps/            # Bitmap files
│   │   └── togglebg.png
│   ├── doc/                # Vim documentation
│   │   └── solarized.txt
│   └── tmp/                # Temporary files
└── backup/                 # Backup directory for existing files
```

## 🛠️ Available Commands

### Installation
- `make install` - Install all dotfiles (shell + vim)
- `make install-shell` - Install only shell configuration
- `make install-vim` - Install only vim configuration

### Management
- `make status` - Show status of installed dotfiles
- `make backup` - Create backup of existing dotfiles
- `make clean` - Remove installed dotfiles (with confirmation)
- `make update` - Update dotfiles from repository

### Development
- `make test` - Test shell configuration syntax
- `make info` - Show project information
- `make help` - Show all available commands

## 🎯 Features

### Shell Configuration
- **Multi-shell support**: Works with both bash and zsh
- **Environment-aware grep**: Prioritizes GNU grep over BSD grep
- **Comprehensive aliases**: Git shortcuts, directory navigation, multibyte character search
- **Utility functions**: Archive extraction, directory management
- **Modular design**: Common and shell-specific configurations

### Vim Configuration
- **Multiple environments**: GUI, terminal, IDE-specific settings
- **Solarized theme**: Consistent color scheme across environments
- **Custom mappings**: Optimized key bindings
- **Plugin management**: Organized plugin structure

### Multibyte Character Search
- **File names**: Find files with multibyte characters in names
- **Content search**: Grep and ripgrep-based multibyte character detection
- **Language-specific**: CJK and Extended Latin character detection
- **Reduced false positives**: Improved regex patterns

## 🔧 Customization

### Shell Customization
After installation, add shell-specific customizations to:
- `~/.bashrc` - Additional bash settings
- `~/.zshrc` - Additional zsh settings

### Vim Customization
Add vim-specific customizations to:
- `~/.vimrc` - Additional vim settings
- `~/_vimrc` - Windows vim settings
- `~/_gvimrc` - Windows GUI vim settings

## 📋 Installation Details

### Shell Configuration
The shell setup creates symlinks to:
- `~/.bashrc` → Sources shell.common and shell.bash
- `~/.zshrc` → Sources shell.common and shell.zsh
- `~/shell.common` → Common shell settings
- `~/shell.bash` → Bash-specific settings
- `~/shell.zsh` → Zsh-specific settings
- `~/aliases.common` → Universal aliases
- `~/aliases.shell` → Shell-specific aliases

### Vim Configuration
The vim setup creates symlinks to:
- `~/.vimrc` → Main vim configuration
- `~/_vimrc` → Windows vim configuration
- `~/_gvimrc` → Windows GUI vim configuration
- `~/vimrc.*` → Environment-specific configurations
- `~/mappings.common` → Common key mappings

## 🔄 Updating

```bash
# Update from repository
make update

# Reinstall configurations
make install
```

## 🗑️ Uninstalling

```bash
# Remove all installed dotfiles
make clean
```

## 📚 Documentation

- [Shell Configuration](shell/README.md) - Detailed shell setup documentation
- [Vim Configuration](vim/README.md) - Detailed vim setup documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make test`
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
