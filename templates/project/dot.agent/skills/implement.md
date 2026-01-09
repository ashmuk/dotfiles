---

name: implement
description: Skill - Implement softwares and relevant artifacts, co-working with ClaudeCode built-in general-purpose agent(s)

---

# SKILL - Implement softwares

## Purpose
Implement softwares and relevant artifacts, co-working with ClaudeCode built-in general-purpose agent(s)

## When to use
- Use this skill when end-user asks for 'implementations', 'build', 'coding' or 'deploy'
- Manually invoke after processing 'plans' (PLANS.md exists)
- Coordinate with builder agent policies during implementation work

## Policy
ClaudeCode built-in general-purpose agent(s) respects builder agent's policies

## Workflow
1. general-purpose agent(s) is co-working with builder agent and respect its policies
2. Read PLANS.md (if exists) 
3. Analyze the context and start implementations (invoke general-purpose or relevant agents in your needs)
4. Implement using the model **Haiku** or **Sonnet**
5. Apply reviewer agent policy for validation of what was implemented
6. Finalize outcome by this feedback loop
7. Preserve notable points in docs/IMPLEMENTATIONS.md
8. Next: Invoke review skill for final validation
