.PHONY: help sync gen-cursor-rules sync-check sync-codex-skills

help:
	@echo "Targets:"
	@echo "  make sync                # generate + sync .agent -> .claude/.cursor"
	@echo "  make sync-check          # sync then show git status"
	@echo "  make sync-codex-skills   # (optional) sync Codex skills to ~/.codex/skills"

gen-cursor-rules:
	@./scripts/gen_cursor_rules_from_commands.py

sync: gen-cursor-rules
	@./scripts/sync-agents.sh

sync-check: sync
	@git status --porcelain

# Optional: local-machine Codex skills sync
# Override destination with: make sync-codex-skills CODEX_SKILLS_DIR=/path/to/skills
CODEX_SKILLS_DIR ?= $(HOME)/.codex/skills
sync-codex-skills:
	@./scripts/sync-codex-skills.sh "$(CODEX_SKILLS_DIR)"
