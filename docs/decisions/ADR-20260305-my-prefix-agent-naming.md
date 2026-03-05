# ADR-20260305: Add `my-` Prefix to Custom Agent Definitions

## Status
- Accepted

## Context
- Custom agent definitions (`analyst`, `architect`, `builder`, `reviewer`) collide with Claude Code's built-in `subagent_type` names
- The previous ADR (ADR-20260305-refine-agent-skills-ecosystem) established `cc-` prefix for custom skills/commands to avoid namespace collisions in the shared `/` namespace
- Agent names live in a separate `subagent_type` namespace but the collision causes ambiguity: when code references "analyst agent", it's unclear whether it means the built-in or custom definition
- A consistent prefix convention is needed to distinguish custom artifacts from built-in ones

## Options Considered

### Option A: `my-` prefix for custom agents
- **Pros**: Short, intuitive, clearly signals "user-defined"; follows `cc-` pattern for a different artifact type; `my-` = personas, `cc-` = actions
- **Cons**: Slightly longer agent names in documentation
- **Effort**: Low — rename 4 files, update references

### Option B: `cc-` prefix for agents too
- **Pros**: Single prefix for everything
- **Cons**: Loses semantic distinction between personas (agents) and actions (skills/commands); agents and skills would look identical in references
- **Effort**: Low

### Option C: Do nothing
- **Pros**: No changes
- **Cons**: Continued namespace collision with built-in agent types; ambiguous references in documentation and skill files

## Decision
We choose **Option A** — `my-` prefix for custom agents, keeping `cc-` for skills/commands.

### Naming Convention Summary
| Artifact Type | Prefix | Namespace | Examples |
|---------------|--------|-----------|----------|
| Skills | `cc-` | Shared `/` (slash commands) | `cc-define`, `cc-review` |
| Commands | `cc-` | Shared `/` (slash commands) | `cc-commit`, `cc-push` |
| Agents | `my-` | `subagent_type` | `my-analyst`, `my-builder` |

### Changes Made
| # | Action | File |
|---|--------|------|
| 1 | RENAME | `subagents/analyst.md` → `subagents/my-analyst.md` |
| 2 | RENAME | `subagents/architect.md` → `subagents/my-architect.md` |
| 3 | RENAME | `subagents/builder.md` → `subagents/my-builder.md` |
| 4 | RENAME | `subagents/reviewer.md` → `subagents/my-reviewer.md` |
| 5 | UPDATE | All skill files — agent references updated to `my-` prefix |
| 6 | UPDATE | CLAUDE.md, AGENTS.md, ARCHITECTURE.md — agent references |
| 7 | UPDATE | Template CLAUDE_project.md, AGENTS_project.md |
| 8 | UPDATE | ADR-20260305-refine-agent-skills-ecosystem.md — agent references |
| 9 | UPDATE | Zenn article — directory structure diagram |

## Rationale
- **Semantic clarity**: `my-` = custom personas (who), `cc-` = custom actions (what)
- **Separate namespaces**: Agents use `subagent_type`, skills/commands use `/` prefix — different prefixes reinforce this
- **Disambiguation**: References to "my-analyst agent" are unambiguously custom; "analyst" could mean built-in
- **Sync compatibility**: Dynamic glob patterns in sync scripts (`*.md`) work without code changes

## Consequences

### Positive
- No more ambiguity between custom and built-in agent types
- Consistent naming convention across all custom artifacts
- Downstream projects benefit from clearer agent references after `make sync`

### Negative
- Documentation references are slightly longer (`my-analyst` vs `analyst`)
- One-time migration cost for downstream projects

### Rollback Plan
- Rename files back, revert documentation changes
- Downstream projects re-run `make sync`

## References
- ADR-20260305-refine-agent-skills-ecosystem (established `cc-` prefix pattern)
- Claude Code built-in agent types: `analyst`, `architect`, `builder`, `reviewer`, `Explore`, `Plan`, `general-purpose`
