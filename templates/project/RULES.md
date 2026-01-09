# RULES.md — Project Policy (Stable)
This file is referred from AGENTS.md

---
description: "This rule provides standards how to behave for this project"
alwaysApply: true
> **NOTE**: This section is only for Cursor (.cursor/rules/project/RULE.md)
---

## Do / Don't
✅ Do
- Propose options with Pros/Cons when decisions are needed
- Keep changes incremental and reviewable
- Ask before destructive operations
- Follow existing patterns
- Record decisions as ADRs in docs/decisions/

❌ Don't
- Destructive changes without confirmation
- Deploy to production (until explicitly allowed)
- Modify assets_legacy/ (read-only)
- Add dependencies without discussion
- Commit secrets or credentials
- **Merge to `main` without explicit approval**
- Force push, hard reset, or rebase shared branches

## Quality / Security
- Security first: validate inputs, avoid leaking any tokens/keys
- Documentation-first: update docs when behavior changes
- Prefer smallest diff that achieves the goal

## Git Flow
**Branches**: `main` (prod) ← `develop` (integration) ← `feature/*`
**Commits**: Conventional format (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`)
**Tags**: `v{X}.{yy}` (X = stage, yy = patch)

## Approval Gates

| Action | Approval |
|--------|----------|
| Create PRs, run CI/CD | Automated |
| Merge to `develop` | Automated (when user says "proceed") |
| **Merge to `main`** | **Require approval** (production) |
| Force push/reset/rebase | **Require approval** |
| Delete production data | **Require approval** |
| Infrastructure changes | **Require approval** |

## PR Checklist
- [ ] Scope is minimal and clear
- [ ] Tests/lint run (or explain why not)
- [ ] Docs updated if needed
- [ ] No secrets / no large binaries
- [ ] Decision captured as ADR when relevant

## Definition of Done
- The change works
- Verification completed (lint/test when available)
- Docs updated
- Next steps noted (if any)

---

**📖 For detailed workflows, see [AGENTS.md](./AGENTS.md)**
**📋 For technology roadmap, see [PLANS.md](./PLANS.md)**
**🏗️ For architecture details, see [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)**
