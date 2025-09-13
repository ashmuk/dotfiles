# Shell Profile Configurations

This directory contains comprehensive shell profile configurations for both Bash and Zsh, designed to work alongside your existing dotfiles system.

## 📁 File Overview

### Reference Configurations (`ref/`)
- **`bash_profile.comprehensive`** - Login shell configuration for Bash
- **`bashrc.comprehensive`** - Interactive shell configuration for Bash
- **`zprofile.comprehensive`** - Login shell configuration for Zsh
- **`zshrc.comprehensive`** - Interactive shell configuration for Zsh

### Existing Files
- **`bash_profile`** - Simple existing bash profile
- **`zprofile`** - Existing zsh profile with Homebrew setup
- **`bash_logout`** - Bash logout script
- **`zlogout`** - Zsh logout script

## 🚀 Features

### Cross-Platform Support
- **OS Detection**: Automatically detects macOS, Linux, Windows (MSYS/Cygwin)
- **Tool Adaptation**: Intelligent selection of GNU vs BSD tools
- **Path Management**: Platform-specific PATH configuration
- **Homebrew Integration**: Supports both Intel and Apple Silicon Macs

### Development Environment
- **Lazy Loading**: Improves startup time for nvm, rbenv, pyenv
- **Language Support**: Python, Node.js, Ruby, Go, Rust, Java
- **Modern Tools**: FZF, direnv, zoxide, starship integration
- **Package Managers**: Poetry, cargo, gem support

### Performance Optimization
- **Startup Monitoring**: Optional performance tracking
- **Caching System**: Intelligent caching for frequently accessed data
- **Lazy Initialization**: Deferred loading of expensive operations
- **Module Loading**: Optimized Zsh module loading

### Enhanced User Experience
- **Git Integration**: Intelligent git status in prompts
- **Smart Completion**: Enhanced tab completion for both shells
- **History Management**: Advanced history configuration
- **Syntax Highlighting**: Zsh syntax highlighting support
- **Auto-suggestions**: Zsh auto-suggestions integration

## 📋 Usage Examples

### Option 1: Replace Existing Profiles

```bash
# Backup existing profiles
cp ~/.bash_profile ~/.bash_profile.backup
cp ~/.zprofile ~/.zprofile.backup

# Link comprehensive profiles
ln -sf ~/dotfiles/shell/profile/ref/bash_profile.comprehensive ~/.bash_profile
ln -sf ~/dotfiles/shell/profile/ref/zprofile.comprehensive ~/.zprofile
```

### Option 2: Source from Existing Profiles

Add to your existing `~/.bash_profile`:
```bash
# Source comprehensive bash profile
if [[ -f ~/dotfiles/shell/profile/ref/bash_profile.comprehensive ]]; then
    source ~/dotfiles/shell/profile/ref/bash_profile.comprehensive
fi
```

Add to your existing `~/.zprofile`:
```bash
# Source comprehensive zsh profile  
if [[ -f ~/dotfiles/shell/profile/ref/zprofile.comprehensive ]]; then
    source ~/dotfiles/shell/profile/ref/zprofile.comprehensive
fi
```

### Option 3: Use as Reference

Compare with generated files:
```bash
# Compare bashrc configurations
diff ~/.bashrc ~/dotfiles/shell/profile/ref/bashrc.comprehensive

# Compare zshrc configurations  
diff ~/.zshrc ~/dotfiles/shell/profile/ref/zshrc.comprehensive
```

## ⚙️ Configuration Options

### Environment Variables

Set these variables to customize behavior:

```bash
# Performance monitoring
export SHELL_PERFORMANCE_MONITOR=1

# Quiet mode (disable welcome messages)
export DOTFILES_QUIET=1

# Use Starship prompt (Zsh only)
export USE_STARSHIP=1

# Dotfiles root directory
export DOTFILES_ROOT="$HOME/dotfiles"
```

### Local Customizations

Create local configuration files for personal customizations:

**Bash:**
- `~/.bash_profile.local`
- `~/.bashrc.local`
- `~/dotfiles/shell/profile/local.bash`

**Zsh:**
- `~/.zprofile.local`
- `~/.zshrc.local`
- `~/dotfiles/shell/profile/local.zsh`

## 🔧 Integration with Existing System

### Dotfiles Integration

These profiles are designed to work seamlessly with your existing dotfiles:

- Sources `shell/shell.common` for shared configuration
- Sources `shell/shell.bash` or `shell/shell.zsh` for shell-specific settings  
- Sources `shell/aliases.common` and `shell/aliases.shell` for aliases
- Integrates with `shell/performance.sh` monitoring system

### Backwards Compatibility

- Maintains compatibility with existing shell configurations
- Preserves existing environment variables and aliases
- Provides fallbacks for missing dependencies
- Respects existing customizations

## 🚦 Getting Started

1. **Test in a new shell session:**
   ```bash
   # Test Bash
   bash -l -c 'source ~/dotfiles/shell/profile/ref/bash_profile.comprehensive'
   
   # Test Zsh
   zsh -l -c 'source ~/dotfiles/shell/profile/ref/zprofile.comprehensive'
   ```

2. **Check performance:**
   ```bash
   SHELL_PERFORMANCE_MONITOR=1 bash -l
   SHELL_PERFORMANCE_MONITOR=1 zsh -l
   ```

3. **Gradually migrate:**
   ```bash
   # Start with sourcing comprehensive profiles
   echo 'source ~/dotfiles/shell/profile/ref/bash_profile.comprehensive' >> ~/.bash_profile
   echo 'source ~/dotfiles/shell/profile/ref/zprofile.comprehensive' >> ~/.zprofile
   ```

## 🛠️ Troubleshooting

### Common Issues

**Slow startup:**
- Enable performance monitoring: `SHELL_PERFORMANCE_MONITOR=1`
- Check for expensive operations in local customizations
- Consider lazy loading additional tools

**Command not found:**
- Verify PATH configuration in profile files
- Check that required tools are installed
- Review platform-specific sections

**Completion not working:**
- Ensure completion scripts are available
- Check completion initialization in comprehensive configs
- Verify shell options are set correctly

### Debug Mode

Enable verbose output for debugging:
```bash
# Bash debug mode
bash -x -l

# Zsh debug mode  
zsh -x -l
```

## 📝 Customization Examples

### Adding a Custom Prompt

Create `~/.bashrc.local`:
```bash
# Custom prompt with timestamp
PS1="[\t] \u@\h:\w\$ "
```

### Adding Development Tools

Create `~/dotfiles/shell/profile/local.zsh`:
```zsh
# Add custom development paths
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Custom aliases
alias myproject='cd ~/Projects/my-important-project'
```

## 🔗 See Also

- [`shell/README_shell.md`](../README_shell.md) - Main shell configuration documentation
- [`shell/performance.sh`](../performance.sh) - Performance monitoring system
- [`shell/aliases.common`](../aliases.common) - Common aliases
- [`vim/README_vim.md`](../../vim/README_vim.md) - Vim configuration documentation