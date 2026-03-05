# ADR-20260305: Add `cc-` Prefix to All Custom Slash Commands

## Status
Accepted

## Context
Claude Code ships 77+ built-in slash commands. Our custom skill `/review` directly conflicts with the built-in `/review` (PR review) command. Other generic names (`/test`, `/commit`, `/push`) risk future collisions as Claude Code adds more built-in commands. Tab-completion is also hindered when custom and built-in names overlap.

## Options Considered

### Option 1: Prefix all custom commands with `cc-`
- **Description**: Rename every custom slash command (skills + commands) with a `cc-` prefix. Replace dots with hyphens for tab-completion friendliness.
- **Pros**: Eliminates all current and future conflicts; easy to identify custom vs built-in; tab-complete `cc-` shows only custom commands
- **Cons**: Longer names; existing muscle memory needs updating
- **Effort**: Low (file renames + reference updates)

### Option 2: Rename only conflicting commands
- **Description**: Only rename `/review` and other confirmed conflicts
- **Pros**: Minimal disruption
- **Cons**: Reactive; future conflicts inevitable; inconsistent naming
- **Effort**: Low

### Option 3: Use a different prefix or namespace
- **Description**: Use project-specific prefix (e.g., `/dot-`) or longer namespace
- **Pros**: More specific to this project
- **Cons**: Not transferable to other projects using the same template system
- **Effort**: Low

## Decision
Option 1 — prefix all custom slash commands with `cc-` (short for "Claude Code custom").

## Rationale
- Holistic approach prevents future conflicts without case-by-case decisions
- `cc-` is short enough to not impede usability
- Tab-completing `cc-` instantly filters to all custom commands
- Dots replaced with hyphens (`pr.create` → `cc-pr-create`) for better tab-completion

## Naming Map

| Type | Old Name | New Name |
|------|----------|----------|
| Skill | `/define` | `/cc-define` |
| Skill | `/design` | `/cc-design` |
| Skill | `/test` | `/cc-test` |
| Skill | `/implement` | `/cc-implement` |
| Skill | `/review` | `/cc-review` |
| Skill | `/remediate` | `/cc-remediate` |
| Skill | `/adr` | `/cc-adr` |
| Command | `/commit` | `/cc-commit` |
| Command | `/push` | `/cc-push` |
| Command | `/pr.create` | `/cc-pr-create` |
| Command | `/devcontainer.up` | `/cc-devcontainer-up` |
| Command | `/devcontainer.down` | `/cc-devcontainer-down` |
| Command | `/devcontainer.rebuild` | `/cc-devcontainer-rebuild` |

## Consequences

### Positive
- Zero namespace conflicts with built-in commands
- Clear visual distinction between custom and built-in commands
- `cc-<TAB>` shows all custom commands at once
- Convention is transferable to downstream projects using the template

### Negative
- Users must re-learn command names (one-time cost)
- All documentation references needed updating

### Rollback
- Revert the commit to restore old filenames and references
- Run `make sync` to regenerate symlinks in downstream projects
- Low risk: no data migration involved, purely file renames and documentation updates

## Implementation Notes
- Source files renamed in `templates/project/dot.agent/{skills,commands}/`
- Symlinks updated in `.claude/commands/`, `.claude/skills/`, `.cursor/rules/skills/`
- All cross-references in skill workflow chain updated
- Documentation updated across CLAUDE.md, AGENTS.md, RULES.md, ARCHITECTURE.md, and templates
