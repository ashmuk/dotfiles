# AGENTS.md — Repo Guide (Entry Point)

> This file is intentionally short. Detailed rules and current plans live in:
> - RULES.md (stable policy)
> - PLANS.md (current stage, tasks, progress)

## Project
- Follow README.md and PLANS.md for current work
- See RULES.md for stable policy

## Where things live (repo map)
**📖 See Repository Structure in [README.md](./README.md)**

## Available agents
- analyst — Analyze systems, break down work, identify risks, plan execution
- architect — Technology choices, trade-offs, ADR documentation
- builder — Implement code, scripts, CI/CD, infrastructure, collect assets
- reviewer — Code review, security, safety escalation, integrity verification

## Quick commands
### Agent/AI workflows
- Sync: `make sync` (generate + sync .agent → .claude/.cursor)
- Check: `make sync-check` (sync + show git status)
- Skills: `make sync-codex-skills` (sync Codex skills)

### DevContainer
- Start: `devcontainer up --workspace-folder .`
- Stop: `devcontainer down --workspace-folder .`
- Rebuild: `devcontainer up --workspace-folder . --remove-existing-container --build-no-cache`

## How to work in this repo
1) Read RULES.md and PLANS.md
2) Use analyst agent to understand situation and plan work
3) Use architect agent for technology decisions (creates ADRs)
4) Use builder agent to implement changes
5) Use reviewer agent to verify before commit
