# Shell Configuration

This directory contains shell configuration files for bash and zsh, organized in a modular way similar to the vim configuration.

## File Structure

```
shell/
├── setup_shell.sh       # Installation script for shell configs
├── shell.common         # Common shell settings (bash/zsh)
├── shell.bash          # Bash-specific settings and functions
├── shell.zsh           # Zsh-specific settings and functions
├── shell.ohmy.zsh      # Oh My Zsh specific configuration
├── performance.sh      # Performance monitoring system
├── aliases.common      # Common aliases (git, dir nav, etc.)
├── aliases.shell       # Shell-specific aliases (grep, ripgrep)
├── local.example       # Example local customization file
├── profile/            # Shell profile configurations
│   ├── ref/            # Reference comprehensive profiles
│   │   ├── bash_profile.comprehensive
│   │   ├── bashrc.comprehensive
│   │   ├── zprofile.comprehensive
│   │   └── zshrc.comprehensive
│   ├── bash_profile    # Existing bash profile
│   ├── zprofile        # Existing zsh profile
│   ├── bash_logout     # Bash logout script
│   └── README_profile.md # Profile configuration documentation
├── README_shell.md     # This documentation file
└── README_command.md   # Command reference documentation
```

## Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles
make install

# Install only shell configuration
make install-shell

# Check status of installed files
make status
```

### Manual Installation
```bash
# Run the setup script
./shell/setup_shell.sh
```

## File Descriptions

### `shell.common`
- Basic shell settings (history, editor, language)
- Path configuration
- Grep command setup with GNU grep priority
- Sources common aliases

### `shell.bash`
- Bash-specific settings (completion, prompt)
- Bash history options
- Bash-specific functions (extract, mkcd)

### `shell.zsh`
- Zsh-specific settings (vi mode, options)
- Zsh history and directory stack options
- Zsh-specific functions (extract, mkcd, dh, j)

### `shell.ohmy.zsh`
- Oh My Zsh specific configuration (macOS only)
- Plugin settings and theme configuration
- Oh My Zsh customizations
- Automatically included only on macOS platforms

### `shellfirst.zsh`
- Zsh initialization script
- First-time setup configurations
- Initial environment setup

### `aliases.common`
- Universal aliases that work in both shells
- Git aliases (g, gs, ga, etc.)
- Directory navigation aliases (pu, pd, ds)
- Multibyte character search (findmbnames)

### `aliases.shell`
- Shell-specific aliases that depend on variables
- Grep-based multibyte search (grepmb, grepmbin)
- Ripgrep aliases (rgmb, rgmbin, rgcjk, rgextmb)
- Conditional loading based on tool availability

### `performance.sh`
- Shell startup performance monitoring system
- Timing measurement for shell initialization
- Performance analysis and optimization tools
- Optional profiling capabilities

### `local.example`
- Example local customization file
- Template for user-specific configurations
- Demonstrates common customization patterns
- Guidelines for personal shell settings

### `profile/` Directory
- **Reference profiles**: Comprehensive shell configurations for advanced users
- **Existing profiles**: Simple, lightweight profile configurations
- **Documentation**: Detailed setup and customization guides
- **Cross-platform**: Optimized for macOS, Linux, and Windows environments

## Features

### Multibyte Character Search
- **File names**: `findmbnames` - Find files with multibyte characters in names
- **Grep-based**: `grepmb`, `grepmbin` - Search content using GNU grep
- **Ripgrep-based**: `rgmb`, `rgmbin` - Search content using ripgrep
- **Language-specific**: `rgcjk`, `rgextmb` - Target specific character sets

### Git Aliases
- **Basic**: `g`, `gs`, `ga`, `gc`, `gp`, `gpl`
- **Branches**: `gb`, `gco`, `gcb`, `gm`
- **Log/Diff**: `gl`, `glo`, `gd`, `gds`
- **Remote**: `gr`, `grv`
- **Stash**: `gst`, `gstp`
- **Reset**: `grh`, `grhh`
- **Compound**: `gacp`, `gpom`, `gplom`
- **Pretty logs**: `glog`, `gloga`
- **Quick switches**: `gmain`, `gdev`

### Directory Navigation
- **Stack operations**: `pu` (pushd), `pd`/`po` (popd)
- **Directory listing**: `ds` (dirs -v)
- **Zsh-specific**: `dh` (dirs -v), `j <number>` (jump to dir by number)

### Utility Functions
- **extract**: Extract various archive formats
- **mkcd**: Create directory and cd into it

## Customization

### Local Customizations
Create local configuration files for personal settings:
- `$HOME/.dotfiles-local` - Primary local customization file
- `$HOME/.config/dotfiles/local` - Alternative location
- `$HOME/dotfiles/shell/local` - Repository-specific customizations

Use the example as a template:
```bash
cp shell/local.example ~/.dotfiles-local
vim ~/.dotfiles-local
```

### Shell-Specific Customizations
After installation, you can add shell-specific customizations to:
- `~/.bashrc` - Additional bash settings
- `~/.zshrc` - Additional zsh settings

### Advanced Profile Customizations
For comprehensive shell configurations, see:
- `profile/README_profile.md` - Detailed profile documentation
- `profile/ref/` - Reference implementations for advanced users
- Compare with generated configs for selective adoption

The installed files are symlinks to the dotfiles repository, so changes to the source files will be reflected immediately.

## Performance Monitoring

Enable performance monitoring to track shell startup times:
```bash
# Enable monitoring
export SHELL_PERFORMANCE_MONITOR=1

# View startup times
bash -l  # Shows loading time
zsh -l   # Shows loading time
```
