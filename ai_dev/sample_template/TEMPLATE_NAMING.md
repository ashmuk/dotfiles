# Template Naming Convention

## Why `dot.` Prefix?

In the `sample_template/` directory, configuration files and directories use the `dot.` prefix instead of the standard `.` (hidden) prefix.

### Problem with Standard `.` Prefix
- **Hidden by default** in Finder (macOS) and Explorer (Windows)
- Requires special settings to view (Cmd+Shift+. on macOS)
- Easy to accidentally overlook important config files
- Harder to browse and maintain template

### Solution: `dot.` Prefix
- ✅ **Fully visible** in all file browsers without special settings
- ✅ **Easy to edit** - no need to toggle hidden file visibility
- ✅ **Clear intent** - obvious these will become hidden files after deployment
- ✅ **Maintained in git** - visible in GitHub/GitLab web interfaces

## File Mapping

The `setup_template.sh` script automatically converts `dot.*` → `.*` during deployment:

| Template (visible) | Deployed (hidden) |
|-------------------|-------------------|
| `dot.devcontainer/` | `.devcontainer/` |
| `dot.github/` | `.github/` |
| `dot.vscode/` | `.vscode/` |
| `dot.aider.conf.yml` | `.aider.conf.yml` |
| `dot.tmuxinator.yml` | `.tmuxinator.yml` |
| `dot.gitignore` | `.gitignore` |
| `dot.pre-commit-config.yaml` | `.pre-commit-config.yaml` |
| `dot.env.example` | `.env` (special case) |
| `Makefile` | `Makefile` (no change) |
| `README.md` | `README.md` (no change) |

## Conversion Logic

```bash
# In setup_template.sh
convert_dotname() {
  local src="$1"
  local basename=$(basename "$src")
  
  if [[ "$basename" == dot.* ]]; then
    # Remove 'dot.' prefix and add '.' prefix
    echo ".${basename#dot.}"
  else
    echo "$basename"
  fi
}

# Example usage:
# dot.devcontainer → .devcontainer
# dot.gitignore → .gitignore
# Makefile → Makefile (unchanged)
```

## Examples

### Viewing Template Files
```bash
# In template directory - all visible
ls ~/dotfiles/ai_dev/sample_template/
# Output shows: dot.devcontainer/ dot.github/ dot.vscode/ etc.

# No special commands needed - visible in Finder/Explorer
```

### After Deployment
```bash
# In project directory - standard hidden files
ls -la /path/to/project/
# Output shows: .devcontainer/ .github/ .vscode/ etc.

# Standard dot-files, works with all tools expecting them
```

## Benefits

1. **Template Maintenance**: Easy to browse and edit template files
2. **Documentation**: Can include screenshots showing visible structure
3. **Git Friendly**: All files visible in web interfaces
4. **Standard Deployment**: Converts to standard conventions automatically
5. **No User Confusion**: Clear what will become hidden after deployment

## Pattern for Other Templates

This pattern can be applied to any dotfiles or configuration template:

```bash
# Template structure (in dotfiles repo)
my-template/
├── dot.config/
├── dot.bashrc
├── dot.vimrc
└── setup.sh  # Converts dot.* → .*

# After deployment (in target)
~/.config/
~/.bashrc
~/.vimrc
```

## Related Files

- `setup_template.sh` - Handles the conversion
- `README.md` - Documents the structure
- `ARCHITECTURE.md` - Explains the rationale
- `USAGE.md` - Shows how to use the template

---

**Convention adopted:** 2025-10-15  
**Applies to:** ai_dev/sample_template/
