# Development Workflow Guide

Quick reference for development workflows with pre-commit hooks, VSCode tasks, and health checks.

## Pre-commit Hooks

This dotfiles repository uses pre-commit hooks to ensure code quality.

### Installation

```bash
# Install pre-commit
pip install pre-commit

# Install hooks in this repository
cd ~/dotfiles
pre-commit install
```

### What Gets Checked

- **YAML validation** - Validates syntax for tmuxinator templates, GitHub Actions
- **Shell scripts** - Lints with ShellCheck, formats with beautysh
- **Markdown** - Lints and auto-fixes formatting issues
- **JSON** - Validates syntax
- **Python** - Formats with Black
- **General** - Checks for large files, merge conflicts, trailing whitespace, broken symlinks
- **Custom** - Validates tmuxinator templates, checks Makefile syntax

### Manual Execution

```bash
# Run on all files
pre-commit run --all-files

# Run on staged files only
pre-commit run

# Run specific hook
pre-commit run shellcheck --all-files
```

### Skipping Hooks (when necessary)

```bash
# Skip all hooks for one commit (use sparingly!)
git commit --no-verify -m "message"

# Skip specific hook
SKIP=shellcheck git commit -m "message"
```

## VSCode Tasks Integration

The AI development sample includes VSCode tasks for common operations.

### Available Tasks

Access via `Cmd+Shift+P` → `Tasks: Run Task`:

- **Aider Tasks** - Plan development, auto-refactor code
- **Testing** - Run tests, CI checks, linting
- **Docker** - Build, start, stop containers
- **Health Check** - Verify environment setup
- **Pre-commit** - Install hooks, run checks

### Quick Access

- `Cmd+Shift+B` - Build menu (common tasks)
- `Cmd+Shift+T` - Test menu

## Environment Health Check

Verify your development environment is properly configured.

### Inside DevContainer

```bash
./.devcontainer/health-check.sh
```

### What Gets Checked

✓ Container environment
✓ Required tools (git, python, aider, etc.)
✓ Environment variables (API keys)
✓ Project files (.aider.conf.yml, Makefile, etc.)
✓ Git configuration
✓ Network connectivity

### Exit Codes

- `0` - Healthy (all required checks passed)
- `1` - Unhealthy (required checks failed)

Warnings for optional items don't cause failure.

## Troubleshooting

### Pre-commit Hook Failures

If a hook fails:

1. **Read the error message** - It usually tells you exactly what to fix
2. **Fix the issue** - Make the necessary changes
3. **Stage the changes** - `git add <file>`
4. **Commit again** - The hooks will re-run automatically

### Common Issues

**"command not found: pre-commit"**
```bash
pip install pre-commit
pre-commit install
```

**"No such file or directory: .pre-commit-config.yaml"**
```bash
cd ~/dotfiles  # Make sure you're in the dotfiles directory
```

**Health check fails in container**
```bash
# Review failed checks
./.devcontainer/health-check.sh

# Install missing tools
make setup

# Set API keys
vim .env
```

## Best Practices

1. **Always run health check after setup** - Catches configuration issues early
2. **Use VSCode tasks for common operations** - Faster than typing commands
3. **Don't skip pre-commit hooks** - They catch issues before they reach CI
4. **Keep hooks updated** - Run `pre-commit autoupdate` periodically

## See Also

- [AI Development Setup Guide](ai_dev/README_ai_dev.md)
- [tmux Configuration](config/tmux/README_tmux.md)
- [Pre-commit Documentation](https://pre-commit.com/)
