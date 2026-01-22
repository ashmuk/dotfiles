# Git Configuration

A comprehensive git configuration system with common settings, aliases, and ignore patterns for various development environments.

## 📁 File Structure

```
git/
├── setup_git.sh           # Installation script for git configurations
├── gitconfig.common       # Common git settings and aliases
├── gitignore.common       # Common gitignore patterns
├── gitattributes.common   # Common gitattributes patterns
└── README_git.md         # This documentation file
```

## 🚀 Installation

### Using Makefile (Recommended)
```bash
# Install all dotfiles including git
make install

# Install only git configuration
make install-git
```

### Manual Installation
```bash
# Run the git setup script
./git/setup_git.sh
```

## 🎯 Configuration Files

### `gitconfig.common`
**Comprehensive git configuration with extensive aliases**

#### Core Settings
- **Line ending handling**: `autocrlf = input` for cross-platform compatibility
- **Editor**: Vim as default editor
- **Pager**: `less -R` for colored output
- **Case sensitivity**: `ignorecase = false` for precise matching

#### Diff and Merge Tools
- **Vimdiff integration**: Configured for macOS with MacVim
- **Color output**: Automatic colorization
- **Conflict resolution**: Three-way merge with diff3 style

#### Branch and Push Settings
- **Default branch**: `main` as default branch name
- **Push behavior**: Simple push with auto-setup remote tracking
- **Pull behavior**: Standard merge (not rebase by default)

#### Color Configuration
- **UI colors**: Automatic color output
- **Branch colors**: Yellow for current, green for remote
- **Diff colors**: Red for deletions, green for additions
- **Status colors**: Color-coded file status

#### Comprehensive Aliases
- **Basic**: `st`, `co`, `br`, `ci`, `df`, `lg`
- **Advanced**: `unstage`, `last`, `visual`, `amend`, `wipe`
- **Branch management**: `bclean`, `bmerged`, `bunmerged`
- **Stash management**: `stash-list`, `stash-clear`, `stash-pop`
- **Remote management**: `remotes`, `remote-url`
- **File management**: `files`, `ignored`
- **History**: `graph`, `hist`
- **Workflow**: `wip`, `unwip`, `save`, `pop`
- **Quick fixes**: `fixup`, `squash`
- **Information**: `who`, `what`, `when`, `where`

### `gitignore.common`
**Comprehensive ignore patterns for various environments**

#### Operating System Files
- **macOS**: `.DS_Store`, Spotlight, Trash files
- **Windows**: Thumbs.db, desktop.ini, recycle bin
- **Linux**: Hidden files, trash, NFS files

#### Editor and IDE Files
- **Vim**: Swap files, session files, netrw history
- **IntelliJ IDEA**: `.idea/`, project files, workspace settings
- **Visual Studio Code**: `.vscode/`, workspace files
- **Sublime Text**: Project and workspace files
- **Atom**: `.atom/` directory

#### Language-Specific Files
- **Python**: `__pycache__/`, `.pyc`, virtual environments
- **Node.js**: `node_modules/`, npm logs, yarn files
- **Java**: `.class`, `.jar`, build artifacts
- **C/C++**: Object files, executables, libraries
- **Go**: `target/`, executables
- **Rust**: `target/`, Cargo lock

#### Build and Dependency Files
- **Gradle**: `.gradle/`, build directories
- **Maven**: `target/`, backup files
- **Package managers**: npm, yarn, bower files

#### Security and Sensitive Files
- **Environment variables**: `.env`, `.env.local`
- **API keys**: `*.key`, `*.pem`, secrets directories
- **Certificates**: Various certificate formats

### `gitattributes.common`
**File attribute definitions for proper git handling**

#### Text Files
- **Source code**: Proper text handling for all major languages
- **Configuration**: YAML, JSON, XML, INI files
- **Documentation**: Markdown, RST, text files

#### Line Ending Handling
- **Windows**: CRLF for batch files, PowerShell scripts
- **Unix**: LF for shell scripts, source code
- **Cross-platform**: Proper line ending management

#### Binary Files
- **Images**: PNG, JPG, GIF, SVG, WebP
- **Audio/Video**: MP3, MP4, AVI, MOV, WebM
- **Archives**: ZIP, TAR, GZ, 7Z, RAR
- **Documents**: PDF, DOC, XLS, PPT
- **Executables**: EXE, DLL, SO, APP

#### Language-Specific Attributes
- **Diff tools**: Python, JavaScript, Java, C/C++, Go, Rust
- **Merge strategies**: Union merge for lock files
- **Export ignore**: Documentation and config files

## 🔧 Customization

### Personal Settings
After installation, add personal settings to:
- `~/.gitconfig` - User-specific git configuration
- `~/.gitignore` - Personal ignore patterns
- `~/.gitattributes` - Personal file attributes

### User Configuration
```bash
# Set your user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set your preferred editor
git config --global core.editor "vim"

# Set your preferred merge tool
git config --global merge.tool "vimdiff"
```

### Custom Aliases
```bash
# Add custom aliases
git config --global alias.myalias "command --options"

# Example: Custom log format
git config --global alias.mylog "log --pretty=format:'%h %s' --graph"
```

## 📋 Installation Details

The git setup creates symlinks to:
- `~/.gitconfig` → Main git configuration (includes common config)
- `~/.gitignore` → Global gitignore file
- `~/.gitattributes` → Global gitattributes file
- `~/gitconfig.common` → Common git settings and aliases
- `~/gitignore.common` → Common ignore patterns
- `~/gitattributes.common` → Common file attributes

## 🌍 Environment Support

### Cross-Platform Compatibility
- **macOS**: Full support with MacVim integration
- **Linux**: Vimdiff and standard tools
- **Windows**: WSL, Git Bash, and native support

### IDE Integration
- **IntelliJ IDEA**: Compatible with built-in git tools
- **Visual Studio Code**: Works with integrated git features
- **Vim/Neovim**: Optimized for vim-based workflows

## 🛠️ Advanced Configuration

### Git LFS (Large File Storage)
```bash
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.psd"
git lfs track "*.zip"
```

### Custom Merge Drivers
```bash
# Define custom merge driver
git config --global merge.customdriver.driver "custom-merge-driver %O %A %B %L"
```

### Hooks
```bash
# Add custom hooks
git config --global core.hooksPath ~/.git-hooks
```

## 🔄 Updating

```bash
# Update git configuration
make update
make install-git
```

## 🗑️ Uninstalling

```bash
# Remove git configuration
make clean
```

## 📚 Additional Resources

- [Git Documentation](https://git-scm.com/doc)
- [Git Attributes](https://git-scm.com/docs/gitattributes)
- [Git Ignore](https://git-scm.com/docs/gitignore)
- [Git Aliases](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)

## 📄 License

This configuration is part of the dotfiles project and is available under the [MIT License](../LICENSE).
