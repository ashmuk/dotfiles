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
- my-analyst — Analyze systems, break down work, identify risks, plan execution
- my-architect — Technology choices, trade-offs, ADR documentation
- my-builder — Implement code, scripts, CI/CD, infrastructure, collect assets
- my-reviewer — Code review, security, safety escalation, integrity verification

## Agent-Skill Coverage Matrix

| Skill | Primary Agent | Co-working Built-in | Reviewer Gate | Escalation |
|-------|--------------|---------------------|---------------|------------|
| `/cc-define` | my-analyst | Explore | my-reviewer | — |
| `/cc-design` | my-architect | Plan | my-reviewer | — |
| `/cc-test` | my-analyst | — | my-reviewer | implement (my-builder) |
| `/cc-implement` | my-builder | general-purpose | my-reviewer | — |
| `/cc-review` | my-reviewer | — | (self) | — |
| `/cc-remediate` | my-builder | — | my-reviewer | my-architect (systemic) |
| `/cc-adr` | (template) | — | — | — |

**Workflow chain:** `cc-define(my-analyst) → cc-design(my-architect) → cc-test(my-analyst) → cc-implement(my-builder) → cc-review(my-reviewer) → cc-remediate(my-builder+my-reviewer)`

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
- `/cc-commit` — Stage changes and create conventional commit
- `/cc-push` — Push changes with safety checks
- `/cc-pr-create` — Create pull request with generated description

**DevContainer lifecycle:**
- `/cc-devcontainer-up` — Start development environment
- `/cc-devcontainer-down` — Stop development environment
- `/cc-devcontainer-rebuild` — Rebuild environment from scratch

**Naming convention:** `cc-` prefix with hyphen-separated namespaces (e.g., `cc-namespace-action`)
**Structure:** Flat files in `.claude/commands/*.md` (like agents, not nested like skills)
**Source of truth:** `.agent/commands/` → synced to `.claude/commands/` via `make sync`

## How to work in this repo
1) Read RULES.md and {PLANS.md, BACKLOG.md}
2) Use my-analyst agent to understand situation and plan work
3) Use my-architect agent for technology decisions (creates ADRs)
4) Use my-builder agent to implement changes
5) Use my-reviewer agent to verify before commit
