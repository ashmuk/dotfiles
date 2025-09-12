#
# Windows PowerShell Orchestration Script for WSL Integration
# This script orchestrates dotfiles setup from Windows to WSL
# Layout: dotfiles in %USERPROFILE%\dotfiles as primary location
#

param(
    [switch]$SetupWSL = $false,
    [switch]$Force = $false,
    [string]$WSLDistro = ""
)

# Colors for output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue
$White = [System.ConsoleColor]::White

function Write-ColoredOutput {
    param(
        [string]$Message,
        [System.ConsoleColor]$Color = $White
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-WSLAvailable {
    try {
        $wslInfo = wsl --list --quiet 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Get-WSLDistributions {
    try {
        $distros = wsl --list --quiet | Where-Object { $_ -and $_.Trim() -ne "" }
        return $distros | ForEach-Object { $_.Trim() }
    }
    catch {
        return @()
    }
}

function Test-DotfilesInWindows {
    $windowsDotfiles = "$env:USERPROFILE\dotfiles"
    return Test-Path $windowsDotfiles
}

function New-WSLSymlinkToDotfiles {
    param(
        [string]$DistroName
    )
    
    Write-ColoredOutput "[INFO] Creating WSL symlink to Windows dotfiles..." $Blue
    
    # Convert Windows path to WSL path
    $windowsDotfiles = "$env:USERPROFILE\dotfiles"
    $wslPath = "/mnt/c/Users/$env:USERNAME/dotfiles"
    
    # Check if WSL can access Windows path
    $testAccess = wsl -d $DistroName -- test -d $wslPath
    if ($LASTEXITCODE -ne 0) {
        Write-ColoredOutput "[ERROR] WSL cannot access Windows dotfiles at: $wslPath" $Red
        Write-ColoredOutput "[INFO] Make sure WSL can access Windows filesystem" $Yellow
        return $false
    }
    
    # Create symlink in WSL home directory
    $commands = @(
        "if [ -e `$HOME/dotfiles ]; then",
        "  if [ -L `$HOME/dotfiles ]; then",
        "    echo 'Symlink already exists'",
        "  else",
        "    echo 'Directory exists but is not a symlink'",
        "    if [ '$Force' = 'true' ]; then",
        "      rm -rf `$HOME/dotfiles",
        "      ln -sf '$wslPath' `$HOME/dotfiles",
        "      echo 'Forced creation of symlink'",
        "    else",
        "      echo 'Use -Force to replace existing directory'",
        "      exit 1",
        "    fi",
        "  fi",
        "else",
        "  ln -sf '$wslPath' `$HOME/dotfiles",
        "  echo 'Created symlink to Windows dotfiles'",
        "fi"
    )
    
    $scriptBlock = $commands -join "; "
    $forceParam = if ($Force) { "true" } else { "false" }
    $fullCommand = $scriptBlock -replace '\$Force', $forceParam
    
    wsl -d $DistroName -- bash -c $fullCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredOutput "[SUCCESS] WSL symlink created successfully" $Green
        return $true
    } else {
        Write-ColoredOutput "[ERROR] Failed to create WSL symlink" $Red
        return $false
    }
}

function Install-WSLDotfiles {
    param(
        [string]$DistroName
    )
    
    Write-ColoredOutput "[INFO] Installing dotfiles in WSL ($DistroName)..." $Blue
    
    # Check prerequisites in WSL
    Write-ColoredOutput "[INFO] Checking WSL prerequisites..." $Blue
    wsl -d $DistroName -- bash -c "cd ~/dotfiles && make check-prereqs"
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColoredOutput "[WARNING] Prerequisites check failed. Continuing anyway..." $Yellow
    }
    
    # Install shell configuration
    Write-ColoredOutput "[INFO] Installing shell configuration in WSL..." $Blue
    wsl -d $DistroName -- bash -c "cd ~/dotfiles && make install-shell"
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredOutput "[SUCCESS] WSL shell configuration installed" $Green
    } else {
        Write-ColoredOutput "[ERROR] Failed to install WSL shell configuration" $Red
        return $false
    }
    
    # Install other components as needed
    Write-ColoredOutput "[INFO] Installing additional components..." $Blue
    wsl -d $DistroName -- bash -c "cd ~/dotfiles && make install-vim install-git"
    
    return $true
}

# Main execution
Write-ColoredOutput "==================================" $Blue
Write-ColoredOutput "Windows-WSL Dotfiles Orchestration" $Blue
Write-ColoredOutput "==================================" $Blue
Write-ColoredOutput ""

# Check if dotfiles exist in Windows location
if (-not (Test-DotfilesInWindows)) {
    Write-ColoredOutput "[ERROR] Dotfiles not found in %USERPROFILE%\dotfiles" $Red
    Write-ColoredOutput "[INFO] Please clone dotfiles to: $env:USERPROFILE\dotfiles" $Yellow
    Write-ColoredOutput "[INFO] Example: git clone <repo-url> `"$env:USERPROFILE\dotfiles`"" $Yellow
    exit 1
}

Write-ColoredOutput "[SUCCESS] Found dotfiles in Windows location" $Green

# Check WSL availability
if (-not (Test-WSLAvailable)) {
    Write-ColoredOutput "[WARNING] WSL not available or not installed" $Yellow
    if ($SetupWSL) {
        Write-ColoredOutput "[INFO] Please install WSL first using:" $Yellow
        Write-ColoredOutput "  wsl --install" $Yellow
        exit 1
    } else {
        Write-ColoredOutput "[INFO] Skipping WSL setup (use -SetupWSL to configure WSL)" $Yellow
        exit 0
    }
}

if ($SetupWSL) {
    # Get available WSL distributions
    $distros = Get-WSLDistributions
    
    if ($distros.Count -eq 0) {
        Write-ColoredOutput "[ERROR] No WSL distributions found" $Red
        Write-ColoredOutput "[INFO] Install a WSL distribution first:" $Yellow
        Write-ColoredOutput "  wsl --install -d Ubuntu" $Yellow
        exit 1
    }
    
    # Select distribution
    if ($WSLDistro -and ($distros -contains $WSLDistro)) {
        $selectedDistro = $WSLDistro
    } elseif ($distros.Count -eq 1) {
        $selectedDistro = $distros[0]
    } else {
        Write-ColoredOutput "[INFO] Available WSL distributions:" $Blue
        for ($i = 0; $i -lt $distros.Count; $i++) {
            Write-ColoredOutput "  [$i] $($distros[$i])" $White
        }
        Write-ColoredOutput ""
        $choice = Read-Host "Select distribution (0-$($distros.Count-1))"
        
        if ([int]::TryParse($choice, [ref]$null) -and [int]$choice -ge 0 -and [int]$choice -lt $distros.Count) {
            $selectedDistro = $distros[[int]$choice]
        } else {
            Write-ColoredOutput "[ERROR] Invalid selection" $Red
            exit 1
        }
    }
    
    Write-ColoredOutput "[INFO] Selected WSL distribution: $selectedDistro" $Blue
    
    # Create reverse symlink (WSL -> Windows)
    if (New-WSLSymlinkToDotfiles -DistroName $selectedDistro) {
        Write-ColoredOutput "[SUCCESS] WSL bridge created successfully" $Green
        
        # Install dotfiles in WSL
        Install-WSLDotfiles -DistroName $selectedDistro
    }
} else {
    Write-ColoredOutput "[INFO] Windows dotfiles ready. Use -SetupWSL to configure WSL integration." $Blue
}

Write-ColoredOutput ""
Write-ColoredOutput "[INFO] Next steps:" $Blue
Write-ColoredOutput "  1. Run Windows setup: .\setup_windows.ps1" $Yellow
Write-ColoredOutput "  2. Configure WSL: .\setup_wsl_orchestration.ps1 -SetupWSL" $Yellow
Write-ColoredOutput "  3. Both systems will share the same dotfiles!" $Green