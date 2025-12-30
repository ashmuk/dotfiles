# PLANS.md — Current Stage & Tasks (Mutable)

## Current Stage
Stage 1 — Documentation & Infrastructure

### Stage 1 Goals
- Fix broken documentation references and missing directories
- Document all Makefile targets
- Create ADR directory structure
- Establish baseline for AI agent improvements

### Task Board
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| S1-01 | Create docs/decisions/ directory | Operator | ADR directory + README | Directory exists with template |
| S1-02 | Update README.md with missing targets | Coder | Updated README | All install-* targets documented |
| S1-03 | Fix CLAUDE.md ADR path reference | Coder | Corrected path | No broken references |
| S1-04 | Update Cursor rules references | Coder | Valid file refs | ARCHITECTURE.md created or refs removed |
| S1-05 | Document generated files strategy | Coder | New docs section | Clear *.generated lifecycle |

---

## Stage 2 — AI Agent Template Enhancement (Priority)

### Stage 2 Goals
- Unify experimental agent features into project template
- Expand skills and tools for AI assistants
- Improve cross-platform agent sync

### Task Board
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| S2-01 | Port MCP configuration to project template | Toolsmith | .codex/mcp.yaml | MCP tools available |
| S2-02 | Add Codex config.json to project template | Toolsmith | .codex/config.json | Model settings configured |
| S2-03 | Create shared prompts/ directory | Coder | prompts/*.md | Reusable prompt templates |
| S2-04 | Expand skills library | Coder | skills/*.md | refactor, test, docs, security-review skills |
| S2-05 | Add agent capability matrix | Planner | AGENTS.md section | Tool access per agent documented |
| S2-06 | Improve sync-agents.sh | Coder | Enhanced script | Claude ↔ Cursor ↔ Codex sync |
| S2-07 | Create MCP tool examples | Toolsmith | mcp/tools/*.json | Echo, lint, test tools |
| S2-08 | Document agent workflow | Coder | README_agent.md | Setup + usage guide |

---

## Stage 3 — Performance Optimization

### Stage 3 Goals
- Address shell startup bottlenecks
- Implement lazy-loading improvements
- Optimize plugin loading

### Task Board
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| S3-01 | Profile current shell startup | Analyst | Timing report | Baseline metrics |
| S3-02 | Implement nvm lazy-loading | Coder | Updated shell config | < 100ms nvm impact |
| S3-03 | Optimize Oh My Zsh plugins | Coder | Reduced plugin set | < 50ms plugin load |
| S3-04 | Add conditional tool loading | Coder | Platform-aware loading | Skip unavailable tools |

---

## Stage 4 — Script Quality Improvements

### Stage 4 Goals
- Add testing framework for shell scripts
- Improve logging and error handling
- Add dry-run modes

### Task Board
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| S4-01 | Add bats test framework | Toolsmith | test/*.bats | Shell tests runnable |
| S4-02 | Add timestamped logging | Coder | Log utilities | Debug-friendly output |
| S4-03 | Add dry-run to setup scripts | Coder | --dry-run flag | Preview without changes |
| S4-04 | Standardize exit codes | Coder | Consistent codes | Documented exit values |

---

## Next Stages (Outline)
- Stage 5: Cross-platform testing (CI matrix for macOS, Linux, WSL)
- Stage 6: Template versioning and migration tooling
- Stage 7: Documentation consolidation (English-first)
