# Requirements

This document describes the requirements for installing and using these dotfiles.

## Minimum Version Requirements

| Tool | Minimum Version | Reason |
|------|-----------------|--------|
| **Bash** | 4.0+ | Associative arrays, improved `[[` syntax |
| **Git** | 2.23+ | `git restore` command, improved features |
| **Make** | 3.81+ | Pattern rules, `.PHONY` targets |

### Checking Versions

```bash
# Check Bash version
bash --version | head -1

# Check Git version
git --version

# Check Make version
make --version | head -1
```

## Tiered Tool Requirements

### Essential (Required)

These tools are required for installation. The installer will fail if they are missing.

| Tool | Purpose |
|------|---------|
| `make` | Build automation |
| `git` | Version control |
| `bash` | Shell scripting (4.0+) |
| `grep` | Text searching |
| `sed` | Text processing |
| `awk` | Text processing |

### Core (Recommended)

These tools are used by the dotfiles but will produce warnings if missing.

| Tool | Purpose |
|------|---------|
| `vim` | Text editor |
| `zsh` | Z shell |
| `curl` | HTTP client |
| `tar` | Archive handling |
| `find` | File searching |
| `tmux` | Terminal multiplexer |
| `jq` | JSON processing (required for Claude MCP merge) |

### Modern (Optional Enhancements)

These tools provide enhanced alternatives to traditional tools.

| Tool | Replaces | Purpose |
|------|----------|---------|
| `rg` (ripgrep) | `grep` | Fast text search |
| `fd` | `find` | Fast file search |
| `bat` | `cat` | Syntax highlighting |
| `fzf` | - | Fuzzy finder |
| `exa`/`eza` | `ls` | Enhanced directory listing |

### Development (Optional)

These tools enhance the development experience.

| Tool | Purpose |
|------|---------|
| `shellcheck` | Shell script linting |
| `jq` | JSON processing |
| `yq` | YAML processing |
| `tree` | Directory visualization |
| `htop`/`btop` | Process monitoring |

## Platform-Specific Installation

### macOS

```bash
# Install Homebrew first if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools
brew install make git bash grep

# Install core tools
brew install vim zsh curl tmux jq

# Install modern tools
brew install ripgrep fd bat fzf eza

# Install development tools
brew install shellcheck yq tree htop
```

**Note**: macOS ships with Bash 3.2. Install a newer version via Homebrew:
```bash
brew install bash
# Add to /etc/shells and optionally set as default
echo /opt/homebrew/bin/bash | sudo tee -a /etc/shells
```

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install essential tools
sudo apt install make git bash grep sed gawk

# Install core tools
sudo apt install vim zsh curl tar findutils tmux jq

# Install modern tools
sudo apt install ripgrep fd-find bat fzf

# Install development tools
sudo apt install shellcheck yq tree htop
```

**Note**: On Ubuntu, `fd` is installed as `fdfind`. Create an alias:
```bash
alias fd='fdfind'
```

### Alpine Linux

```bash
# Install essential tools
apk add make git bash grep sed gawk

# Install core tools
apk add vim zsh curl tar findutils tmux jq

# Install modern tools
apk add ripgrep fd bat fzf

# Install development tools
apk add shellcheck yq tree htop
```

**Important**: Alpine uses `ash` by default. These dotfiles require `bash`.

### Arch Linux

```bash
# Install essential tools
sudo pacman -S make git bash grep sed gawk

# Install core tools
sudo pacman -S vim zsh curl tar findutils tmux jq

# Install modern tools
sudo pacman -S ripgrep fd bat fzf eza

# Install development tools
sudo pacman -S shellcheck yq tree htop
```

### CentOS/RHEL/Fedora

```bash
# Fedora
sudo dnf install make git bash grep sed gawk
sudo dnf install vim zsh curl tar findutils tmux jq
sudo dnf install ripgrep fd-find bat fzf

# CentOS/RHEL (may require EPEL)
sudo yum install epel-release
sudo yum install make git bash grep sed gawk
sudo yum install vim zsh curl tar findutils tmux jq
```

### Windows (via Scoop)

```powershell
# Install Scoop package manager
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb get.scoop.sh | iex

# Install essential tools
scoop install make git

# Install core tools
scoop install vim curl jq

# Install modern tools
scoop install ripgrep fd bat fzf

# Install development tools
scoop install shellcheck yq tree
```

**Note**: Git for Windows includes bash, grep, sed, and awk.

### Windows Subsystem for Linux (WSL)

Follow the Ubuntu/Debian instructions above within your WSL distribution.

## Verification

After installation, verify your environment:

```bash
# Run the prerequisite check
make check-prereqs

# Validate the configuration
make validate
```

## Troubleshooting

### Bash Version Issues

If you encounter errors about associative arrays or other Bash 4+ features:

1. Check your Bash version: `bash --version`
2. If using macOS with old Bash, install newer version via Homebrew
3. Ensure the newer Bash is in your PATH before the system Bash

### Git Version Issues

If `git restore` is not available:

1. Check your Git version: `git --version`
2. Update Git to 2.23+ using your package manager
3. Alternative: use `git checkout --` for file restoration

### Missing jq for Claude MCP

The Claude configuration setup requires `jq` for merging MCP server configurations:

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Alpine
apk add jq
```
