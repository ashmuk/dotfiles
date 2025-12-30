# AGENTS.md — Repo Guide (Entry Point)

> This file is intentionally short. Detailed rules and current plans live in:
> - RULES.md (stable policy)
> - PLANS.md (current stage, tasks, progress)

## Project
- Follow README.md, PLANS.md and RULES.md

## Where things live (repo map)
- assets_legacy/        # legacy assets (read-only)
- docs/analytics/       # reports (JSON/MD)
- docs/decisions/       # ADRs / decisions

## Quick commands
### Agent/AI workflows
- Sync: `make sync` (generate + sync .agent → .claude/.cursor)
- Check: `make sync-check` (sync + show git status)
- Skills: `make sync-codex-skills` (sync Codex skills)

### DevContainer
- Start: `devcontainer up --workspace-folder .`
- Stop: `devcontainer down --workspace-folder .`
- Rebuild: `devcontainer up --workspace-folder . --remove-existing-container --build-no-cache`

### Project-specific (add your own)
- Setup: `...` (e.g., `npm install`, `pip install -r requirements.txt`)
- Lint: `...` (e.g., `npm run lint`, `ruff check`)
- Test: `...` (e.g., `npm test`, `pytest`)
- Build: `...` (e.g., `npm run build`, `docker build`)

## How to work in this repo
1) Read RULES.md and PLANS.md
2) Propose a small plan aligned with PLANS stage
3) Implement minimal changes
4) Verify (lint/test) + update docs if needed
