.PHONY: help init init-cli setup-hooks check-env sync gen-cursor-rules sync-check sync-codex-skills

# ============================================
# Help
# ============================================
help:
	@echo "Project Management Commands"
	@echo ""
	@echo "Initialization:"
	@echo "  make init              # Interactive setup wizard (recommended for new projects)"
	@echo "  make init-cli          # Non-interactive setup (for automation/CI)"
	@echo "  make setup-hooks       # Set up git hooks only"
	@echo "  make check-env         # Verify environment configuration"
	@echo ""
	@echo "Sync:"
	@echo "  make sync              # Generate + sync .agent -> .claude/.cursor"
	@echo "  make sync-check        # Sync then show git status"
	@echo "  make sync-codex-skills # Sync Codex skills from .agent to .codex/skills"

# ============================================
# Initialization
# ============================================

# Interactive wizard (default for new projects)
init:
	@./scripts/init-project.sh wizard

# Non-interactive mode (for automation/CI)
init-cli:
	@./scripts/init-project.sh cli

# Set up git hooks only
setup-hooks:
	@./scripts/setup-git-hooks.sh

# Verify environment is configured
check-env:
	@echo "Checking environment configuration..."
	@if [ -f .env ]; then \
		echo "✓ .env file exists"; \
		missing=0; \
		while IFS= read -r line; do \
			if echo "$$line" | grep -q "^[A-Z_]*=$$"; then \
				var=$$(echo "$$line" | cut -d= -f1); \
				echo "⚠ $$var is not set"; \
				missing=1; \
			fi; \
		done < .env; \
		if [ $$missing -eq 0 ]; then \
			echo "✓ All variables appear to be set"; \
		else \
			echo ""; \
			echo "Edit .env to set missing values"; \
		fi; \
	else \
		echo "✗ .env file not found"; \
		echo "  Run: cp .env.example .env"; \
	fi

# ============================================
# Sync
# ============================================

# Generate Cursor rules from .agent/commands (pending - needs redesign)
#gen-cursor-rules:
#	@./scripts/gen_cursor_rules_from_commands.py

# Full sync: sync agents to claude/cursor
#sync: gen-cursor-rules
sync:
	@./scripts/sync-agents.sh

# Sync then show git status
sync-check: sync
	@git status --porcelain

# Sync Codex skills from .agent/skills to .codex/skills
sync-codex-skills:
	@./scripts/sync-codex-skills.sh
