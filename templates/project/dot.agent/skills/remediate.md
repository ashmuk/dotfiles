---
name: remediate
description: Skill - Close the broken review feedback loop by applying reviewer findings, co-working with builder and reviewer agents
---

# SKILL - Remediate Review Findings

## Purpose
Close the broken review feedback loop. Take reviewer findings, coordinate builder to apply fixes, then re-invoke reviewer to validate. This is the "Next" step from review when MUST-FIX findings exist.

## When to use
- Use this skill when end-user asks to 'remediate', 'fix findings', or 'resolve issues'
- Manually invoke after review skill produces MUST-FIX findings
- Coordinate with builder agent (applies fixes) and reviewer agent (re-validates)

## Policy
- Builder agent applies fixes following its own policies
- Reviewer agent re-validates following its own policies
- Maximum 3 remediation iterations before mandatory escalation
- Reviewer re-validates ONLY the original finding set; new concerns are logged as SUGGESTION for the next review cycle
- SHOULD-FIX findings are addressed when feasible; SUGGESTIONS are optional

## Systemic Issue Criteria
An issue is "systemic" and requires escalation to architect when:
- (a) The same finding category recurs across 2+ iterations
- (b) Fixes require changes outside the original scope
- (c) The iteration cap (3) is reached without full resolution

## Workflow
1. Read reviewer findings from docs/REVIEW_FINDINGS.md (MUST-FIX / SHOULD-FIX / SUGGESTION)
2. Triage findings: separate MUST-FIX from lower-priority items
3. Builder agent applies fixes for all MUST-FIX findings
4. Builder agent addresses SHOULD-FIX findings where feasible
5. Reviewer agent re-validates the fixed code against the original finding set only (new concerns logged as SUGGESTION for next review cycle)
6. If MUST-FIX findings remain from the original set, return to step 3 (max 3 iterations)
7. If iteration cap reached or systemic issue criteria met, escalate to architect agent
8. Preserve findings and resolution status in docs/REMEDIATION.md (see output template below)
9. Next: Accept (all MUST-FIX resolved) or escalate to architect if systemic issues found

## Output Template — docs/REMEDIATION.md

```markdown
# Remediation Report

## Summary
- Review source: docs/REVIEW_FINDINGS.md
- Iterations: [N of 3 max]
- Status: RESOLVED / ESCALATED

## Findings Resolution

| # | Finding | Severity | Status | Notes |
|---|---------|----------|--------|-------|
| 1 | [description] | MUST-FIX | FIXED / DEFERRED / ESCALATED | [what was done] |
| 2 | [description] | SHOULD-FIX | FIXED / DEFERRED / ESCALATED | [what was done] |

## Iteration Log
### Iteration 1
- Findings addressed: [list]
- Outcome: [remaining issues or resolved]

## Escalations (if any)
- [Systemic issue description and reason for escalation]
```
