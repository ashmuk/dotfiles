# Multi-AI Coordination System

This directory (`.agent/`) is the **centralized source of truth** for AI tool configurations. Changes here propagate to Claude Code, Cursor IDE, and OpenAI Codex via `make sync`.

## Architecture Overview

### Complete File Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         UPSTREAM (~/dotfiles/templates/)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  global/                           project/                                 │
│  ├── AGENTS_global.md              ├── AGENTS_project.md                    │
│  └── CLAUDE_global.md              ├── CLAUDE_project.md                    │
│                                    ├── RULES.md                             │
│                                    ├── Makefile                             │
│                                    ├── dot.gitignore                        │
│                                    ├── dot.agent/                           │
│                                    │   ├── commands/                        │
│                                    │   ├── subagents/                       │
│                                    │   ├── skills/                          │
│                                    │   └── starters/                        │
│                                    │       ├── PROJECT.staged.yaml          │
│                                    │       ├── PROJECT.toolbox.yaml         │
│                                    │       ├── PLANS.md                     │
│                                    │       └── BACKLOG.md                   │
│                                    └── scripts/boilerplate/                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ make fetch-from-upstream
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROJECT ROOT (e.g., ~/projects/a2/)                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SYNCED FROM UPSTREAM (Tier 1 & 2)     │  PROJECT-SPECIFIC (never synced)  │
│  ──────────────────────────────────    │  ────────────────────────────────  │
│  AGENTS_global.md                      │                                    │
│  CLAUDE_global.md                      │                                    │
│  AGENTS.md                             │  PROJECT.yaml    ← created by init │
│  CLAUDE.md                             │  PLANS.md        ← if staged       │
│  RULES.md                              │  BACKLOG.md      ← if toolbox      │
│  Makefile                              │  docs/decisions/ADR-*.md           │
│  .gitignore                            │                                    │
│  .agent/                               │                                    │
│    ├── commands/                       │                                    │
│    ├── subagents/                      │                                    │
│    ├── skills/                         │                                    │
│    └── starters/                       │                                    │
│        ├── PROJECT.staged.yaml         │                                    │
│        ├── PROJECT.toolbox.yaml        │                                    │
│        ├── PLANS.md                    │                                    │
│        └── BACKLOG.md                  │                                    │
│  scripts/boilerplate/                  │                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ make init-staged  OR  make init-toolbox
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INITIALIZATION RESULT                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  make init-staged:                     make init-toolbox:                   │
│  ─────────────────                     ──────────────────                   │
│  .agent/starters/PROJECT.staged.yaml   .agent/starters/PROJECT.toolbox.yaml │
│           │                                     │                           │
│           ▼                                     ▼                           │
│  PROJECT.yaml (root)                   PROJECT.yaml (root)                  │
│                                                                             │
│  .agent/starters/PLANS.md              .agent/starters/BACKLOG.md           │
│           │                                     │                           │
│           ▼                                     ▼                           │
│  PLANS.md (root)                       BACKLOG.md (root)                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ make sync
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AI TOOL CONFIGURATIONS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  .agent/                                                                    │
│     │                                                                       │
│     ├──────────────────┬────────────────────┬──────────────────────┐        │
│     ▼                  ▼                    ▼                      ▼        │
│  .claude/           .cursor/rules/       .codex/                            │
│  ├── agents/        ├── agents/          ├── AGENTS.override.md             │
│  ├── commands/      └── skills/          └── skills/                        │
│  └── skills/                                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
.agent/
├── README.md           # This file
├── commands/           # Git workflow commands (Claude Code slash commands)
│   ├── commit.md       # /commit - Stage and commit with generated message
│   ├── push.md         # /push - Push with safety checks
│   ├── pr.create.md    # /pr.create - Create PR with generated description
│   ├── devcontainer.up.md
│   ├── devcontainer.down.md
│   └── devcontainer.rebuild.md
├── skills/             # Workflow skills (multi-step tasks)
│   ├── define.md       # /define - Requirements gathering
│   ├── design.md       # /design - Architecture and planning
│   ├── implement.md    # /implement - Build software
│   ├── review.md       # /review - Validate and review
│   └── adr.md          # /adr - Create Architecture Decision Records
├── subagents/          # Agent definitions
│   ├── analyst.md      # System analysis, planning, risk identification
│   ├── architect.md    # Technology decisions, trade-offs
│   ├── builder.md      # Implementation specialist
│   └── reviewer.md     # Code review, security validation
└── starters/           # Project initialization templates
    ├── PROJECT.staged.yaml   # For staged development projects
    ├── PROJECT.toolbox.yaml  # For ad-hoc toolbox projects
    ├── PLANS.md              # Roadmap template (staged)
    └── BACKLOG.md            # Task queue template (toolbox)
```

## Dual-Mode Project Characters

This template supports two project characters via `PROJECT.yaml`:

```
One Template → Two Characters → Same Infrastructure

┌──────────────────────────────────────────────────────────────┐
│                     SHARED INFRASTRUCTURE                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐             │
│  │ Agents  │ │Commands │ │ Skills  │ │  ADRs   │             │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐             │
│  │Git Cmds │ │DevCtnr  │ │make sync│ │ RULES   │             │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘             │
├──────────────────────────────────────────────────────────────┤
│                     PROJECT.yaml                              │
│              ┌─────────────┴─────────────┐                   │
│              ▼                           ▼                   │
│     character: staged           character: toolbox           │
│     ┌─────────────────┐         ┌─────────────────┐          │
│     │ Linear stages   │         │ Ad-hoc tasks    │          │
│     │ PLANS.md        │         │ BACKLOG.md      │          │
│     │ Deployment gate │         │ Ship anytime    │          │
│     │ Full workflow   │         │ Scale to size   │          │
│     └─────────────────┘         └─────────────────┘          │
└──────────────────────────────────────────────────────────────┘
```

### Staged Projects

For linear, single-deliverable development:

```yaml
# PROJECT.yaml
version: 1
character: staged

staged:
  current_stage: 1
  deployment_gate: 5
  roadmap_file: PLANS.md
```

- Follows stages: Analysis → Asset Collection → Architecture → Implementation → Enhancement
- Uses `PLANS.md` for roadmap tracking
- Deployment blocked until specified stage

### Toolbox Projects

For ad-hoc tools, plugins, and experiments:

```yaml
# PROJECT.yaml
version: 1
character: toolbox

toolbox:
  backlog_file: BACKLOG.md
  shipping: continuous
```

- No stages, no gates
- Uses `BACKLOG.md` for task tracking
- Workflow scales to task size:
  - Small (1 file, <50 LOC): `/implement` directly
  - Medium (2-5 files, 50-500 LOC): `/design` → `/implement`
  - Large (cross-cutting, >500 LOC): Full workflow

## Quick Start

### Initialize Project Character

```bash
# For ad-hoc projects (plugins, tools, experiments)
make init-toolbox

# For staged development (single deliverable)
make init-staged

# Check current character
make show-character
```

### Sync to AI Tools

```bash
# Propagate .agent/ to .claude/, .cursor/, .codex/
make sync

# Check sync status
make sync-check
```

### Update from Upstream Template

```bash
# Fetch updates from ~/dotfiles/templates/
make fetch-from-upstream

# Check for differences first
make fetch-from-upstream-check

# Push local improvements back to template
make push-to-upstream
```

## File Protection Matrix

| File | Synced from Upstream? | Protected? |
|------|----------------------|------------|
| `.agent/*` | Yes | No - template files |
| `PROJECT.yaml` | Never | Yes - project-specific |
| `PLANS.md` | Never | Yes - project-specific |
| `BACKLOG.md` | Never | Yes - project-specific |
| `docs/decisions/*` | Never | Yes - project-specific |

## AI Agent Logic

When AI agents read this project, they follow this logic:

```
┌─────────────────────────────────┐
│ Read PROJECT.yaml               │
│         │                       │
│         ▼                       │
│   File exists?                  │
│    │         │                  │
│   Yes        No                 │
│    │         │                  │
│    ▼         ▼                  │
│  Parse    Assume               │
│  character  "staged"            │
│             (default)           │
└─────────────────────────────────┘
```

- If `PROJECT.yaml` exists: Use declared character
- If missing: Default to `staged` (backwards compatible)
