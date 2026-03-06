---
name: cc-review
description: Skill - Review all relevant aspects of project progress, co-working with ClaudeCode built-in agent(s) which are relevant
---

# SKILL - Review project progress

## Purpose
Review all relevant aspects of project progress, co-working with ClaudeCode built-in agent(s) which are relevant

## When to use
- Use this skill at any stage to validate work in progress
- Manually invoke for final validation before commits/deployments
- Apply my-reviewer agent policies throughout all workflows

## Policy
- ClaudeCode built-in agent(s) respects my-reviewer agent's policies
- Review is strictly read-only — no code modifications. All fixes flow through cc-remediate skill to my-builder agent.

## Workflow
1. Apply my-reviewer agent policies (from .agent/subagents/my-reviewer.md)
2. Understand context from input or artifacts (REQUIREMENTS.md, ARCHITECTURE.md, etc.)
3. Review using my-reviewer checklist:
   - Alignment with plan/requirements
   - Security vulnerabilities
   - For security-focused reviews, read .agent/prompts/security/ for detailed guidance
   - Code quality and maintainability
   - Safety for destructive actions
4. Provide findings with severity: MUST-FIX / SHOULD-FIX / SUGGESTION
5. Recommend concrete, actionable fixes
6. Preserve findings in docs/REVIEW_FINDINGS.md
7. Next: If MUST-FIX findings exist, invoke cc-remediate skill. Otherwise, accept.
