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

# Check prerequisites
make check-prereqs
```

## 🔧 CLI Tool Requirements

This dotfiles system uses a comprehensive set of command-line tools across different categories:

### **Essential Tools (Required)**
Core tools needed for basic dotfiles functionality:
- `git` - Version control and dotfiles management
- `make` - Build automation and primary interface
- `bash` - Shell scripting and cross-platform compatibility
- `grep` - Text searching in shell functions and aliases
- `sed` - Stream editing for text processing
- `awk` - Pattern scanning and text processing

### **Core Tools (Highly Recommended)**
Tools for full dotfiles experience:
- `vim` - Text editor (major component of this dotfiles)
- `zsh` - Enhanced shell with rich configuration
- `curl` - HTTP downloads and package installations
- `tar` - Archive handling for backups/restore
- `find` - File searching and dotfiles management

### **Modern Enhancement Tools (Optional but Valuable)**
Modern alternatives providing better functionality:
- `ripgrep` (`rg`) - Faster grep with better defaults
- `fd` - Faster find replacement with intuitive syntax
- `bat` - Enhanced cat with syntax highlighting
- `fzf` - Fuzzy finder for enhanced shell navigation
- `exa` - Modern ls replacement with better formatting

### **Development & Quality Tools (Optional)**
Tools that enhance the development experience:
- `shellcheck` - Shell script linting and validation
- `jq` - JSON processing and manipulation
- `yq` - YAML processing and manipulation
- `tree` - Directory tree visualization
- `htop`/`btop` - Enhanced process monitoring

### **Platform-Specific Notes**
- **macOS**: Install GNU versions via Homebrew (`ggrep`, `gsed`, `gawk`)
- **Windows**: Most tools available via Git for Windows + Scoop
- **Linux**: Standard GNU tools usually pre-installed

### **Quick Installation**

**macOS (Homebrew):**
```bash
# Essential + Core
brew install make git bash grep gnu-sed gawk vim zsh curl

# Modern enhancements
brew install ripgrep fd bat fzf exa

# Development tools
brew install shellcheck jq yq tree htop
```

**Windows (Scoop):**
```powershell
# Install Scoop first
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb get.scoop.sh | iex

# Essential + Core (many included with Git for Windows)
scoop install make vim zsh

# Modern enhancements
scoop install ripgrep fd bat fzf exa

# Development tools
scoop install shellcheck jq yq tree btop
```

**Linux (apt/Ubuntu):**
```bash
# Essential + Core
sudo apt update && sudo apt install make git bash grep sed gawk vim zsh curl tar findutils

# Modern enhancements (may need additional repos)
sudo apt install ripgrep fd-find bat fzf exa

# Development tools
sudo apt install shellcheck jq tree htop
```

Run `make check-prereqs` to check which tools you have and get installation suggestions for your platform.

## ⚡ Quick Reference

| Command | Description |
|---------|-------------|
| `make install` | Install all dotfiles (shell + vim + git) |
| `make check-prereqs` | Check tools and show installation commands |
| `make install-fonts` | Install programming fonts for gvim |
| `make check-fonts` | Check font availability |
| `make test` | Run complete test suite |
| `make status` | Show installation status |
| `make clean` | Remove installed dotfiles |
| `make setup-wsl-bridge` | WSL-first: Create Windows junction |
| `make setup-windows-bridge` | Windows-first: Create WSL symlink |
| `make install-windows` | Install Windows PowerShell config |

**Platform-Specific Quick Start:**
- **macOS**: `brew install make git bash vim zsh ripgrep fd bat fzf`
- **Windows**: `scoop install make vim zsh ripgrep fd bat fzf exa`
- **Linux**: `sudo apt install make git bash vim zsh ripgrep fd-find bat`

## 📁 Project Structure

```
dotfiles/
├── Makefile                 # Main installation and management script
├── README.md               # This file
├── bashrc.generated         # Generated bash configuration file (universal)
├── zshrc.generated          # Generated zsh configuration file (universal)
├── vimrc.generated         # Generated vim configuration (universal)
├── gvimrc.generated        # Generated GUI vim configuration (universal)
├── ideavimrc.generated     # Generated IdeaVim configuration (universal)
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
- **Multi-shell support**: Works with both bash and zsh with complete profile coverage
- **Environment-aware tools**: Prioritizes GNU grep over BSD grep, intelligent tool detection
- **Comprehensive aliases**: Git shortcuts, directory navigation, multibyte character search
- **Smart utility functions**: Archive extraction, directory management, enhanced gvim integration
- **Modular design**: Common and shell-specific configurations with local customization support
- **Performance monitoring**: Built-in shell startup performance tracking with lazy-loading
- **Complete profile system**: Enhanced bash_profile, zprofile, zlogout with consistent structure
- **ShellCheck compliance**: All shell code passes static analysis for best practices
- **Cross-platform compatibility**: Comprehensive support for macOS, Linux, WSL, and Windows
- **Modern tool integration**: Native support for ripgrep, fd, bat, fzf, and other modern CLI tools

### Vim Configuration
- **Multiple environments**: GUI, terminal, IDE-specific settings
- **Solarized theme**: Consistent color scheme across environments
- **Custom mappings**: Optimized key bindings
- **Plugin ecosystem**: vim-plug integration with curated essential plugins
- **Git integration**: vim-fugitive for advanced git operations
- **Enhanced completion**: Improved TAB completion and command-line completion
- **Smart Windows integration**: Dynamic gvim detection with .msi prioritization over Scoop
- **Universal configurations**: Consolidated .generated files with built-in platform detection eliminate duplication

### Windows & WSL Integration
- **Dual workflow support**: Windows-first and WSL-first approaches
- **Intelligent path detection**: Automatic Windows Vim installation discovery
- **Scoop package manager**: Native support with smart tool mapping
- **PowerShell orchestration**: Automated WSL setup from Windows
- **Seamless file sharing**: Symlinks and junctions for unified dotfiles access
- **Cross-environment compatibility**: Works in WSL, MSYS2, Cygwin, and native Windows

### Advanced CLI Tool Management
- **Tiered tool categorization**: Essential, Core, Modern, and Development tools
- **Automated prerequisite checking**: `make check-prereqs` with platform-specific suggestions
- **Intelligent package mapping**: Tool name mapping across different package managers
- **Cross-platform installation**: Homebrew, Scoop, apt, yum, pacman support
- **Modern tool adoption**: First-class support for ripgrep, fd, bat, fzf, exa
- **Development workflow**: Integrated shellcheck, jq, yq, tree, htop support

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

**Note**: Generated files are universal with built-in platform detection, eliminating the need for separate platform-specific versions.

### Vim Configuration
The vim setup creates symlinks to:
- `~/.vimrc` → Main vim configuration
- `~/_vimrc` → Windows vim configuration
- `~/_gvimrc` → Windows GUI vim configuration
- `~/vimrc.generated`, `~/gvimrc.generated`, `~/ideavimrc.generated` → Universal configurations with platform detection
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

#### Windows & Scoop Issues

**Issue**: Missing tools after installing via Scoop
```powershell
# Check if Scoop is in PATH
scoop --version

# Refresh PATH if needed
refreshenv

# Verify tool installation
scoop list | grep -E "vim|make|ripgrep"
```

**Issue**: gvim not finding Scoop-installed vim
```bash
# Check if function finds correct vim path
type gvim

# Manually verify Scoop vim location
ls /mnt/c/Users/$USER/scoop/apps/vim/*/gvim.exe
```

**Issue**: WSL bridge not working
```bash
# For Windows-first layout
ls -la ~/dotfiles  # should be symlink to /mnt/c/Users/username/dotfiles

# For WSL-first layout
ls -la "/mnt/c/Users/$USER/dotfiles"  # should be junction to WSL
```

**Issue**: PowerShell execution policy errors
```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set policy for current user
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Validation and Testing

Before reporting issues, run the validation checks:

```bash
# Check prerequisites and get installation suggestions
make check-prereqs

# Validate configuration and dependencies
make validate

# Run comprehensive test suite (syntax + shellcheck + compatibility)
make test

# Test individual components
make test-syntax      # Shell syntax only
make test-shellcheck  # ShellCheck analysis only
make test-compat      # Cross-platform compatibility only

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

# 2. Install essential tools (see CLI Tool Requirements section above)
scoop install make vim zsh
scoop install ripgrep fd bat fzf exa
scoop install shellcheck jq yq tree btop
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
