# ADR-20260305: Refine Agent Skills Ecosystem

## Status
- Accepted

## Context
- The skill ecosystem had 5 skills (`define`, `design`, `implement`, `review`, `adr`) covering the SDLC
- Two new skills were considered: `code-simplifier` and `toolsmith`
- Analysis revealed both overlap heavily with existing coverage (reviewer + builder + Claude Code built-in `/simplify`)
- A genuine architectural gap was identified: the `review` skill is the only skill without a "Next" step — findings terminate into a void
- The reviewer is read-only by design (independence), but no skill existed to act on its findings
- No skill owned test *strategy* (what to test); builder only writes test code

## Decision Drivers
- Close the broken review feedback loop (reviewer produces findings, nobody acts on them)
- Absorb `code-simplifier` and `toolsmith` intent into existing layers without adding redundant skills
- Maintain naming conventions (action nouns, not agent nouns)
- Clarify infrastructure ownership across architect/builder/reviewer
- Add test strategy as a distinct SDLC phase

## Options Considered

### Option A: Add `code-simplifier` and `toolsmith` as new skills
- Pros: Explicit dedicated skills for simplification and tooling
- Cons: High overlap with reviewer (detection), builder (principles), and Claude Code built-in `/simplify`; naming breaks conventions (agent-nouns vs action-nouns); fragments responsibilities
- Notes: "code-simplifier" conflicts with built-in `/simplify`

### Option B: Enrich existing layers + add `remediate` and `test` skills
- Pros: Closes review loop; adds test strategy ownership; absorbs simplifier/toolsmith intent without redundancy; maintains naming consistency
- Cons: More files touched (8 total); requires understanding the full ecosystem
- Notes: This is the chosen approach

### Option C: Do nothing
- Pros: No changes needed
- Cons: Review findings continue to terminate in a void; no test strategy ownership; infrastructure scope remains ambiguous

## Decision
- We choose **Option B** because it addresses the genuine architectural gaps (broken review loop, missing test strategy) while absorbing the intent of rejected skills into existing layers without creating redundancy or naming conflicts.

### Changes Made (8 files)

| # | Action | File | Absorbs |
|---|--------|------|---------|
| 1 | NEW | `skills/remediate.md` | Closes review-to-fix feedback loop |
| 2 | NEW | `skills/test.md` | Test strategy ownership |
| 3 | ENRICH | `skills/review.md` | Added "Next: remediate or accept" |
| 4 | ENRICH | `skills/implement.md` | Added refactor/simplify triggers |
| 5 | ENRICH | `subagents/reviewer.md` | code-simplifier + infra maintenance |
| 6 | ENRICH | `subagents/builder.md` | toolsmith + infra implementation |
| 7 | ENRICH | `subagents/architect.md` | infra design scope |
| 8 | UPDATE | `CLAUDE.md` | Registered new skills |

All paths relative to `templates/project/dot.agent/`.

### Resulting SDLC Flow
```
define -> design -> test -> implement -> review --+--> [accept]
                                                  |
                                                  v
                                              remediate
                                           (if MUST-FIX exists)

         adr <- (strategic decisions at any point)
```

### Infrastructure Scope Clarification
| Concern | Agent Owner |
|---------|-------------|
| Infrastructure Design | **Architect** (service selection, network, IAM, monitoring) |
| Infrastructure Implementation | **Builder** (Terraform/CDK, CI/CD, deployment scripts) |
| Infrastructure Maintenance | **Reviewer** (drift detection, patches, compliance) |

### Token Impact (estimated)

| File | Before | After | Delta |
|------|--------|-------|-------|
| `skills/design.md` | 629 | 632 | +3 |
| `skills/remediate.md` *(new)* | 0 | 558 | +558 |
| `skills/test.md` *(new)* | 0 | 357 | +357 |
| `skills/review.md` | 189 | 236 | +47 |
| `skills/implement.md` | 205 | 220 | +15 |
| `subagents/builder.md` | 590 | 653 | +63 |
| `subagents/reviewer.md` | 604 | 722 | +118 |
| `RULES.md` | 574 | 582 | +8 |
| **Total** | **2,791** | **3,960** | **+1,169** |

- Existing files: +254 tokens (~9% increase)
- New files: +915 tokens (net-new capabilities)
- At Opus input pricing (~$15/M tokens): ~+$0.018 per invocation when all files are loaded

## Consequences

- Positive:
  - Review findings now flow into remediation (closed loop)
  - Test strategy is a first-class concern separate from test implementation
  - Infrastructure responsibilities are clearly partitioned
  - No naming conflicts or redundant skills
- Negative / Risks:
  - Remediation loop could cycle if reviewer keeps finding new issues
  - Test skill boundary with builder requires discipline (strategy vs code)
- Mitigations:
  - Remediate skill escalates to architect if systemic issues found
  - Test skill policy explicitly states "never writes code"
  - Test implementation is explicitly required to be a separate builder invocation from feature implementation (separation of concerns)
- Rollback plan:
  - Revert the 8 file changes; downstream projects re-run `make sync`

## Agent-Skill Coverage Validation

4 agents are sufficient — no new agent needed. Every skill maps to an existing agent role.

| Skill | Primary Agent | Co-working Built-in | Reviewer Gate | Escalation |
|-------|--------------|---------------------|---------------|------------|
| `/define` | analyst | Explore | reviewer | — |
| `/design` | architect | Plan | reviewer | — |
| `/test` | analyst | — | reviewer | implement (builder) |
| `/implement` | builder | general-purpose | reviewer | — |
| `/review` | reviewer | — | (self) | — |
| `/remediate` | builder | — | reviewer | architect (systemic) |
| `/adr` | (template) | — | — | — |

**Workflow chain:** `define(analyst) → design(architect) → test(analyst) → implement(builder) → review(reviewer) → remediate(builder+reviewer)`

## References

- Rejected skills analysis: `code-simplifier` (HIGH overlap), `toolsmith` (MODERATE-HIGH overlap)
- Future candidates (not in scope): `maintain` (P2), `release` (P3)
