# Setup & Deployment Guide

## Overview

The `setup_template.sh` script automates deployment of the AI Dev Template to your project directory. This guide explains what gets deployed and how.

## What Gets Deployed

### Configuration Files (converted from `dot.*` → `.*`)

```
Template Source          →  Deployed Target
─────────────────────────────────────────────────────────
dot.devcontainer/        →  .devcontainer/
  ├── Dockerfile
  ├── compose.yml
  ├── devcontainer.json
  ├── health-check.sh
  ├── post-create.sh
  └── tmux/
      └── tmux.conf      →  (symlinked to ~/.tmux.conf in container)

dot.github/              →  .github/
  └── workflows/
      └── ci.yml

dot.vscode/              →  .vscode/
  └── tasks.json

dot.aider.conf.yml       →  .aider.conf.yml
dot.ai_dev.yml           →  ai_dev.yml
dot.gitignore            →  .gitignore
dot.pre-commit-config.yaml → .pre-commit-config.yaml
dot.env.example          →  .env (special case)
```

### Application & Test Files (copied as-is)

```
Template Source          →  Deployed Target
─────────────────────────────────────────────────────────
app/                     →  app/
  ├── __init__.py
  └── main.py

tests/                   →  tests/
  ├── __init__.py
  └── test_health.py

prompts/                 →  prompts/
  ├── 01_basic_setup.md
  ├── 02_ai_workflow.md
  ├── 03_tmux_integration.md
  ├── 04_full_workflow.md
  ├── 05_ai_orchestration.md
  ├── README_prompts.md
  ├── refactor.md
  └── example_dev_setup.md

scripts/                 →  scripts/
  ├── ai_task_manager.sh  (executable)
  └── claude_run.sh       (executable)

Documentation (referenced):
  ├── AI_ORCHESTRATION.md
  ├── QUICKSTART_ORCHESTRATION.md
  └── USAGE.md
```

### Root Files (no conversion)

```
Template Source          →  Deployed Target
─────────────────────────────────────────────────────────
Makefile                 →  Makefile
requirements.txt         →  requirements.txt
README.md                →  README.md
```

## Deployment Process

### Step 1: Run Setup Script

```bash
# From dotfiles directory
~/dotfiles/templates/ai_dev/sample_template/setup_template.sh /path/to/your-project
```

### Step 2: Confirmation

The script will ask for confirmation:
```
Deploy template to /path/to/your-project? [y/N]
```

Type `y` and press Enter.

### Step 3: Automatic Deployment

The script performs these operations:

1. **Creates target directory** (if doesn't exist)
2. **Backs up existing files** (adds `.backup` extension)
3. **Copies DevContainer configuration**
   - Creates `.devcontainer/` directory
   - Sets executable permissions on scripts
4. **Copies GitHub workflows**
   - Creates `.github/workflows/` directory
5. **Copies VSCode tasks**
   - Creates `.vscode/` directory
6. **Copies configuration files**
   - Converts `dot.*` → `.*` naming
7. **Copies application & tests**
   - Only if directories don't exist (preserves existing code)
8. **Copies AI prompts**
   - Only if `prompts/` doesn't exist
9. **Copies AI orchestration scripts**
   - Creates `scripts/` directory
   - Copies `*.sh` files
   - Sets executable permissions
10. **Creates `.env` file**
    - From `dot.env.example`
    - Only if `.env` doesn't exist
11. **Bootstraps agent configuration**
    - Runs `agent/setup_agent.sh` if available
    - Creates CLAUDE.md, AGENTS.md, .cursor/

### Step 4: Post-Deployment

The script displays:
- Summary of files deployed
- Next steps checklist
- Documentation links
- Important warnings

## Special Handling

### Executable Permissions

Scripts maintain executable permissions:
```bash
chmod +x .devcontainer/health-check.sh
chmod +x .devcontainer/post-create.sh
chmod +x scripts/*.sh
```

### Backup System

Existing files are backed up before overwriting:
```
.aider.conf.yml         → .aider.conf.yml.backup
.devcontainer/          → .devcontainer.backup/
scripts/                → scripts.backup/
```

### Smart Copying

- **Configuration files**: Always copied (with backup)
- **Application code** (`app/`, `tests/`): Only if doesn't exist
- **Prompts**: Only if doesn't exist
- **Scripts**: Always copied (AI orchestration updates)

### Environment File Creation

```bash
# If .env doesn't exist:
cp dot.env.example .env

# User must edit .env to add:
# - ANTHROPIC_API_KEY
# - OPENAI_API_KEY
# - GITHUB_TOKEN
```

## Verification

After deployment, verify files were copied:

```bash
cd /path/to/your-project

# Check configuration files
ls -la .devcontainer/ .github/ .vscode/
ls -la .aider.conf.yml .gitignore .pre-commit-config.yaml

# Check application files
ls app/ tests/ prompts/

# Check AI orchestration scripts
ls -lah scripts/
# Should show:
# -rwxr-xr-x  ai_task_manager.sh
# -rwxr-xr-x  claude_run.sh

# Check environment file
cat .env
# Edit and add your API keys
```

## Next Steps After Deployment

1. **Configure API Keys**
   ```bash
   vim .env
   # Add your ANTHROPIC_API_KEY, OPENAI_API_KEY, GITHUB_TOKEN
   ```

2. **Open in DevContainer**
   ```bash
   code .  # or cursor .
   # Then: Cmd+Shift+P → "Dev Containers: Reopen in Container"
   ```

3. **Inside Container - Verify Environment**
   ```bash
   make health-check
   ```

4. **Install Pre-commit Hooks**
   ```bash
   make pre-commit-install
   ```

5. **Run Tests**
   ```bash
   make test
   ```

6. **Try AI Orchestration**
   ```bash
   tmux new-session -s ai-dev
   ./scripts/ai_task_manager.sh  # In first pane
   ./scripts/claude_run.sh "Set up dev environment"  # In another pane
   ```

   See [QUICKSTART_ORCHESTRATION.md](QUICKSTART_ORCHESTRATION.md) for details.

## Clean-Hard: Nuclear Reset

The template includes a `clean-hard` target for completely removing all deployed files:

```bash
make clean-hard
```

### What It Does

1. **Runs `clean` first** - Removes build artifacts
2. **Shows warning** - Lists all files to be removed
3. **Requires confirmation** - You must type `yes` to proceed
4. **Removes everything**:
   - Configuration: `.devcontainer/`, `.github/`, `.vscode/`
   - Dot files: `.gitignore`, `.aider*`, `.ai_dev.yml`, etc.
   - Cache: `.cache`, `.claude`, `.codex`, `.cursor`, `.pytest_cache`
   - Project files: `AGENTS.md`, `CLAUDE.md`, `Makefile`
   - Directories: `app/`, `tests/`, `scripts/`, `prompts/`, `logs/`, `mcp/`

### When to Use

- **Project reset**: Start fresh without manual cleanup
- **Template uninstall**: Remove all template files
- **Troubleshooting**: Clean slate when things go wrong
- **Testing**: Reset between deployment tests

### Safety Features

- **Interactive confirmation**: Must type `yes` to proceed
- **Clear warnings**: Shows exactly what will be removed
- **Abortable**: Exits safely if you cancel

### Example Usage

```bash
cd /path/to/project
make clean-hard

# Output:
# WARNING: This will remove ALL template files and configuration!
# Files/directories to be removed:
#   - .cache .claude .codex .coverage .cursor
#   - .devcontainer .github .gitignore .pre-commit-config.yaml
#   - .pytest_cache .vscode .aider* .ai_dev.yml
#   - AGENTS.md CLAUDE.md ai_dev.yml Makefile
#   - app/ mcp/ prompts/ requirements.txt scripts/ tests/ logs/
# Are you sure? Type 'yes' to continue: yes
# Removing template files...
# Clean-hard complete. Project reset to empty state.
```

### Recovery After clean-hard

If you want to restore the template:

```bash
# Re-deploy the template
~/dotfiles/templates/ai_dev/sample_template/setup_template.sh /path/to/project
```

## Troubleshooting

### Permission Denied on Scripts

```bash
# Manually fix permissions
chmod +x scripts/*.sh
chmod +x .devcontainer/*.sh
```

### Files Not Copied

```bash
# Check script output for warnings
# Re-run deployment:
~/dotfiles/templates/ai_dev/sample_template/setup_template.sh /path/to/project
```

### Backed Up Files Interfering

```bash
# Review backup files
ls -la *.backup

# Remove after verification
rm -rf *.backup
```

### Missing Dependencies

```bash
# Inside container, reinstall
make setup
```

## Re-Deployment / Updates

To update an existing project with new template changes:

1. **Backup your work** (commit to git)
2. **Re-run setup script**
   ```bash
   ~/dotfiles/templates/ai_dev/sample_template/setup_template.sh /path/to/project
   ```
3. **Review `.backup` files**
   - Compare your customizations
   - Merge changes if needed
4. **Remove backups** when satisfied
   ```bash
   rm -rf *.backup .*.backup
   ```

## Customization After Deployment

### Keep Custom Changes

These files can be customized per-project:
- `.env` - Your API keys
- `app/` - Your application code
- `tests/` - Your tests
- `prompts/` - Your custom prompts
- `.aider.conf.yml` - Model preferences
- `ai_dev.yml` - tmux layout

### Update from Template

These files should generally be kept in sync with template:
- `.devcontainer/` - Container configuration
- `.github/workflows/` - CI/CD pipelines
- `scripts/` - AI orchestration tools
- `Makefile` - Task automation
- `.pre-commit-config.yaml` - Quality hooks

## Version History

- **v2.1** (2025-10-16)
  - Added AI orchestration scripts deployment
  - Enhanced setup output with orchestration instructions
  - Updated documentation links

- **v2.0** (2025-10-16)
  - Cross-platform DevContainer compatibility
  - Updated to Claude 4.5 models

- **v1.0** (2025-10-15)
  - Initial release
  - Basic DevContainer setup

## Related Documentation

- [QUICKSTART_ORCHESTRATION.md](QUICKSTART_ORCHESTRATION.md) - AI orchestration quick start
- [AI_ORCHESTRATION.md](AI_ORCHESTRATION.md) - Complete orchestration guide
- [TEMPLATE_NAMING.md](TEMPLATE_NAMING.md) - File naming conventions
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [CHANGELOG_v2.1.md](CHANGELOG_v2.1.md) - Release notes

---

**Last Updated:** 2025-10-16 (v2.1)
**Maintained by:** dotfiles/templates/ai_dev/sample_template/
