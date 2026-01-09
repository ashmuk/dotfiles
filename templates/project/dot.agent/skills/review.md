---
name: review
description: Skill - Review all relevant aspects of project progress, co-working with ClaudeCode built-in agent(s) which are relevant
---

# SKILL - Review project progress

## Purpose
Review all relevant aspects of project progress, co-working with ClaudeCode built-in agent(s) which are relevant

## When to use
- Use this skill at any stage to validate work in progress
- Manually invoke for final validation before commits/deployments
- Apply reviewer agent policies throughout all workflows

## Policy
ClaudeCode built-in agent(s) respects reviewer agent's policies

## Workflow
1. Apply reviewer agent policies (from .claude/agents/reviewer.md)
2. Understand context from input or artifacts (REQUIREMENTS.md, ARCHITECTURE.md, etc.)
3. Review using reviewer checklist:
   - Alignment with plan/requirements
   - Security vulnerabilities
   - Code quality and maintainability
   - Safety for destructive actions
4. Provide findings with severity: MUST-FIX / SHOULD-FIX / SUGGESTION
5. Recommend concrete, actionable fixes
