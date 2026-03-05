---
name: cc-test
description: Skill - Own test strategy, coverage gap analysis, test architecture and test plans, co-working with my-analyst and my-reviewer agents
---

# SKILL - Define Test Strategy

## Purpose
Own test strategy — coverage gap analysis, test architecture, test plans, and regression mapping. This skill plans WHAT to test; my-builder writes the actual test code.

## When to use
- Use this skill when end-user asks for 'test strategy', 'test plan', 'test coverage', or 'testing'
- Manually invoke before implementation to define what needs testing
- Coordinate with my-analyst agent (strategic planning) and my-reviewer agent (validates coverage)

## Policy
- Test skill NEVER writes code — that is always delegated to my-builder via cc-implement skill
- my-builder NEVER decides test strategy — that is always owned by this skill
- Test implementation MUST be a separate my-builder invocation from feature implementation — the my-builder instance that writes tests must not be the same instance that wrote the feature code
- my-analyst agent drives strategic planning; my-reviewer agent validates coverage completeness

## Workflow
1. my-analyst agent reads PLANS.md (if exists), codebase, and available coverage data
2. Identify test pyramid ratios appropriate for the project (unit / integration / e2e)
3. Analyze coverage gaps: what is untested, undertested, or at risk
4. Define test architecture: fixture strategy, mock boundaries, test data management
5. Map regression risks: which areas need regression coverage and why
6. Scope non-functional testing: performance, security, accessibility as applicable
7. Assess flakiness risk in existing or planned tests
8. Select or confirm framework choices aligned with project conventions
9. my-reviewer agent validates coverage completeness and strategy soundness
10. Finalize outcome by this feedback loop
11. Preserve all outcome in docs/TEST_STRATEGY.md or docs/TEST_PLAN.md
12. Next: Invoke cc-implement skill so my-builder writes tests per the strategy
