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

## Git / PR
**Commit format**: `type(scope): description`
```
- feat(stage1): ...
- fix(scraper): ...
- docs: ...
```

**Branches**: `main` (prod) ← `develop` (integration) ← `feature/*`
- Prefer short-lived feature branches

**DevContainer**: `claude-hard` = dangerous mode alias

**PR checklist**
- [ ] Scope is minimal and clear
- [ ] Tests/lint run (or explain why not)
- [ ] Docs updated if needed
- [ ] No secrets / no large binaries
- [ ] Decision captured as ADR when relevant

### Merge Workflow & Approval Gates
**Automated (No approval needed):**
- ✅ Create PRs (feature → develop)
- ✅ Run CI/CD checks
- ✅ Merge to `develop` (when explicitly asked to "proceed")
- ✅ Create release PRs (develop → main)

**Require Explicit Approval:**
- ⚠️ **Merge to `main`** - Always ask first (production deployment)
- ⚠️ **Force operations** - push --force, reset --hard, rebase on shared branches
- ⚠️ **Delete production data** - S3 objects, CloudFront invalidations, DB records
- ⚠️ **Infrastructure changes** - CloudFormation/CDK deployments, DNS changes

**Example Workflow:**
```bash
# 1. Create feature PR → develop (automated)
# 2. Merge to develop (automated if user said "proceed")
# 3. Create release PR → main (automated)
# 4. ⚠️ STOP and ask: "PR #X ready to merge to main. Deploy to production?"
# 5. After approval: merge to main
```

## Definition of Done
- The change works
- Verification completed (lint/test when available)
- Docs updated
- Next steps noted (if any)

---

**📖 For detailed workflows, see [AGENTS.md](./AGENTS.md)**
**📋 For technology roadmap, see [PLANS.md](./PLANS.md)**
**🏗️ For architecture details, see [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)**
