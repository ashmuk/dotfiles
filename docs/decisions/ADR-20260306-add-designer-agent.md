# ADR-20260306: Add my-designer Sub-Agent

## Status
- Accepted

## Context
- No existing agent owns design work — neither UX/UI design nor backend/API design
- `my-architect` handles strategic decisions and ADRs but not detailed design of how things look, feel, or interface
- `my-analyst` extracts design signals (read-only observation) but does not create design specs
- Design is a distinct discipline from strategic architecture — mixing them dilutes both responsibilities
- The gap exists for both frontend (UX/UI, Apple HIG, accessibility) and backend (API contracts, data modeling, DX)

## Decision Drivers
- Design needs a dedicated owner that creates prescriptive specs (not just observations)
- Architecture decisions (what technology) should remain separate from design decisions (how it looks/feels/interfaces)
- A single agent covering both UX and API design avoids fragmentation while recognizing the unified discipline

## Options Considered

### Option A: Add new my-designer agent (single agent for UX + API design)
- **Pros**: Clear ownership; design is a distinct discipline; single agent avoids fragmentation; covers full design surface (UX, API, accessibility)
- **Cons**: Adds a 5th agent; increases token budget (~750 tokens)
- **Effort**: Low

### Option B: Expand my-architect to include design
- **Pros**: No new agent; reuses existing role
- **Cons**: Overloads architect with two distinct disciplines; strategic decisions and design details have different workflows; architect grows too large
- **Effort**: Low

### Option C: Split into separate frontend and backend design agents
- **Pros**: Deep specialization per domain
- **Cons**: Over-fragmentation for most projects; coordination overhead between two design agents; many projects need only one side
- **Effort**: Medium

## Decision
We choose **Option A** — add a single `my-designer` agent covering both UX/UI and backend/API design.

Design is a distinct discipline from strategic architecture. my-architect decides *what technology*; my-designer decides *how it looks, feels, and interfaces*. Keeping them separate preserves clean responsibility boundaries.

### Resulting Agent Set
```
my-analyst   -> understand & plan
my-architect -> strategic decisions & ADRs
my-designer  -> all design (UX + backend + API)
my-builder   -> implement everything
my-reviewer  -> verify everything
```

### Changes Made

| # | Action | File |
|---|--------|------|
| 1 | CREATE | `templates/project/dot.agent/subagents/my-designer.md` |
| 2 | MODIFY | `templates/project/dot.agent/skills/cc-design.md` (add Phase B for UX/API Design) |
| 3 | MODIFY | `templates/project/AGENTS_project.md` (register agent + update matrices) |
| 4 | MODIFY | `templates/project/CLAUDE_project.md` (register agent in docs) |
| 5 | MOVE | `templates/global/prompts/design/` → `templates/project/dot.agent/prompts/design/` (3 design prompt templates) |

### cc-design Workflow Integration
Phase B (UX/UI & API Design) inserted between Phase A (Architecture) and Phase C (System Design):
```
Phase A: Architecture → Phase B: UX/API Design → Phase C: System Design → Phase D: Task Breakdown → Phase E: Planning
```

Phase B adapts to project context (frontend-only, backend-only, full-stack, or skip).

Design prompt templates (design systems, critique, UI/UX patterns) moved from `templates/global/prompts/design/` into `.agent/prompts/design/` for direct reference during Phase B.

## Consequences

- Positive:
  - Design has a dedicated owner with clear scope
  - Architecture and design remain cleanly separated
  - Phase B ensures design decisions feed into system design (Phase C)
  - Single agent avoids fragmentation while covering both UX and API design
  - Rich design prompts integrated into SDLC workflow via `.agent/prompts/design/`
- Negative / Risks:
  - 5th agent increases cognitive load for users learning the system
  - Token budget impact:
    - **Per-session (always loaded):** ~1,375 tokens (my-designer subagent — largest of all agents at ~5.5KB vs ~3KB average)
    - **Per `/cc-design` invocation:** ~25 additional tokens (1 extra step in Phase B)
    - **On-demand (Phase B only):** ~3,160 tokens when designer reads `.agent/prompts/design/` (3 prompt files, not auto-loaded)
- Mitigations:
  - Phase B can be skipped if project has no UI or API design needs
  - Agent description clearly delineates boundary with my-analyst and my-architect
- Rollback plan:
  - Delete my-designer.md, revert cc-design.md and documentation changes; downstream projects re-run `make sync`

## Relationship to Prior ADRs
- Partially supersedes "4 agents are sufficient" conclusion from ADR-20260305-refine-agent-skills-ecosystem
- That ADR's coverage matrix validated no gap for *skills*; this ADR identifies a gap in the *agent* layer for design ownership

## References
- Boundary: my-analyst *extracts* signals (read-only); my-designer *creates* specs (prescriptive)
- Boundary: my-architect decides *what technology*; my-designer decides *how it looks/feels/interfaces*
