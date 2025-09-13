# PowerShell script to install vim-plug on Windows
# This script ensures vim-plug is properly installed for Windows vim/gvim

$ErrorActionPreference = "Stop"

# Determine vim directory based on environment
if ($env:VIM) {
    $vimDir = $env:VIM
} elseif ($env:USERPROFILE) {
    $vimDir = Join-Path $env:USERPROFILE "vimfiles"
} else {
    $vimDir = Join-Path $env:HOME "vimfiles"
}

$autoloadDir = Join-Path $vimDir "autoload"
$plugFile = Join-Path $autoloadDir "plug.vim"
$plugUrl = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

Write-Host "Installing vim-plug for Windows..." -ForegroundColor Green
Write-Host "Target directory: $vimDir" -ForegroundColor Cyan

# Create autoload directory if it doesn't exist
if (!(Test-Path $autoloadDir)) {
    Write-Host "Creating autoload directory: $autoloadDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $autoloadDir -Force | Out-Null
}

# Download vim-plug
Write-Host "Downloading vim-plug from: $plugUrl" -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $plugUrl -OutFile $plugFile -UseBasicParsing
    Write-Host "✅ vim-plug installed successfully!" -ForegroundColor Green
    Write-Host "Location: $plugFile" -ForegroundColor Cyan
    
    # Verify installation
    if (Test-Path $plugFile) {
        $fileSize = (Get-Item $plugFile).Length
        Write-Host "File size: $fileSize bytes" -ForegroundColor Cyan
        
        if ($fileSize -gt 1000) {
            Write-Host "✅ Installation verified!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Yellow
            Write-Host "1. Open vim/gvim" -ForegroundColor White
            Write-Host "2. Run :PlugInstall to install plugins" -ForegroundColor White
            Write-Host "3. Restart vim/gvim to load plugins" -ForegroundColor White
        } else {
            Write-Host "⚠️  Warning: Downloaded file seems too small" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Failed to download vim-plug: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual installation:" -ForegroundColor Yellow
    Write-Host "1. Download from: $plugUrl" -ForegroundColor White
    Write-Host "2. Save to: $plugFile" -ForegroundColor White
    Write-Host "3. Create directory if needed: $autoloadDir" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "vim-plug installation completed!" -ForegroundColor Green
