# .cursor/ Directory — Best Practice Configuration Template

> Minimal configuration: `rules/general.md`, `prompts/refactor.md`, root `.gitignore` (to protect .cursor)

> **See also**: [README_agent.md](./README_agent.md) for comprehensive agent-based development guide with Claude Code, Codex, and MCP tool integration.

---

## Directory Structure (Minimal)

```text
<project-root>/
└─ cursor/                 # Copy and Paste in <project root> directory as `.cursor`
   ├─ rules/
   │  └─ 00_general.md     # Repository-wide AI rules/policies
   ├─ prompts/
   │  └─ refactor.md       # Standard prompt (refactoring)
   └─ settings.json        # Optional: project-level Cursor settings
```

> **Note**: The `prompts/refactor.md` file is a Cursor-specific copy. If using both Cursor and Codex in your project, the shared prompts are in `../prompts/` (referenced by `.codex/config.json`).

---

## 1) `.cursor/rules/general.md`

```markdown
# Cursor Rules — General

## Role
You are an AI pair programmer and reviewer for this repository. Prioritize readability, reproducibility, and safety.

## Priorities
1. Propose small diffs (incremental changes)
2. Utilize type safety and static analysis (TypeScript/pyright, etc.)
3. Security and confidentiality considerations (never hardcode secrets)
4. Minimal test additions (unit > integration)
5. Consistency with existing design/documentation (refer to README/ADR)

## Coding Style
- Naming: Meaningful names, minimize abbreviations
- Dependencies: Prefer standard/existing libraries, justify additions
- I/O: Protect boundaries with clear types/schemas
- Logging: Detailed in dev, avoid PII in production

## Output Policy
- Start with 1-2 sentence summary of why changes are needed
- Then provide **patch candidates** (diffs or code blocks per file)
- If needed, list follow-up tasks (tests/docs/CI) as TODO bullets

## Guardrails
- Never generate/paste secrets (API keys, tokens) or customer data
- Don't include external code with unclear license compatibility
- Document breaking changes in `MIGRATION.md`/`CHANGELOG`

## Project Context
- Important documents: `README.md`, `docs/ARCHITECTURE.md`, `ADR/`
- Exclude: `node_modules`, `dist`, `build`, `.venv`, `*.lock`
```

---

## 2) `.cursor/prompts/refactor.md`

```markdown
# Prompt: Refactor (Safe & Minimal)

**Goal**: Improve code readability and maintainability while minimizing side effects.

**Steps**
1. Summarize purpose and constraints in one paragraph (performance, compatibility, API surface)
2. List issues (max 5 items with rationale)
3. Propose changes (in small commit units)
4. Suggest patches (code blocks per file)
5. Risks/regression test plan (bullet points)

**Constraints**
- Don't break existing public APIs
- No type errors/linter errors
- Supplement code intent with comments/docstrings

**Acceptance Checklist**
- [ ] Type checking/linting passes
- [ ] Existing tests are green
- [ ] Main logic intent is explainable
- [ ] Change rationale and impact summarized in PR description
```

---

## Optional Additions (Reference)

### `.cursor/settings.json` (Minimal Example)

```json
{
  "model": "anthropic/claude-4.5-sonnet",
  "contextFiles": ["README.md", "docs/ARCHITECTURE.md"],
  "allowWrite": true
}
```

### `.cursor/rules/` Split Example

```text
.cursor/
  rules/
    00-general.md
    10-frontend.md
    20-backend.md
    90-security.md
```

> Rules are assumed to be **merged in order from front to back**. Using numeric prefixes to control read order is practical (keeping in mind tool specification changes, aim for content that works even as a single file).

---

## Integration with Agent Framework

This Cursor configuration is designed to work alongside the broader agent-based development framework:

- **Standalone use**: Copy the `cursor/` directory to your project as `.cursor/` for Cursor AI assistance
- **Combined with Codex**: Use both `.cursor/` (this guide) and `.codex/` (see [README_agent.md](./README_agent.md)) for multi-tool AI development
- **Shared policies**: Both Cursor and Codex can reference the same `CLAUDE.md` and `AGENTS.md` files for consistent behavior
- **Gitignore protection**: Remember to add Cursor-specific entries to `.gitignore` (see section 3 above)

---
