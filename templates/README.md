# Templates Directory

This directory contains reusable templates for bootstrapping new projects and environments.

## Directory Structure

```
templates/
├── project/            # Main project template (recommended)
│   ├── setup_project.sh    # Bootstrap script
│   ├── Makefile            # Project management commands
│   ├── dot.devcontainer/   # DevContainer configuration
│   ├── dot.agent/          # Agent definitions (subagents, commands, skills)
│   ├── dot.claude/         # Claude Code configuration
│   ├── dot.cursor/         # Cursor IDE rules
│   ├── dot.codex/          # Codex skills (project-level)
│   ├── dot.github/         # GitHub workflows and templates
│   ├── dot.githooks/       # Git hooks (pre-commit, pre-push)
│   ├── scripts/            # Utility scripts
│   └── *.md                # Project documentation templates
├── global/             # Global templates (user home directory)
│   ├── AGENTS_global.md    # Global agent patterns
│   └── CLAUDE_global.md    # Global AI assistant guidelines
└── experimental/       # Experimental/legacy templates
    ├── agent/              # Agent configuration templates (legacy)
    └── ai_dev/             # AI dev/tmux orchestration experiments
```

## Quick Start

### Deploy a New Project

```bash
# Deploy project template to a new directory
./templates/project/setup_project.sh /path/to/workspace my-project-name

# This creates: /path/to/workspace/my-project-name/
# with all template files deployed and configured
```

### Initialize After Deployment

```bash
cd /path/to/workspace/my-project-name

# Interactive setup wizard (recommended)
make init

# Or non-interactive for automation
make init-cli
```

## Project Template

The main template at `templates/project/` provides:

- **DevContainer**: Docker-based development environment with Claude Code pre-installed
- **Agent System**: Subagent definitions, commands, and skills for AI collaboration
- **Git Workflow**: Hooks for branch protection, PR templates, GitHub Actions
- **Documentation**: CLAUDE.md, AGENTS.md, PLANS.md, RULES.md templates

### Key Commands (after deployment)

```bash
make help              # Show all available commands
make init              # Interactive setup wizard
make init-cli          # Non-interactive setup
make sync              # Sync agent configurations
make sync-codex-skills # Sync Codex skills
make check-env         # Verify environment configuration
```

## Global Templates

Templates in `templates/global/` are for user-level configuration:

- **AGENTS_global.md**: Global agent patterns available across all projects
- **CLAUDE_global.md**: Global AI assistant guidelines

These are symlinked to `~/.codex/` and `~/.claude/` in the DevContainer.

## Experimental Templates

The `templates/experimental/` directory contains:

- **agent/**: Legacy agent configuration templates
- **ai_dev/**: AI development tooling with tmux orchestration

These are preserved for reference but `templates/project/` is recommended for new projects.

## Adding New Templates

When adding new template categories:

1. Create a descriptive subdirectory (e.g., `templates/python/`, `templates/rust/`)
2. Add a README.md explaining the template's purpose
3. Include a setup/bootstrap script
4. Update this README with the new template category
5. Add corresponding Makefile targets if needed

## Related Directories

- **`config/`**: Personal environment configurations (tmux, vim, shell, etc.)
- **`git/`**: Git configuration and hooks for the dotfiles repo itself
