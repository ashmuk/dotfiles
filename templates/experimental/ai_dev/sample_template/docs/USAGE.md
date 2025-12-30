# AI Dev Template - Usage Guide

> **Note:** In the template directory, files use `dot.` prefix (e.g., `dot.devcontainer/`, `dot.gitignore`) for visibility in Finder/Explorer. The `setup_template.sh` script automatically converts these to hidden `.` files during deployment.

## Quick Reference

### Essential Commands

```bash
# Setup & Verification
make health-check          # Verify environment
make setup                 # Install dependencies
make pre-commit-install    # Install git hooks

# Development
make run                   # Start server (hot reload)
make test                  # Run tests with coverage
make lint                  # Check code quality
make format                # Auto-format code

# AI Development
make aider-plan            # Generate test plan
make aider-refactor        # AI-assisted coding

# Quality Assurance
make ci-local              # Run GitHub Actions locally
make pre-commit-run        # Run all quality checks
make clean                 # Clean build artifacts
```

### VSCode/Cursor Tasks (Cmd+Shift+B)

Quick access to common operations:
- Test: Run All Tests
- Lint: Check Code Quality
- Format: Auto-Format Code
- Health Check: Verify Environment

## Detailed Workflows

### 1. Initial Setup (New Project)

```bash
# Step 1: Deploy template
~/dotfiles/templates/ai_dev/sample_template/setup_template.sh ~/projects/my-app

# Step 2: Configure
cd ~/projects/my-app
vim .env  # Add API keys

# Step 3: Open in container
cursor .
# Cmd+Shift+P → "Dev Containers: Reopen in Container"

# Step 4: Verify (inside container)
make health-check

# Step 5: Install pre-commit hooks
make pre-commit-install

# Step 6: Run tests
make test
```

### 2. Daily Development

```bash
# Option A: Traditional workflow
vim app/main.py           # Edit code
make lint                 # Check quality
make test                 # Verify tests
git commit -m "feat: add feature"

# Option B: tmux parallel workflow
tmuxinator start -p .tmuxinator.yml
# Pane 1: make run (server auto-reloads)
# Pane 2: make test (continuous testing)
# Pane 3: make aider-refactor (AI assistance)
# Pane 4: gh pr status --watch
```

### 3. AI-Assisted Feature Development

```bash
# Step 1: Generate plan
make aider-plan
# Creates: tests/TESTPLAN.md

# Step 2: Review plan
cat tests/TESTPLAN.md

# Step 3: Implement with AI
make aider-refactor
# Aider will:
# - Analyze existing code
# - Propose changes
# - Run tests automatically
# - Commit if tests pass

# Step 4: Verify
make test
make lint
```

### 4. Custom AI Tasks

```bash
# Interactive mode
aider

# One-shot task
aider --message "Add logging to all endpoints" --yes

# Specific files only
aider app/main.py --message "Add error handling"

# With different model
aider --model gpt-4 --message "Optimize performance"
```

### 5. Pre-Commit Quality Gates

```bash
# First time setup
make pre-commit-install

# Now hooks run automatically on commit
git commit -m "feat: add feature"
# Runs:
# ✓ trailing-whitespace
# ✓ end-of-file-fixer
# ✓ ruff (lint + format)
# ✓ shellcheck
# ✓ markdownlint
# ✓ yamllint
# ✓ secret detection

# Manual run (all files)
make pre-commit-run
```

### 6. Local CI Testing

```bash
# Run full CI pipeline locally
make ci-local

# This runs:
# - Linting (ruff)
# - Formatting check
# - Tests (pytest)
# - Coverage report
# - Security scan (bandit)

# Same as GitHub Actions, faster feedback
```

### 7. Debugging

```bash
# Check environment
make health-check

# View container logs
docker compose -f .devcontainer/compose.yml logs

# Inspect running container
docker compose -f .devcontainer/compose.yml exec ai-dev-template bash

# Check Python packages
pip list

# Verify virtual environment
echo $VIRTUAL_ENV
which python
```

### 8. Working with Profiles

```bash
# Default profile (with network)
docker compose -f .devcontainer/compose.yml up

# No-network profile (isolated)
docker compose -f .devcontainer/compose.yml --profile no-net up

# Use case: Offline testing
# Use case: Security testing
# Use case: CI without external dependencies
```

### 9. Updating Dependencies

```bash
# Update requirements
vim .devcontainer/devcontainer.json
# Edit postCreateCommand to add new packages

# Rebuild container
# Cmd+Shift+P → "Dev Containers: Rebuild Container"

# Or manually:
docker compose -f .devcontainer/compose.yml down
docker compose -f .devcontainer/compose.yml build --no-cache
docker compose -f .devcontainer/compose.yml up -d
```

### 10. Team Collaboration

```bash
# Share template updates
git add .devcontainer/ Makefile .pre-commit-config.yaml
git commit -m "chore: update dev environment"
git push

# Team members:
git pull
# Cmd+Shift+P → "Dev Containers: Rebuild Container"

# Consistent environment for everyone
```

## Common Patterns

### Pattern: Test-Driven Development

```bash
# Terminal 1: Watch tests
make test

# Terminal 2: Edit code
vim app/main.py

# Terminal 3: Run server
make run

# Tests auto-rerun on save
```

### Pattern: AI Pair Programming

```bash
# Terminal 1: Aider in interactive mode
aider

# In Aider:
/add app/main.py tests/test_*.py
# Describe what you want
# Review proposed changes
# Accept or iterate
```

### Pattern: Pre-Push Validation

```bash
# Before pushing
make pre-commit-run       # All quality checks
make ci-local             # Full CI simulation
make health-check         # Environment verification

# If all pass:
git push
```

### Pattern: Feature Branch Workflow

```bash
# Create branch
git checkout -b feature/new-endpoint

# Develop with AI
make aider-refactor

# Verify
make test
make lint
make ci-local

# Create PR
git push -u origin feature/new-endpoint
gh pr create
```

## Tips & Tricks

### Tip 1: Fast Iteration
```bash
# Use --yes flag for non-interactive AI
aider --message "Add docstrings" --yes

# Faster than manual typing
```

### Tip 2: Smart File Selection
```bash
# Aider only on specific files
aider app/routes/*.py --message "Add validation"

# More focused changes
```

### Tip 3: Incremental Quality
```bash
# Fix one issue at a time
make lint | head -10
# Fix first issue
make lint | head -10
# Repeat
```

### Tip 4: Health Check After Changes
```bash
# Always verify after container changes
make health-check

# Catches issues early
```

### Tip 5: Use VSCode Tasks
```bash
# Cmd+Shift+P → Tasks: Run Task
# Faster than typing make commands
# Integrated output panel
```

## Environment Variables

### Required (for AI features)
```bash
ANTHROPIC_API_KEY=sk-ant-...  # Claude models
OPENAI_API_KEY=sk-...         # GPT models
GITHUB_TOKEN=ghp_...          # GitHub integration
```

### Optional
```bash
APP_ENV=development           # Application environment
LOG_LEVEL=info                # Logging verbosity
```

### Where to set
1. `.env` file (git-ignored, local only)
2. Shell export (temporary)
3. Docker Compose environment section (team-wide)

## Troubleshooting

### "make: command not found"
**Cause:** Not in container
**Fix:** Reopen in DevContainer

### "aider: command not found"
**Cause:** venv not activated
**Fix:** `source /home/vscode/.venv/bin/activate`

### "Permission denied"
**Cause:** Running as root or wrong user
**Fix:** Check `user: vscode` in compose.yml

### "Port 8000 already in use"
**Cause:** Previous server still running
**Fix:** `pkill -f uvicorn` or restart container

### "Tests failing in CI but pass locally"
**Cause:** Environment differences
**Fix:** Run `make ci-local` to replicate CI environment

### "Pre-commit hooks not running"
**Cause:** Not installed
**Fix:** `make pre-commit-install`

## Next Steps

After mastering the basics:

1. **Customize Makefile** - Add project-specific targets
2. **Extend .pre-commit-config.yaml** - Add more hooks
3. **Enhance .tmuxinator.yml** - Adjust pane layout
4. **Add metrics** - Integrate API usage tracking
5. **Automate more** - Move toward sample_adv vision

## Getting Help

- Run `make health-check` for diagnostics
- Check logs: `docker compose logs`
- Review README.md for architecture
- See ARCHITECTURE.md for design decisions

## Learn More

- [Aider Tips](https://aider.chat/docs/tips.html)
- [tmux Guide](https://github.com/tmux/tmux/wiki)
- [Pre-commit Hooks](https://pre-commit.com/hooks.html)
- [DevContainers](https://containers.dev/implementors/json_reference/)

---

**Remember:** This template is a foundation. Customize it for your needs!
