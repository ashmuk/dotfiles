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
├── shellfirst.zsh     # Zsh initialization script
├── aliases.common      # Common aliases (git, dir nav, etc.)
├── aliases.shell       # Shell-specific aliases (grep, ripgrep)
└── README_shell.md     # This documentation file
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
- Oh My Zsh specific configuration
- Plugin settings and theme configuration
- Oh My Zsh customizations

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

After installation, you can add shell-specific customizations to:
- `~/.bashrc` - Additional bash settings
- `~/.zshrc` - Additional zsh settings

The installed files are symlinks to the dotfiles repository, so changes to the source files will be reflected immediately.
