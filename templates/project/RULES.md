# RULES.md — Project Policy (Stable)

## Do / Don't
✅ Do
- Propose options with Pros/Cons when decisions are needed
- Keep changes incremental and reviewable
- Ask before destructive operations
- Follow existing patterns
- Record decisions as ADRs in docs/decisions/

❌ Don't
- Deploy to production (until explicitly allowed)
- Modify assets_legacy/ (read-only)
- Add dependencies without discussion
- Commit secrets or credentials

## Quality / Security
- Security first: validate inputs, avoid leaking any tokens/keys
- Documentation-first: update docs when behavior changes
- Prefer smallest diff that achieves the goal

## Git / PR
### Commit format
type(scope): description
- feat(stage1): ...
- fix(scraper): ...
- docs: ...

### Branch model (override per repo reality)
- main (prod) <- develop (integration) <- feature/*
- Prefer short-lived feature branches

### PR checklist
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
