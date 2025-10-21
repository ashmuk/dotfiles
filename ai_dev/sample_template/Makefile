.PHONY: setup run test lint format clean aider-plan aider-refactor ci-local health-check
.PHONY: claude-session-create claude-session-list claude-session-kill
.PHONY: claude-pane-create claude-pane-exec claude-pane-capture claude-demo

# Setup - Install dependencies in virtual environment
setup:
	@if [ -d "/home/ashmuk/.venv" ]; then \
		/home/ashmuk/.venv/bin/pip install -U pip; \
		/home/ashmuk/.venv/bin/pip install -U fastapi uvicorn pytest ruff httpx aider-chat coverage pre-commit; \
	else \
		echo "Virtual environment not found. Run postCreateCommand first."; \
		exit 1; \
	fi

# Run the application
run:
	uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Test
test:
	pytest -v --cov

# Linting
lint:
	ruff check .

# Format code
format:
	ruff format .

# Clean build artifacts
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .ruff_cache .coverage htmlcov

# Hard clean - Remove all AI dev template files (destructive!)
clean-hard: clean
	@echo ""
	@printf "\033[0;31m[DANGER]\033[0m This will remove ALL AI development template files!\n"
	@printf "\033[0;31m[DANGER]\033[0m This includes project files, configurations, and caches!\n"
	@printf "\033[1;33m[WARNING]\033[0m Files to be removed:\n"
	@echo "  - Directories: .cache .claude .codex .coverage .cursor .devcontainer .github .pytest_cache .vscode app prompts scripts tests mcp"
	@echo "  - Files: .gitignore .pre-commit-config.yaml AGENTS.md CLAUDE.md ai_dev.yml Makefile requirements.txt .aider* .ai_dev*.yml"
	@echo ""
	@printf "\033[0;31mAre you ABSOLUTELY sure? Type 'yes' to confirm: \033[0m"; \
	read confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo ""
	@printf "\033[0;34m[INFO]\033[0m Removing AI dev template directories...\n"
	@rm -rf .cache .claude .codex .coverage .cursor .devcontainer .github .pytest_cache .vscode app prompts scripts tests mcp
	@printf "\033[0;34m[INFO]\033[0m Removing AI dev template configuration files...\n"
	@rm -f .gitignore .pre-commit-config.yaml AGENTS.md CLAUDE.md ai_dev.yml Makefile requirements.txt
	@printf "\033[0;34m[INFO]\033[0m Removing aider configuration files...\n"
	@rm -f .aider* .ai_dev*.yml
	@printf "\033[0;32m[SUCCESS]\033[0m Hard cleanup completed\n"
	@echo ""
	@printf "\033[1;33m[NEXT ACTIONS]\033[0m Recommended cleanup steps:\n"
	@echo "  1. Check git log to review recent commits:"
	@printf "     \033[0;34mgit log --oneline -10\033[0m\n"
	@echo ""
	@echo "  2. If you need to remove recent commits, use:"
	@printf "     \033[0;34mgit reset --soft HEAD~n\033[0m  # Keep changes staged\n"
	@printf "     \033[0;34mgit reset --mixed HEAD~n\033[0m # Keep changes unstaged (default)\n"
	@printf "     \033[0;34mgit reset --hard HEAD~n\033[0m  # Discard all changes (destructive!)\n"
	@echo ""
	@echo "  3. Check for remaining template files:"
	@printf "     \033[0;34mgit status\033[0m\n"
	@echo ""
	@echo "  4. If satisfied, force push to remote (if needed):"
	@printf "     \033[0;34mgit push --force-with-lease\033[0m\n"
	@echo ""
	@printf "\033[1;33m[TIP]\033[0m Replace 'n' with the number of commits to undo\n"

# AI Development Tasks
aider-plan:
	aider --message "Scan the repo and create a test plan at tests/TESTPLAN.md focusing on API health and CRUD coverage" --yes

aider-refactor:
	aider --yes \
		--read prompts/refactor.md \
		app/main.py \
		tests/test_health.py \
		--message "Refactor app/main.py to add /todos endpoints with in-memory store and make tests pass. Create tests/test_main.py with tests for the new endpoints. Keep style with ruff."

# Local CI with act
ci-local:
	act pull_request -j check

# Health check
health-check:
	./.devcontainer/health-check.sh

# Pre-commit hooks
pre-commit-install:
	pre-commit install

pre-commit-run:
	pre-commit run --all-files

# ============================================================================
# Claude-tmux Integration (MVP)
# ============================================================================

# Bridge script path
BRIDGE = ./scripts/claude-tmux-bridge.sh

# Session management
claude-session-create:
	@if [ -z "$(SESSION)" ]; then \
		echo "Usage: make claude-session-create SESSION=<name>"; \
		exit 1; \
	fi
	@$(BRIDGE) session-create $(SESSION)

claude-session-list:
	@$(BRIDGE) session-list

claude-session-kill:
	@if [ -z "$(SESSION)" ]; then \
		echo "Usage: make claude-session-kill SESSION=<name>"; \
		exit 1; \
	fi
	@$(BRIDGE) session-kill $(SESSION)

# Pane management
claude-pane-create:
	@if [ -z "$(SESSION)" ]; then \
		echo "Usage: make claude-pane-create SESSION=<name> LABEL=<label>"; \
		exit 1; \
	fi
	@$(BRIDGE) pane-create $(SESSION) $(LABEL)

claude-pane-exec:
	@if [ -z "$(SESSION)" ] || [ -z "$(PANE)" ] || [ -z "$(CMD)" ]; then \
		echo "Usage: make claude-pane-exec SESSION=<name> PANE=<id> CMD='<command>'"; \
		exit 1; \
	fi
	@$(BRIDGE) pane-exec $(SESSION) $(PANE) "$(CMD)"

claude-pane-capture:
	@if [ -z "$(SESSION)" ] || [ -z "$(PANE)" ]; then \
		echo "Usage: make claude-pane-capture SESSION=<name> PANE=<id> [LINES=20]"; \
		exit 1; \
	fi
	@$(BRIDGE) pane-capture $(SESSION) $(PANE) $(LINES)

# Demo: Complete workflow
claude-demo:
	@echo "=== Claude-tmux MVP Demo ==="
	@echo ""
	@echo "Step 1: Creating session 'demo-session'..."
	@$(BRIDGE) session-create demo-session
	@sleep 1
	@echo ""
	@echo "Step 2: Creating additional panes..."
	@$(BRIDGE) pane-create demo-session tests
	@$(BRIDGE) pane-create demo-session logs
	@sleep 1
	@echo ""
	@echo "Step 3: Executing commands in panes..."
	@$(BRIDGE) pane-exec demo-session 0 "echo 'Server pane: make run would go here'"
	@$(BRIDGE) pane-exec demo-session 1 "echo 'Tests pane: make test would go here'"
	@$(BRIDGE) pane-exec demo-session 2 "echo 'Logs pane: tail -f logs/app.log'"
	@sleep 2
	@echo ""
	@echo "Step 4: Capturing pane outputs..."
	@$(BRIDGE) pane-capture demo-session 0 5
	@echo ""
	@$(BRIDGE) pane-capture demo-session 1 5
	@echo ""
	@echo "Step 5: Session info..."
	@$(BRIDGE) session-list
	@echo ""
	@echo "=== Demo complete! ==="
	@echo "To attach: tmux attach -t demo-session"
	@echo "To kill: make claude-session-kill SESSION=demo-session"
