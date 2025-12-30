.PHONY: help sync gen-cursor-rules sync-check sync-codex-skills

help:
	@echo "Targets:"
	@echo "  make sync                # generate + sync .agent -> .claude/.cursor"
	@echo "  make sync-check          # sync then show git status"
	@echo "  make sync-codex-skills   # sync Codex skills from .agent to .codex/skills"

gen-cursor-rules:
	@./scripts/gen_cursor_rules_from_commands.py

sync: gen-cursor-rules
	@./scripts/sync-agents.sh

sync-check: sync
	@git status --porcelain

# Sync Codex skills from .agent/skills or .agent/codex/skills to .codex/skills
sync-codex-skills:
	@./scripts/sync-codex-skills.sh
