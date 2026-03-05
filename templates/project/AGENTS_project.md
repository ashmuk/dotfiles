# AGENTS.md — Repo Guide (Entry Point)

> This file is intentionally short. Detailed rules and current plans live in:
> - RULES.md (stable policy)
> - PLANS.md, if present (current stage, tasks, progress)
> - BACKLOG.md, if present

## Project
- Follow README.md and {PLANS.md, BACKLOG.md} for current work
- See RULES.md for stable policy

## Where things live (repo map)
**📖 See Repository Structure in [README.md](./README.md)**

## Available agents
- analyst — Analyze systems, break down work, identify risks, plan execution
- architect — Technology choices, trade-offs, ADR documentation
- builder — Implement code, scripts, CI/CD, infrastructure, collect assets
- reviewer — Code review, security, safety escalation, integrity verification

## Agent-Skill Coverage Matrix

| Skill | Primary Agent | Co-working Built-in | Reviewer Gate | Escalation |
|-------|--------------|---------------------|---------------|------------|
| `/define` | analyst | Explore | reviewer | — |
| `/design` | architect | Plan | reviewer | — |
| `/test` | analyst | — | reviewer | implement (builder) |
| `/implement` | builder | general-purpose | reviewer | — |
| `/review` | reviewer | — | (self) | — |
| `/remediate` | builder | — | reviewer | architect (systemic) |
| `/adr` | (template) | — | — | — |

**Workflow chain:** `define(analyst) → design(architect) → test(analyst) → implement(builder) → review(reviewer) → remediate(builder+reviewer)`

## Quick commands
### Agent/AI workflows
- Sync: `make sync` (generate + sync .agent → .claude/.cursor)
- Check: `make sync-check` (sync + show git status)
- Skills: `make sync-codex-skills` (sync Codex skills)

### DevContainer
- Start: `devcontainer up --workspace-folder .`
- Stop: `devcontainer down --workspace-folder .`
- Rebuild: `devcontainer up --workspace-folder . --remove-existing-container --build-no-cache`

> **Note**: `claude-hard` alias (dangerous mode) is only available inside DevContainer

### Slash Commands (Claude Code)
Available slash commands for common workflows:

**Git workflows:**
- `/commit` — Stage changes and create conventional commit
- `/push` — Push changes with safety checks
- `/pr.create` — Create pull request with generated description

**DevContainer lifecycle:**
- `/devcontainer.up` — Start development environment
- `/devcontainer.down` — Stop development environment
- `/devcontainer.rebuild` — Rebuild environment from scratch

**Naming convention:** Dot notation for namespaces (e.g., `namespace.action`)
**Structure:** Flat files in `.claude/commands/*.md` (like agents, not nested like skills)
**Source of truth:** `.agent/commands/` → synced to `.claude/commands/` via `make sync`

## How to work in this repo
1) Read RULES.md and {PLANS.md, BACKLOG.md}
2) Use analyst agent to understand situation and plan work
3) Use architect agent for technology decisions (creates ADRs)
4) Use builder agent to implement changes
5) Use reviewer agent to verify before commit
