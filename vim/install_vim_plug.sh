#!/usr/bin/env bash
# Bash script to install vim-plug on Windows (Git Bash/MSYS2/Cygwin)
# This script ensures vim-plug is properly installed for Windows vim/gvim

set -euo pipefail

# Determine vim directory based on environment
if [[ -n "${VIM:-}" ]]; then
    vim_dir="$VIM"
elif [[ -n "${USERPROFILE:-}" ]]; then
    vim_dir="$USERPROFILE/vimfiles"
else
    vim_dir="$HOME/vimfiles"
fi

autoload_dir="$vim_dir/autoload"
plug_file="$autoload_dir/plug.vim"
plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

echo "Installing vim-plug for Windows..."
echo "Target directory: $vim_dir"

# Create autoload directory if it doesn't exist
if [[ ! -d "$autoload_dir" ]]; then
    echo "Creating autoload directory: $autoload_dir"
    mkdir -p "$autoload_dir"
fi

# Download vim-plug
echo "Downloading vim-plug from: $plug_url"

# Try different download methods
if command -v curl >/dev/null 2>&1; then
    echo "Using curl..."
    curl -fLo "$plug_file" "$plug_url"
elif command -v wget >/dev/null 2>&1; then
    echo "Using wget..."
    wget -O "$plug_file" "$plug_url"
elif command -v powershell.exe >/dev/null 2>&1; then
    echo "Using PowerShell..."
    powershell.exe -Command "Invoke-WebRequest -Uri '$plug_url' -OutFile '$plug_file'"
else
    echo "❌ Error: No download tool available (curl, wget, or PowerShell)"
    echo ""
    echo "Manual installation:"
    echo "1. Download from: $plug_url"
    echo "2. Save to: $plug_file"
    echo "3. Create directory if needed: $autoload_dir"
    exit 1
fi

# Verify installation
if [[ -f "$plug_file" ]]; then
    file_size=$(wc -c < "$plug_file" 2>/dev/null || echo "0")
    echo "✅ vim-plug installed successfully!"
    echo "Location: $plug_file"
    echo "File size: $file_size bytes"
    
    if [[ "$file_size" -gt 1000 ]]; then
        echo "✅ Installation verified!"
        echo ""
        echo "Next steps:"
        echo "1. Open vim/gvim"
        echo "2. Run :PlugInstall to install plugins"
        echo "3. Restart vim/gvim to load plugins"
    else
        echo "⚠️  Warning: Downloaded file seems too small"
    fi
else
    echo "❌ Error: Installation failed - file not found"
    exit 1
fi

echo ""
echo "vim-plug installation completed!"
