.PHONY: help init init-cli setup-hooks check-env sync gen-cursor-rules sync-check sync-codex-skills sync-upstream sync-upstream-check sync-upstream-status sync-upstream-dry-run push-to-upstream push-to-upstream-check push-to-upstream-status push-to-upstream-dry-run

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
	@echo "Sync (Local):"
	@echo "  make sync              # Generate + sync .agent -> .claude/.cursor"
	@echo "  make sync-check        # Sync then show git status"
	@echo "  make sync-codex-skills # Sync Codex skills from .agent to .codex/skills"
	@echo ""
	@echo "Sync (Upstream Template):"
	@echo "  make sync-upstream           # Sync from dotfiles template"
	@echo "  make sync-upstream-check     # Check for template differences"
	@echo "  make sync-upstream-status    # Show sync status"
	@echo "  make sync-upstream-dry-run   # Preview template sync"
	@echo ""
	@echo "Push to Upstream Template:"
	@echo "  make push-to-upstream           # Push local changes to dotfiles template"
	@echo "  make push-to-upstream-check     # Show what would be pushed (dry-run)"
	@echo "  make push-to-upstream-status    # Compare local vs upstream"
	@echo "  make push-to-upstream-dry-run   # Preview push without changes"
	@echo ""
	@echo "Options:"
	@echo "  VERBOSE=1 make init    # Show detailed command output and errors"
	@echo "  ./scripts/init-project.sh --help  # Show all init options"

# ============================================
# Initialization
# ============================================

# Interactive wizard (default for new projects)
init:
	@./scripts/boilerplate/init-project.sh wizard

# Non-interactive mode (for automation/CI)
init-cli:
	@./scripts/boilerplate/init-project.sh cli

# Set up git hooks only
setup-hooks:
	@./scripts/boilerplate/setup-git-hooks.sh

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
#	@./scripts/boilerplate/gen_cursor_rules_from_commands.py

# Full sync: sync agents to claude/cursor
#sync: gen-cursor-rules
sync:
	@./scripts/boilerplate/sync-agents.sh

# Sync then show git status
sync-check: sync
	@git status --porcelain

# Sync Codex skills from .agent/skills to .codex/skills
sync-codex-skills:
	@./scripts/boilerplate/sync-codex-skills.sh

# ============================================
# Upstream Template Sync
# ============================================

# Sync from upstream dotfiles template
sync-upstream:
	@./scripts/boilerplate/sync-upstream.sh

# Check for template differences
sync-upstream-check:
	@./scripts/boilerplate/sync-upstream.sh --check

# Show sync status
sync-upstream-status:
	@./scripts/boilerplate/sync-upstream.sh --status

# Preview template sync (dry-run)
sync-upstream-dry-run:
	@./scripts/boilerplate/sync-upstream.sh --dry-run

# ============================================
# Push to Upstream Template
# ============================================

# Push local changes to dotfiles template
push-to-upstream:
	@./scripts/boilerplate/push-to-upstream.sh

# Show what would be pushed (dry-run)
push-to-upstream-check:
	@./scripts/boilerplate/push-to-upstream.sh --check

# Compare local vs upstream
push-to-upstream-status:
	@./scripts/boilerplate/push-to-upstream.sh --status

# Preview push without changes
push-to-upstream-dry-run:
	@./scripts/boilerplate/push-to-upstream.sh --dry-run
