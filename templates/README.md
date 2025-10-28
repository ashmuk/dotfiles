# Templates Directory

This directory contains reusable templates for bootstrapping new projects and environments.

## Directory Structure

```
templates/
└── agent/              # AI agent configuration templates
    ├── CLAUDE.md       # Project policy template for Claude Code
    ├── AGENTS.md       # Agent role definitions
    ├── codex/          # Codex AI runtime configuration
    ├── cursor/         # Cursor IDE templates
    ├── prompts/        # Shared prompt templates
    ├── mcp/            # Model Context Protocol tool definitions
    └── setup_agent.sh  # Bootstrap script for deploying templates
```

## Usage

### Agent Templates

AI agent templates provide standardized configuration for AI coding assistants across projects.

**Install to your system:**
```bash
make install-agent
# Creates symlinks in ~/.config/agent/ for reference
```

**Deploy to a new project:**
```bash
# Option 1: Use the bootstrap script directly
~/dotfiles/templates/agent/setup_agent.sh /path/to/your-project

# Option 2: Use with AI dev template
~/dotfiles/ai_dev/sample_template/setup_template.sh /path/to/your-project
```

See [templates/agent/README_agent.md](agent/README_agent.md) for detailed documentation.

## Adding New Templates

When adding new template categories to this directory:

1. Create a descriptive subdirectory (e.g., `templates/docker/`, `templates/ci/`)
2. Add a README.md explaining the template's purpose
3. Include a setup/bootstrap script if applicable
4. Update this README with the new template category
5. Add corresponding Makefile targets if needed

## Related Directories

- **`config/`** - Personal environment configurations (tmux, vim, shell, etc.)
- **`ai_dev/`** - AI development tooling and project templates
- **`templates/`** - Reusable templates for distribution to projects (you are here)
