---
name: cc-implement
description: >-
  Implement software, code, scripts, and artifacts from existing plans. Use
  when user asks to "build", "code", "implement", "deploy", "refactor", or
  "simplify" code. Do NOT use for architecture or design (use cc-design),
  test strategy (use cc-test), or code review (use cc-review).
metadata:
  version: 1.0.0
  category: workflow-automation
---

# SKILL - Implement software

## Purpose
Implement software and relevant artifacts, co-working with ClaudeCode built-in general-purpose agent(s)

## When to use
- Use this skill when end-user asks for 'implementations', 'build', 'coding', 'deploy', 'refactor' or 'simplify' (in the context of code/artifacts, not strategy or plans)
- Manually invoke after processing 'plans' (PLANS.md exists)
- Coordinate with my-builder agent policies during implementation work

## Policy
- ClaudeCode built-in general-purpose agent(s) respects my-builder agent's policies
- When implementing tests from a test strategy, this MUST be a separate invocation from the feature implementation — never combine feature code and test code in the same implement session

## Workflow
1. general-purpose agent(s) is co-working with my-builder agent and respect its policies
2. Read PLANS.md (if exists)
3. Analyze the context and start implementations (invoke general-purpose or relevant agents in your needs)
4. Implement using the appropriate model: **Sonnet** for multi-file or complex logic; **Haiku** for single-file, well-scoped tasks
5. Apply my-reviewer agent policy for validation of what was implemented
6. Finalize outcome by this feedback loop
7. Preserve notable points in docs/IMPLEMENTATIONS.md
8. Next: Invoke cc-review skill for final validation

## Examples

### Example 1: Feature implementation from plan
User says: "Implement the authentication module from the plan"
Actions:
1. Read PLANS.md for authentication module tasks
2. my-builder implements code following project patterns
3. my-reviewer validates implementation against plan
Result: Feature code committed, docs/IMPLEMENTATIONS.md updated

### Example 2: Test implementation from strategy
User says: "Write the tests from the test strategy"
Actions:
1. Read docs/TEST_STRATEGY.md for test requirements
2. my-builder writes tests in a SEPARATE session from feature code
3. my-reviewer validates coverage against strategy
Result: Test suite created matching the defined strategy

## Troubleshooting

### PLANS.md not found
Cause: No plan exists to implement from.
Solution: Run cc-design skill first to produce PLANS.md, or ask the user for specific implementation instructions.

### Implementation diverges from plan
Cause: Plan assumptions don't match actual codebase.
Solution: Pause implementation, document the divergence, and either update the plan via cc-design or escalate to my-architect for guidance.
