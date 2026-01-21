# PowerShell Setup Script for Dotfiles on Windows
# This script sets up dotfiles configuration for native Windows PowerShell environments

param(
    [switch]$Force,
    [switch]$WhatIf,
    [string]$DotfilesPath = "$env:USERPROFILE\dotfiles"
)

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Status($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success($Message) {
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Validate environment
function Test-WindowsEnvironment {
    if (-not $IsWindows -and -not ($PSVersionTable.PSVersion.Major -le 5)) {
        Write-Error "This script is designed for Windows PowerShell environments"
        return $false
    }

    if (-not (Test-Path $DotfilesPath)) {
        Write-Error "Dotfiles directory not found: $DotfilesPath"
        return $false
    }

    return $true
}

# Create backup directory
function New-BackupDirectory($BackupType) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $DotfilesPath "backup" ".${BackupType}_backup_$timestamp"

    try {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-Status "Created backup directory: $backupDir"
        return $backupDir
    }
    catch {
        Write-Error "Failed to create backup directory: $backupDir"
        throw
    }
}

# Backup existing files
function Backup-ExistingFile($SourcePath, $BackupDir) {
    if (Test-Path $SourcePath) {
        $fileName = Split-Path $SourcePath -Leaf
        $backupPath = Join-Path $BackupDir $fileName

        try {
            Copy-Item $SourcePath $backupPath -Force
            Write-Status "Backed up $fileName to backup directory"
            return $true
        }
        catch {
            Write-Error "Failed to backup $fileName"
            throw
        }
    }
    return $false
}

# Create symbolic link with backup
function New-SymbolicLink($Source, $Target, $Name, $BackupDir) {
    if (-not (Test-Path $Source)) {
        Write-Error "Source file does not exist: $Source"
        return $false
    }

    # Handle existing target
    if (Test-Path $Target) {
        if ((Get-Item $Target).LinkType -eq "SymbolicLink") {
            $currentTarget = (Get-Item $Target).Target
            if ($currentTarget -eq $Source) {
                Write-Status "$Name symlink already correct"
                return $true
            }
            Write-Warning "$Name already exists as symlink, removing..."
            Remove-Item $Target -Force
        }
        else {
            if ($BackupDir) {
                Backup-ExistingFile $Target $BackupDir
            }
            else {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $backupPath = "${Target}.backup.$timestamp"
                Move-Item $Target $backupPath
                Write-Warning "Moved existing $Name to $backupPath"
            }
        }
    }

    # Create target directory if needed
    $targetDir = Split-Path $Target -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Create symbolic link
    try {
        if ($WhatIf) {
            Write-Host "What if: Would create symlink $Target -> $Source"
            return $true
        }

        New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force | Out-Null
        Write-Success "$Name symlink created: $Target -> $Source"
        return $true
    }
    catch {
        Write-Error "Failed to create symlink: $Target -> $Source"
        Write-Error $_.Exception.Message
        return $false
    }
}

# Setup PowerShell profile
function Setup-PowerShellProfile {
    Write-Status "Setting up PowerShell profile..."

    $backupDir = New-BackupDirectory "powershell"

    # PowerShell profiles for different hosts
    $profiles = @(
        @{
            Path = $PROFILE.CurrentUserAllHosts
            Name = "PowerShell Profile (All Hosts)"
            Source = Join-Path $DotfilesPath "windows" "Microsoft.PowerShell_profile.ps1"
        },
        @{
            Path = $PROFILE.CurrentUserCurrentHost
            Name = "PowerShell Profile (Current Host)"
            Source = Join-Path $DotfilesPath "windows" "Microsoft.PowerShell_profile_host.ps1"
        }
    )

    foreach ($profile in $profiles) {
        if (Test-Path $profile.Source) {
            New-SymbolicLink $profile.Source $profile.Path $profile.Name $backupDir
        }
        else {
            Write-Warning "Profile source not found: $($profile.Source)"
        }
    }
}

# Setup Windows Terminal configuration
function Setup-WindowsTerminal {
    Write-Status "Setting up Windows Terminal configuration..."

    $backupDir = New-BackupDirectory "terminal"

    # Windows Terminal settings
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $wtSourcePath = Join-Path $DotfilesPath "windows" "terminal" "settings.json"

    if (Test-Path $wtSourcePath) {
        New-SymbolicLink $wtSourcePath $wtSettingsPath "Windows Terminal Settings" $backupDir
    }
    else {
        Write-Warning "Windows Terminal settings source not found: $wtSourcePath"
    }

    # Windows Terminal themes (if directory exists)
    $wtThemesDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\themes"
    $wtThemesSource = Join-Path $DotfilesPath "windows" "terminal" "themes"

    if (Test-Path $wtThemesSource) {
        New-SymbolicLink $wtThemesSource $wtThemesDir "Windows Terminal Themes" $backupDir
    }
}

# Setup Git configuration for Windows
function Setup-GitWindows {
    Write-Status "Setting up Git configuration for Windows..."

    $backupDir = New-BackupDirectory "git_windows"

    # Git configuration files
    $gitConfigs = @(
        @{
            Source = Join-Path $DotfilesPath "git" "gitconfig.common"
            Target = "$env:USERPROFILE\.gitconfig"
            Name = "Git Config"
        },
        @{
            Source = Join-Path $DotfilesPath "git" "gitignore.common"
            Target = "$env:USERPROFILE\.gitignore"
            Name = "Git Ignore"
        },
        @{
            Source = Join-Path $DotfilesPath "git" "gitattributes.common"
            Target = "$env:USERPROFILE\.gitattributes"
            Name = "Git Attributes"
        }
    )

    foreach ($config in $gitConfigs) {
        if (Test-Path $config.Source) {
            New-SymbolicLink $config.Source $config.Target $config.Name $backupDir
        }
        else {
            Write-Warning "Git config source not found: $($config.Source)"
        }
    }
}

# Setup Vim configuration for Windows
function Setup-VimWindows {
    Write-Status "Setting up Vim configuration for Windows..."

    $backupDir = New-BackupDirectory "vim_windows"

    # Vim configuration files (use generated configs from vim/setup_vimrc.sh)
    $vimConfigs = @(
        @{
            Source = Join-Path $DotfilesPath "vimrc.generated"
            Target = "$env:USERPROFILE\_vimrc"
            Name = "Vim Config"
        },
        @{
            Source = Join-Path $DotfilesPath "gvimrc.generated"
            Target = "$env:USERPROFILE\_gvimrc"
            Name = "GVim Config"
        },
        @{
            Source = Join-Path $DotfilesPath "ideavimrc.generated"
            Target = "$env:USERPROFILE\_ideavimrc"
            Name = "IdeaVim Config"
        }
    )

    foreach ($config in $vimConfigs) {
        if (Test-Path $config.Source) {
            New-SymbolicLink $config.Source $config.Target $config.Name $backupDir
        }
        else {
            Write-Warning "Vim config source not found: $($config.Source)"
        }
    }

    # Vim runtime directory
    $vimRuntimeSource = Join-Path $DotfilesPath "vim" "vimfiles"
    $vimRuntimeTarget = "$env:USERPROFILE\vimfiles"

    if (Test-Path $vimRuntimeSource) {
        New-SymbolicLink $vimRuntimeSource $vimRuntimeTarget "Vim Runtime" $backupDir
    }
}

# Main setup function
function Start-DotfilesSetup {
    Write-Status "Starting Windows dotfiles setup..."
    Write-Status "Dotfiles directory: $DotfilesPath"

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    try {
        # Check if running as administrator for symbolic links
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $isAdmin) {
            Write-Warning "Not running as administrator. Symbolic links may fail on older Windows versions."
            Write-Status "Consider running as administrator or enabling Developer Mode in Windows Settings."
        }

        Setup-PowerShellProfile
        Setup-WindowsTerminal
        Setup-GitWindows
        Setup-VimWindows

        Write-Success "Windows dotfiles setup completed!"
        Write-Status ""
        Write-Status "Configuration files have been symlinked."
        Write-Status "Restart PowerShell and Windows Terminal to apply changes."

        if (-not $isAdmin) {
            Write-Status ""
            Write-Status "Note: If symbolic links failed, try:"
            Write-Status "1. Run PowerShell as Administrator"
            Write-Status "2. Enable Developer Mode in Windows Settings"
            Write-Status "3. Use 'git config --global core.symlinks true' for Git repos"
        }
    }
    catch {
        Write-Error "Setup failed: $($_.Exception.Message)"
        exit 1
    }
}

# Show help
function Show-Help {
    Write-Host @"
Windows Dotfiles Setup Script

USAGE:
    .\setup_windows.ps1 [OPTIONS]

OPTIONS:
    -Force              Overwrite existing configurations without prompting
    -WhatIf            Show what would be done without making changes
    -DotfilesPath PATH  Specify custom dotfiles directory (default: $env:USERPROFILE\dotfiles)
    -Help              Show this help message

EXAMPLES:
    .\setup_windows.ps1
    .\setup_windows.ps1 -WhatIf
    .\setup_windows.ps1 -Force -DotfilesPath "C:\MyDotfiles"

REQUIREMENTS:
    - Windows 10/11 or Windows PowerShell 5.1+
    - Dotfiles repository cloned to specified directory
    - Administrator privileges recommended for symbolic links

"@
}

# Main execution
if ($args -contains '-Help' -or $args -contains '--help' -or $args -contains '/?') {
    Show-Help
    exit 0
}

Start-DotfilesSetup
