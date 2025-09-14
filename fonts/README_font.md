# Font Installation Guide

This guide covers font installation across different platforms, with focus on Nerd Fonts for proper terminal icon display.

## What are Nerd Fonts?

[Nerd Fonts](https://www.nerdfonts.com/) are popular developer fonts patched with a high number of glyphs (icons). They provide:
- Enhanced terminal experience with icons and symbols
- Better compatibility with modern terminal applications
- Support for powerline, vim-airline, and other status line plugins

## Installation Methods

### Windows (Chocolatey - Recommended)

Install Chocolatey if not already installed:
```powershell
# Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Install Nerd Fonts:
```powershell
# Search for available Nerd Fonts (names may vary)
choco search nerd-fonts

# Install popular Nerd Fonts via Chocolatey
choco install nerd-fonts-hack -y
choco install nerd-fonts-firacode -y
choco install nerd-fonts-cascadiacode -y
choco install nerd-fonts-jetbrainsmono -y

# Or install all Nerd Fonts (warning: large download ~2GB)
# choco install nerd-fonts-complete -y
```

**Note:** Font package names may change over time. Use `choco search nerd-fonts` to find current available packages.

### Windows (Manual Installation)

1. Download fonts from [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases)
2. Extract the font files
3. Right-click font files → "Install" or "Install for all users"
4. Or copy to `C:\Windows\Fonts\` (requires admin)

### macOS (Homebrew)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Nerd Fonts via Homebrew Cask
brew tap homebrew/cask-fonts

# Install specific fonts
brew install --cask font-hack-nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-cascadia-code-nerd-font

# Or install all Nerd Fonts (warning: large download)
# brew install --cask font-nerd-font
```

### Linux (Package Manager)

#### Ubuntu/Debian
```bash
# Install from official repositories (limited selection)
sudo apt update
sudo apt install fonts-firacode fonts-hack

# Or install manually (see Manual Installation section)
```

#### Arch Linux
```bash
# Install from AUR
yay -S nerd-fonts-complete
# Or specific fonts
yay -S nerd-fonts-fira-code nerd-fonts-hack
```

### Manual Installation (All Platforms)

1. Visit [Nerd Fonts Downloads](https://www.nerdfonts.com/font-downloads)
2. Download desired fonts (popular choices):
   - **Hack Nerd Font** - Clean, readable
   - **FiraCode Nerd Font** - Excellent ligature support
   - **JetBrains Mono Nerd Font** - Modern, designed for coding
   - **CascadiaCode Nerd Font** - Microsoft's terminal font
3. Install according to your OS:
   - **Windows**: Right-click → Install
   - **macOS**: Double-click → Install Font
   - **Linux**: Copy to `~/.local/share/fonts/` then run `fc-cache -fv`

## Terminal Configuration

### Windows Terminal
1. Open Windows Terminal
2. Settings (Ctrl+,) → Profiles → Defaults → Appearance
3. Font face → Choose your Nerd Font:
   - "Hack Nerd Font"
   - "FiraCode Nerd Font"
   - "JetBrains Mono Nerd Font"
   - "CascadiaCode Nerd Font"

### WSL Terminal
Same as Windows Terminal configuration above - WSL uses the Windows Terminal settings.

### PowerShell ISE
1. Options → Change Font
2. Select your installed Nerd Font

### macOS Terminal
1. Terminal → Preferences → Profiles
2. Text tab → Font → Change
3. Select your Nerd Font

### iTerm2 (macOS)
1. Preferences → Profiles → Text
2. Font → Select your Nerd Font

### Linux Terminal Emulators

#### GNOME Terminal
1. Edit → Preferences → Profiles
2. Text tab → Custom font
3. Select your Nerd Font

#### Konsole (KDE)
1. Settings → Edit Current Profile
2. Appearance → Font
3. Select your Nerd Font

## Verification

Test your font installation by running:
```bash
echo "Testing Nerd Font icons: 🔥 ⚡ 🚀 💻 📁 🌟"
```

You should see proper icons if Nerd Fonts are working correctly.

## Recommended Fonts by Use Case

- **Programming**: JetBrains Mono Nerd Font, FiraCode Nerd Font
- **Terminal Work**: Hack Nerd Font, CascadiaCode Nerd Font
- **General Use**: JetBrains Mono Nerd Font
- **Ligature Support**: FiraCode Nerd Font, CascadiaCode Nerd Font

## Troubleshooting

### Font Not Appearing
- Restart terminal application after installation
- Check font name exactly (case-sensitive)
- Verify font installed system-wide vs user-only

### Icons Not Displaying
- Confirm you're using a "Nerd Font" variant
- Test with: `echo "\ue0b0 \ue0b2 \uf27c \uf269"`
- Check terminal's font fallback settings

### Performance Issues
- Some fonts with many glyphs may impact performance
- Try different Nerd Font variants
- Consider font hinting settings

## Scripts in This Directory

- `install_fonts.sh` - Linux/macOS font installation script
- `install_fonts.ps1` - Windows PowerShell font installation script

Run these scripts to automatically install recommended Nerd Fonts for your platform.