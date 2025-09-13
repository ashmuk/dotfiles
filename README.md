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
├── bashrc.generated        # Generated bash configuration file
├── zshrc.generated         # Generated zsh configuration file
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
│   ├── performance.sh      # Performance monitoring system
│   ├── aliases.common      # Universal aliases
│   ├── aliases.shell       # Shell-specific aliases
│   ├── local.example       # Example local customization file
│   ├── profile/            # Shell profile configurations
│   │   ├── ref/            # Reference comprehensive profiles
│   │   │   ├── bash_profile.comprehensive
│   │   │   ├── bashrc.comprehensive
│   │   │   ├── zprofile.comprehensive
│   │   │   └── zshrc.comprehensive
│   │   ├── bash_profile    # Existing bash profile
│   │   ├── zprofile        # Existing zsh profile
│   │   └── README_profile.md # Profile configuration documentation
│   ├── README_shell.md     # Shell configuration documentation
│   └── README_command.md   # Command reference documentation
├── vim/                    # Vim configuration directory
│   ├── setup_vimrc.sh      # Vim installation script
│   ├── vimrc.common        # Common vim settings
│   ├── vimrc.gui           # GUI vim settings
│   ├── vimrc.terminal      # Terminal vim settings
│   ├── vimrc.idea          # IntelliJ IDEA vim settings
│   ├── plugins.vim         # vim-plug plugin management
│   ├── mappings.common     # Common key mappings
│   ├── local.example.vim   # Example local vim customization
│   ├── README_vim.md       # Vim configuration documentation
│   └── vimfiles/           # Vim plugin files and data
│       ├── autoload/       # Vim autoload functions (vim-plug)
│       ├── plugged/        # Installed plugins (vim-fugitive, ale, etc.)
│       ├── colors/         # Color schemes (solarized)
│       ├── bitmaps/        # Bitmap files
│       └── doc/            # Plugin documentation
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
├── backup/                 # Backup directory for existing files
├── notes/                  # Project documentation and analysis
│   ├── claude_report_1500_20250912_before.md  # Pre-implementation analysis
│   └── claude_report_1700_20250912_after.md   # Post-implementation review
└── windows/               # Windows-specific configurations
    ├── Microsoft.PowerShell_profile.ps1  # PowerShell profile
    ├── setup_windows.ps1                 # Windows installation script
    ├── setup_wsl_orchestration.ps1       # Windows-first WSL orchestration
    └── README-WindowsFirst.md            # Windows-first workflow documentation
```

## 🛠️ Available Commands

### Installation
- `make install` - Install all dotfiles (shell + vim + git)
- `make install-shell` - Install only shell configuration
- `make install-vim` - Install only vim configuration
- `make install-git` - Install only git configuration
- `make install-windows` - Install Windows PowerShell configuration (from WSL)

### WSL/Windows Integration
- `make setup-wsl-bridge` - Create Windows junction (WSL-first layout)
- `make setup-windows-bridge` - Create WSL symlink (Windows-first layout)

### Management
- `make status` - Show status of installed dotfiles
- `make backup` - Create backup of existing dotfiles
- `make clean` - Remove installed dotfiles (with confirmation)
- `make update` - Update dotfiles from repository

### Development & Testing
- `make test` - Run comprehensive test suite (syntax, ShellCheck, compatibility)
- `make test-syntax` - Test shell configuration syntax only
- `make test-shellcheck` - Run ShellCheck static analysis
- `make test-compat` - Test platform compatibility
- `make check-prereqs` - Check required tools and dependencies
- `make info` - Show project information
- `make help` - Show all available commands

## 🎯 Features

### Shell Configuration
- **Multi-shell support**: Works with both bash and zsh
- **Environment-aware grep**: Prioritizes GNU grep over BSD grep
- **Comprehensive aliases**: Git shortcuts, directory navigation, multibyte character search
- **Utility functions**: Archive extraction, directory management
- **Modular design**: Common and shell-specific configurations
- **Performance monitoring**: Built-in shell startup performance tracking
- **Reference profiles**: Comprehensive bash/zsh profile configurations for advanced users
- **ShellCheck compliance**: All shell code passes static analysis for best practices
- **Cross-platform compatibility**: Tested on macOS, Linux, and WSL environments

### Vim Configuration
- **Multiple environments**: GUI, terminal, IDE-specific settings
- **Solarized theme**: Consistent color scheme across environments
- **Custom mappings**: Optimized key bindings
- **Plugin ecosystem**: vim-plug integration with curated essential plugins
- **Git integration**: vim-fugitive for advanced git operations
- **Enhanced completion**: Improved TAB completion and command-line completion

### Multibyte Character Search
- **File names**: Find files with multibyte characters in names
- **Content search**: Grep and ripgrep-based multibyte character detection
- **Language-specific**: CJK and Extended Latin character detection
- **Reduced false positives**: Improved regex patterns

## 🔧 Customization

The dotfiles system supports user-specific customizations without modifying the main configuration files.

### Shell Customization
Create a local configuration file in any of these locations (first found will be loaded):
- `$HOME/.dotfiles-local`
- `$HOME/.config/dotfiles/local` 
- `$HOME/dotfiles/shell/local`
- `$HOME/.dotfiles/shell/local`

Copy the example to get started:
```bash
cp ~/dotfiles/shell/local.example ~/.dotfiles-local
# Edit with your personal settings
vim ~/.dotfiles-local
```

### Vim Customization
Create a local vim configuration file in any of these locations:
- `~/.vim/local.vim` (Unix/macOS)
- `~/vimfiles/local.vim` (Windows)
- `~/.config/nvim/local.vim` (Neovim)
- `~/dotfiles/vim/local.vim`

Copy the example to get started:
```bash
cp ~/dotfiles/vim/local.example.vim ~/.vim/local.vim
# Edit with your personal vim settings
vim ~/.vim/local.vim
```

### Customization Features
- **Override any setting**: Personal configs are loaded last
- **Add custom aliases**: Define personal shortcuts and commands
- **Environment-specific settings**: Configure work vs. home environments
- **Plugin management**: Add personal vim plugins
- **Performance tuning**: Optimize for your specific setup

## 📋 Installation Details

### Shell Configuration
The shell setup creates symlinks to:
- `~/.bashrc` → Generated bash configuration (bashrc.generated)
- `~/.zshrc` → Generated zsh configuration (zshrc.generated)
- `~/.bash_logout` → Bash logout configuration
- `~/.bash_profile` → Bash profile configuration
- `~/.zprofile` → Zsh profile configuration
- `~/.zlogout` → Zsh logout configuration

Generated files combine modular components:
- `bashrc.generated` = `shell.common` + `shell.bash`
- `zshrc.generated` = `shell.common` + `shell.zsh` + `shell.ohmy.zsh`

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

## 🔧 Troubleshooting

### Common Issues

#### Installation Problems

**Issue**: Permission denied errors during installation
```bash
# Solution: Ensure scripts are executable
chmod +x shell/setup_shell.sh vim/setup_vimrc.sh git/setup_git.sh
```

**Issue**: Symlink creation fails
```bash
# Check if files already exist
ls -la ~/.bashrc ~/.zshrc ~/.vimrc

# If they exist as regular files, they will be automatically backed up
make install
```

#### Platform-Specific Issues

**macOS**: GNU tools not found
```bash
# Install GNU tools via Homebrew
brew install grep gnu-tar coreutils

# Tools will be automatically detected in PATH
```

**Windows (WSL/MSYS)**: Path issues
```bash
# Ensure you're using the correct shell environment
# For WSL, use the Linux shell, not Windows Command Prompt
# For MSYS, ensure MSYS2 is properly configured
```

**Linux**: Missing zsh or dependencies
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y zsh vim git

# CentOS/RHEL
sudo yum install -y zsh vim git
```

#### Configuration Issues

**Issue**: Aliases not working after installation
```bash
# Restart your terminal or reload configuration
source ~/.bashrc  # for bash
source ~/.zshrc   # for zsh
```

**Issue**: Vim plugins not loading
```bash
# Check vim plugin directory symlink
ls -la ~/.vim  # should point to ~/dotfiles/vim/vimfiles
ls -la ~/vimfiles  # Windows should point to ~/dotfiles/vim/vimfiles
```

**Issue**: Git configuration not applied
```bash
# Verify git configuration
git config --list | grep -E "user\.|core\."

# Reload git configuration
git config --reload
```

#### Environment Detection Issues

**Issue**: Wrong tools being used (BSD vs GNU)
```bash
# Check which tools are being detected
echo $grep_command
echo $du_command

# Install GNU tools if needed (macOS)
brew install grep coreutils

# Or manually set aliases in your local config
```

### Validation and Testing

Before reporting issues, run the validation checks:

```bash
# Validate configuration
make validate

# Test configuration syntax
make test

# Check installation status
make status
```

### Getting Help

1. Check the validation output: `make validate`
2. Review the troubleshooting section above
3. Check existing [GitHub Issues](https://github.com/your-username/dotfiles/issues)
4. Create a new issue with:
   - OS and shell version
   - Output of `make validate`
   - Specific error messages

## 🪟 Windows Support

This dotfiles system provides comprehensive Windows integration through two workflows:

### Windows-First Approach (Recommended)
**Layout**: `%USERPROFILE%\dotfiles` (primary) → WSL symlink
- Better Windows performance (native filesystem access)
- Seamless WSL integration via symlinks
- Single source of truth for both systems

#### Prerequisites
```powershell
# 1. Install Scoop package manager (recommended)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb get.scoop.sh | iex

# 2. Install essential tools
scoop install make ripgrep fd bat
```

#### Setup
```powershell
# 1. Clone to Windows (PowerShell)
git clone <repo-url> "$env:USERPROFILE\dotfiles"

# 2. Install Windows configuration
.\windows\setup_windows.ps1

# 3. Set up WSL integration
.\windows\setup_wsl_orchestration.ps1 -SetupWSL
```

### WSL-First Approach
**Layout**: `$HOME/dotfiles` (primary) → Windows junction
- Better for Linux-centric workflows
- Windows access via junction points

```bash
# From WSL after cloning to $HOME/dotfiles
make install-windows    # Creates Windows junction automatically
```

See [Windows-First Documentation](windows/README-WindowsFirst.md) for detailed setup instructions.

## 📚 Documentation

- [Shell Configuration](shell/README_shell.md) - Detailed shell setup documentation
- [Shell Profile Reference](shell/profile/README_profile.md) - Comprehensive shell profiles
- [Command Reference](shell/README_command.md) - Available shell commands and aliases
- [Vim Configuration](vim/README_vim.md) - Detailed vim setup documentation
- [Git Configuration](git/README_git.md) - Git setup and customization
- [Windows-First Workflow](windows/README-WindowsFirst.md) - Windows-first installation guide
- [Project Analysis](notes/) - Technical analysis and implementation reports

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make validate` and `make test`
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
