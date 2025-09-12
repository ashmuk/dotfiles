# Windows-First Dotfiles Setup

This guide describes the Windows-first approach where dotfiles are cloned to `%USERPROFILE%\dotfiles` and then orchestrated to WSL.

## Overview

### Layout
```
Windows:  %USERPROFILE%\dotfiles (primary location)
WSL:      $HOME/dotfiles -> symlink to /mnt/c/Users/{username}/dotfiles
```

### Benefits
- **Windows as primary**: Dotfiles live natively on Windows filesystem
- **Better Windows performance**: No cross-filesystem access penalties
- **WSL integration**: Full access from WSL via symlink
- **Single source**: Both systems share the same files

## Quick Start

### 1. Clone to Windows
```powershell
# From Windows PowerShell
cd $env:USERPROFILE
git clone https://github.com/your-username/dotfiles.git
```

### 2. Install Windows Configuration
```powershell
cd $env:USERPROFILE\dotfiles\windows
.\setup_windows.ps1
```

### 3. Set Up WSL Integration
```powershell
# Orchestrate WSL setup from Windows
.\setup_wsl_orchestration.ps1 -SetupWSL
```

**OR** from within WSL:
```bash
# From WSL (after Windows setup)
make setup-windows-bridge
make install-shell install-vim install-git
```

## Detailed Workflow

### Prerequisites
- Windows 11 with WSL2 installed
- PowerShell 5.1+ or PowerShell Core
- WSL distribution (Ubuntu recommended)
- Git for Windows

### Step-by-Step Setup

#### 1. Windows Setup
```powershell
# Clone dotfiles to Windows user profile
git clone <your-repo> "$env:USERPROFILE\dotfiles"
cd "$env:USERPROFILE\dotfiles"

# Install Windows configuration
.\windows\setup_windows.ps1

# Verify installation
Get-ChildItem $PROFILE
```

#### 2. WSL Integration Options

**Option A: Automated from Windows**
```powershell
# Run orchestration script
.\windows\setup_wsl_orchestration.ps1 -SetupWSL

# Select WSL distribution when prompted
# Script will:
# - Create WSL symlink to Windows dotfiles
# - Install WSL prerequisites 
# - Configure shell, vim, git in WSL
```

**Option B: Manual from WSL**
```bash
# From WSL terminal
make setup-windows-bridge     # Create symlink
make check-prereqs            # Verify requirements
make install                  # Install everything
```

#### 3. Verification
```bash
# From WSL - verify symlink
ls -la ~/dotfiles
# Should show: dotfiles -> /mnt/c/Users/{username}/dotfiles

# Test configuration
source ~/.bashrc  # or ~/.zshrc
alias | head -10   # Should show dotfiles aliases
```

```powershell
# From Windows PowerShell
Test-Path $PROFILE
Get-Content $PROFILE | Select-Object -First 10
```

## Commands Reference

### Windows PowerShell
```powershell
# Orchestration script
.\setup_wsl_orchestration.ps1 -SetupWSL              # Full WSL setup
.\setup_wsl_orchestration.ps1 -SetupWSL -Force       # Force overwrite existing
.\setup_wsl_orchestration.ps1 -WSLDistro "Ubuntu"    # Specify distribution

# Regular Windows setup
.\setup_windows.ps1                                   # Install Windows config
```

### WSL/Linux
```bash
# Bridge management
make setup-windows-bridge     # Create WSL -> Windows symlink
make setup-wsl-bridge        # Create Windows -> WSL junction (other direction)

# Installation
make install                 # Full installation (auto-detects layout)
make install-windows         # Windows config (auto-detects bridge needed)
make check-prereqs          # Check requirements

# Testing
make test                   # Run all tests
make test-compat           # Test compatibility
```

## Troubleshooting

### Common Issues

**WSL can't access Windows dotfiles**
```bash
# Check if Windows path is accessible
ls /mnt/c/Users/$USER/dotfiles

# If not found, check Windows username
cmd.exe /c 'echo %USERNAME%'
```

**Symlink creation fails**
```bash
# Check existing dotfiles
ls -la ~/dotfiles

# Remove if needed (CAUTION: backup first)
rm ~/dotfiles  # Only if it's a broken symlink
```

**Permission issues**
```bash
# Check WSL can write to Windows filesystem
touch /mnt/c/Users/$USER/test.txt
rm /mnt/c/Users/$USER/test.txt
```

### File System Performance

**Windows-first advantages:**
- Native Windows file access (no WSL filesystem translation)
- Better performance for Windows tools (VS Code, etc.)
- Simpler backup/sync with Windows tools

**Considerations:**
- WSL access via `/mnt/c` has some performance overhead
- Line ending handling (configure Git properly)
- Case sensitivity differences

## Migration

### From WSL-first to Windows-first
```bash
# 1. From WSL: backup and move dotfiles
cp -r ~/dotfiles ~/dotfiles.backup
```

```powershell
# 2. From Windows: move to Windows filesystem
Move-Item "\\wsl$\Ubuntu\home\$env:USERNAME\dotfiles" "$env:USERPROFILE\dotfiles"
```

```bash
# 3. From WSL: create symlink
make setup-windows-bridge
```

### From Windows-first to WSL-first
```powershell
# 1. From Windows: backup dotfiles
Copy-Item "$env:USERPROFILE\dotfiles" "$env:USERPROFILE\dotfiles.backup" -Recurse
```

```bash
# 2. From WSL: copy to WSL filesystem
cp -r /mnt/c/Users/$USER/dotfiles ~/dotfiles

# 3. Create Windows junction
make setup-wsl-bridge
```

## Advanced Configuration

### Multiple WSL Distributions
```powershell
# Target specific distribution
.\setup_wsl_orchestration.ps1 -SetupWSL -WSLDistro "Ubuntu-20.04"
```

### Custom Paths
Edit `setup_wsl_orchestration.ps1` to customize:
- Windows dotfiles location
- WSL mount points
- Distribution selection logic

### Integration with Windows Tools
The Windows-first approach enables better integration with:
- Visual Studio Code (native file access)
- Windows Terminal (direct config access)
- Git for Windows (no WSL translation layer)
- Windows backup tools