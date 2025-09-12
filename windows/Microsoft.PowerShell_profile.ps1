# PowerShell Profile for All Hosts
# This profile is loaded for all PowerShell hosts (console, ISE, VS Code, etc.)

# =============================================================================
# Environment Variables
# =============================================================================

# Add common paths
$env:PATH = "$env:USERPROFILE\bin;$env:LOCALAPPDATA\Programs\Git\bin;$env:PATH"

# Editor settings
$env:EDITOR = "code"
$env:VISUAL = "code"

# =============================================================================
# PowerShell Settings
# =============================================================================

# Set PSReadLine options for better command line experience
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    
    # Set command line editing options
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    
    # Key bindings
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    
    # Search history
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# =============================================================================
# Aliases - Basic Commands
# =============================================================================

# Directory navigation
Set-Alias -Name ll -Value Get-ChildItemColor -ErrorAction SilentlyContinue
Set-Alias -Name la -Value Get-ChildItemColorWide -ErrorAction SilentlyContinue
Set-Alias -Name .. -Value Set-LocationUp
Set-Alias -Name ... -Value Set-LocationUpUp
Set-Alias -Name .... -Value Set-LocationUpUpUp

# File operations
Set-Alias -Name touch -Value New-EmptyFile
Set-Alias -Name which -Value Get-CommandLocation

# Text processing
Set-Alias -Name grep -Value Select-String -ErrorAction SilentlyContinue

# =============================================================================
# Aliases - Git Commands
# =============================================================================

Set-Alias -Name g -Value git
Set-Alias -Name gs -Value git status
Set-Alias -Name ga -Value git add
Set-Alias -Name gc -Value git commit
Set-Alias -Name gp -Value git push
Set-Alias -Name gpl -Value git pull
Set-Alias -Name gb -Value git branch
Set-Alias -Name gco -Value git checkout
Set-Alias -Name gd -Value git diff
Set-Alias -Name gl -Value git log
Set-Alias -Name gst -Value git stash

# =============================================================================
# Functions - Directory Navigation
# =============================================================================

function Set-LocationUp { Set-Location .. }
function Set-LocationUpUp { Set-Location ..\.. }
function Set-LocationUpUpUp { Set-Location ..\..\.. }

function Get-DirectorySize {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Recurse -File | 
    Measure-Object -Property Length -Sum | 
    ForEach-Object {
        [PSCustomObject]@{
            Path = (Resolve-Path $Path).Path
            Size = "{0:N2} MB" -f ($_.Sum / 1MB)
            Files = $_.Count
        }
    }
}

# =============================================================================
# Functions - File Operations
# =============================================================================

function New-EmptyFile {
    param([Parameter(Mandatory=$true)][string]$Name)
    New-Item -ItemType File -Name $Name -Force
}

function Get-CommandLocation {
    param([Parameter(Mandatory=$true)][string]$Command)
    Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

function Find-Files {
    param(
        [Parameter(Mandatory=$true)][string]$Pattern,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Recurse -Filter $Pattern | Select-Object FullName
}

# =============================================================================
# Functions - System Information
# =============================================================================

function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        OSVersion = [System.Environment]::OSVersion.VersionString
        ProcessorCount = [System.Environment]::ProcessorCount
        TotalMemory = "{0:N2} GB" -f ((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        AvailableMemory = "{0:N2} GB" -f ((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB / 1024)
    }
}

function Get-DiskSpace {
    Get-CimInstance -ClassName Win32_LogicalDisk | 
    Where-Object { $_.DriveType -eq 3 } |
    Select-Object @{
        Name = 'Drive'
        Expression = { $_.DeviceID }
    }, @{
        Name = 'Size'
        Expression = { "{0:N2} GB" -f ($_.Size / 1GB) }
    }, @{
        Name = 'FreeSpace'
        Expression = { "{0:N2} GB" -f ($_.FreeSpace / 1GB) }
    }, @{
        Name = 'PercentFree'
        Expression = { "{0:N1}%" -f (($_.FreeSpace / $_.Size) * 100) }
    }
}

# =============================================================================
# Functions - Development Utilities
# =============================================================================

function Start-ElevatedSession {
    Start-Process powershell -Verb RunAs
}

function Get-PortProcesses {
    param([int]$Port)
    if ($Port) {
        netstat -ano | Where-Object { $_ -match ":$Port " }
    } else {
        netstat -ano | Where-Object { $_ -match "LISTENING" }
    }
}

function Test-Administrator {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# =============================================================================
# Functions - Dotfiles Management
# =============================================================================

function Update-DotFiles {
    $dotfilesPath = "$env:USERPROFILE\dotfiles"
    if (Test-Path $dotfilesPath) {
        Push-Location $dotfilesPath
        try {
            Write-Host "Updating dotfiles..." -ForegroundColor Blue
            git pull origin main
            Write-Host "Dotfiles updated!" -ForegroundColor Green
        }
        finally {
            Pop-Location
        }
    } else {
        Write-Host "Dotfiles directory not found: $dotfilesPath" -ForegroundColor Red
    }
}

function Edit-Profile {
    if ($env:EDITOR) {
        & $env:EDITOR $PROFILE
    } else {
        notepad $PROFILE
    }
}

# =============================================================================
# Enhanced Directory Listing (if Get-ChildItemColor module available)
# =============================================================================

if (Get-Module -ListAvailable Get-ChildItemColor -ErrorAction SilentlyContinue) {
    Import-Module Get-ChildItemColor -Force
    
    function Get-ChildItemColorWide {
        Get-ChildItemColor @args | Format-Wide -AutoSize
    }
} else {
    # Fallback functions if module not available
    function Get-ChildItemColor {
        Get-ChildItem @args
    }
    
    function Get-ChildItemColorWide {
        Get-ChildItem @args | Format-Wide -AutoSize
    }
}

# =============================================================================
# Prompt Customization
# =============================================================================

function prompt {
    $path = $PWD.ToString().Replace($env:USERPROFILE, "~")
    $gitBranch = ""
    
    # Get git branch if in a git repository
    if (Test-Path .git -ErrorAction SilentlyContinue) {
        try {
            $gitBranch = " (" + (git rev-parse --abbrev-ref HEAD 2>$null) + ")"
        } catch {
            # Ignore git errors
        }
    }
    
    $isAdmin = Test-Administrator
    $adminIndicator = if ($isAdmin) { " [ADMIN]" } else { "" }
    
    # Color the prompt based on admin status
    if ($isAdmin) {
        Write-Host "PS " -NoNewline -ForegroundColor Red
        Write-Host "$path" -NoNewline -ForegroundColor Yellow
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Green
        Write-Host "$adminIndicator" -NoNewline -ForegroundColor Red
    } else {
        Write-Host "PS " -NoNewline -ForegroundColor Blue
        Write-Host "$path" -NoNewline -ForegroundColor Green
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Cyan
    }
    
    return "> "
}

# =============================================================================
# Module Imports
# =============================================================================

# Import useful modules if available
$modulesToImport = @(
    "PSReadLine",
    "Get-ChildItemColor",
    "posh-git"
)

foreach ($module in $modulesToImport) {
    if (Get-Module -ListAvailable $module -ErrorAction SilentlyContinue) {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}

# =============================================================================
# Welcome Message
# =============================================================================

Write-Host "PowerShell Profile Loaded" -ForegroundColor Green
if (Test-Administrator) {
    Write-Host "Running as Administrator" -ForegroundColor Red
}

# Load host-specific profile if it exists
$hostProfile = $PROFILE.CurrentUserCurrentHost
if ((Test-Path $hostProfile) -and ($hostProfile -ne $PROFILE.CurrentUserAllHosts)) {
    . $hostProfile
}