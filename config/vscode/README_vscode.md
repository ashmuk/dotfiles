# VS Code Configuration

This directory contains comprehensive Visual Studio Code configuration optimized for dotfiles development and cross-platform compatibility.

## File Structure

```
config/vscode/
├── settings.json          # Main VS Code configuration file
└── README_vscode.md       # This documentation file
```

## Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles (includes VS Code)
make install

# Install only VS Code configuration
make install-vscode

# Check status of installed files
make status
```

### Manual Installation
```bash
# Create VS Code directory and symlink
mkdir -p ~/.vscode
ln -sf $(pwd)/config/vscode/settings.json ~/.vscode/settings.json
```

## Configuration Features

### 🎨 **Editor Experience**
- **Modern Font Stack**: Prioritizes JetBrains Mono, Fira Code, and Cascadia Code with ligature support
- **Smart Formatting**: Auto-indent detection with 2-space default, rulers at 80/120 columns
- **Enhanced Display**: Smooth scrolling, cursor blinking, and whitespace visualization
- **Auto-Save**: Configured with 1-second delay for seamless workflow

### 📁 **File Management**
- **Comprehensive Exclusions**: Performance optimized with sensible file/directory exclusions
- **Smart Watching**: Excludes build artifacts and caches from file watching
- **Auto-Cleanup**: Trailing whitespace removal, final newline insertion
- **Project-Aware**: `.vscode` directory explicitly visible for configuration management

### 🔍 **Enhanced File Associations**
The configuration includes extensive file type detection for dotfiles development:

#### Shell & Scripts
```json
{
  "shell.*": "shellscript",
  "aliases.*": "shellscript",
  ".bashrc": "shellscript",
  ".zshrc": "shellscript",
  "*.sh": "shellscript",
  "*.ps1": "powershell"
}
```

#### Configuration Files
```json
{
  "*gitconfig*": "git-config",
  "*gitignore*": "ignore",
  "Makefile": "makefile",
  "*.conf": "ini",
  ".tmux.conf": "tmux"
}
```

#### Development Files
```json
{
  "*.json": "jsonc",           // JSON with comments support
  "*.yaml": "yaml",
  "*.toml": "toml",
  ".vimrc": "viml",
  "Dockerfile*": "dockerfile"
}
```

### 🖥️ **Terminal Integration**
- **Font Consistency**: Matching font family between editor and integrated terminal
- **Copy-on-Selection**: Enabled for efficient workflow
- **Cursor Styling**: Blinking cursor for better visibility

### 🔧 **Development Tools**
- **Git Integration**: Smart commit suggestions, auto-fetch, tree view
- **IntelliSense**: Auto-import updates for JavaScript/TypeScript
- **Extensions**: Auto-update enabled for latest features
- **Security**: Workspace trust prompts for safe development

### 🎯 **UI/UX Enhancements**
- **Theme Adaptability**: Auto-detects system color scheme with Dark+/Light+ themes
- **Breadcrumbs**: Enabled with type-based symbol sorting
- **Problems Panel**: Active status indicators and decorations
- **Explorer**: Compact folders disabled, confirmations for safety

## Usage Examples

### Dotfiles Development Workflow
```bash
# With proper file associations, these files are automatically recognized:
code .bashrc          # → shellscript syntax
code .vimrc           # → viml syntax
code Makefile         # → makefile syntax
code .tmux.conf       # → tmux syntax
code config.yaml      # → yaml syntax
```

### Multi-Platform Development
The configuration works seamlessly across:
- **macOS**: Full font support with SF Mono fallback
- **Linux**: Ubuntu Mono and DejaVu Sans Mono fallbacks
- **Windows**: Cascadia Code and console fonts
- **WSL**: Cross-platform font stack ensures consistency

### Performance Optimization
```json
{
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/.mypy_cache/**": true,
    "**/dist/**": true
  }
}
```

## Advanced Features

### 📋 **Smart File Exclusions**
The configuration implements a three-tier exclusion system:

#### **Files Panel** (`files.exclude`)
- Hidden from explorer but accessible via search
- Build artifacts, cache directories, and system files
- `.vscode` explicitly visible for dotfiles management

#### **Search** (`search.exclude`)
- Excluded from search results for performance
- Focuses search on source code and configuration files
- Removes noise from search results

#### **File Watching** (`files.watcherExclude`)
- Not monitored for changes to improve performance
- Large directories that change frequently
- Binary and generated content

### 🎨 **Font Hierarchy**
```json
{
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', 'Cascadia Code', 'SF Mono', Monaco, 'Cascadia Code PL', 'Ubuntu Mono', monospace"
}
```

### 🔒 **Security Configuration**
- **Workspace Trust**: Prompts for untrusted files
- **Trust Banner**: Always visible for security awareness
- **Safe Defaults**: Explorer confirmations for destructive operations

## Integration with Dotfiles Ecosystem

### 🔗 **Makefile Integration**
- **Installation**: `make install-vscode` installs configuration
- **Status Monitoring**: `make status` shows VS Code configuration state
- **Cleanup**: `make clean` removes VS Code settings
- **Validation**: `make validate` includes VS Code directory checks

### 🏠 **Home Directory Structure**
```
~/.vscode/
└── settings.json → /path/to/dotfiles/config/vscode/settings.json
```

### 📊 **Status Reporting**
The Makefile provides detailed status information:
```bash
$ make status
VS Code Configuration:
  Home directory:
    ✓ .vscode/settings.json (symlink)  # Properly linked
    ⚠ .vscode/settings.json (file)     # Needs migration
    ✗ .vscode/settings.json (not found) # Not installed
```

## Customization

### Project-Specific Settings
Create workspace-specific settings in your project:
```json
// .vscode/settings.json (workspace)
{
  "editor.tabSize": 4,  // Override default 2-space tabs
  "files.associations": {
    "*.custom": "json"  // Project-specific file types
  }
}
```

### User-Level Overrides
The global settings can be overridden in VS Code's user settings:
```json
// Override via VS Code UI or Command Palette
{
  "workbench.colorTheme": "GitHub Dark",
  "editor.fontSize": 14
}
```

### Extension Integration
The configuration works well with popular extensions:
- **GitLens**: Enhanced git integration
- **Prettier**: Auto-formatting support
- **ESLint**: JavaScript/TypeScript linting
- **shellcheck**: Shell script validation
- **YAML**: Enhanced YAML support

## Troubleshooting

### Font Issues
If fonts aren't displaying correctly:

1. **Install recommended fonts**:
   ```bash
   make install-fonts  # If available in your dotfiles
   ```

2. **Verify font installation**:
   ```bash
   make check-fonts    # Check available programming fonts
   ```

3. **Manual font verification**:
   - **macOS**: Font Book → Search for "JetBrains Mono"
   - **Linux**: `fc-list | grep -i jetbrains`
   - **Windows**: Check installed fonts in Settings

### Symlink Issues
If the settings aren't loading:

1. **Verify symlink**:
   ```bash
   ls -la ~/.vscode/settings.json
   readlink ~/.vscode/settings.json
   ```

2. **Recreate symlink**:
   ```bash
   make install-vscode  # Reinstall configuration
   ```

3. **Manual fixing**:
   ```bash
   rm ~/.vscode/settings.json
   ln -sf /path/to/dotfiles/config/vscode/settings.json ~/.vscode/settings.json
   ```

### JSON Validation
If VS Code reports JSON errors:

1. **Validate JSON syntax**:
   ```bash
   jq empty config/vscode/settings.json
   ```

2. **Check for common issues**:
   - Trailing commas
   - Missing quotes around keys
   - Improper nesting

### Performance Issues
If VS Code is slow:

1. **Check exclusion patterns**:
   - Verify `files.watcherExclude` includes large directories
   - Add project-specific exclusions if needed

2. **Monitor file watching**:
   ```bash
   # Check VS Code's file watching usage
   code --status
   ```

## Migration from Existing Settings

### Backup Current Settings
```bash
# Automatic backup during installation
make install-vscode  # Creates timestamped backup

# Manual backup
cp ~/.vscode/settings.json ~/.vscode/settings.json.backup
```

### Merge Custom Settings
1. **Identify custom settings**:
   ```bash
   diff ~/.vscode/settings.json.backup config/vscode/settings.json
   ```

2. **Preserve important customizations**:
   - Theme preferences
   - Extension settings
   - Keybinding preferences

3. **Create workspace overrides** for project-specific needs

## Platform Considerations

### macOS Specific
- **SF Mono**: System font available by default
- **Font Rendering**: Optimized for Retina displays
- **Menu Integration**: Standard macOS application behavior

### Linux Specific
- **Font Installation**: May require manual font installation
- **Theme Integration**: Follows GTK theme preferences
- **File Associations**: Integrates with desktop environment

### Windows/WSL Specific
- **Cascadia Code**: Available on Windows 10/11
- **Path Handling**: Works with both Windows and WSL paths
- **Performance**: Optimized for Windows file system watching

This VS Code configuration provides a robust, cross-platform development environment that integrates seamlessly with your dotfiles ecosystem while maintaining excellent performance and usability.