---

name: design
description: Skill - Create system architecture, designs, task breakdowns and plans, co-working with ClaudeCode built-in Plan agent(s)

---

# SKILL - Design architecture, system, tasks and plans

## Purpose
Create system architecture, designs, task breakdowns and plans, co-working with ClaudeCode built-in Plan agent(s)

## When to use
- Use this skill when end-user asks for 'architecture', 'system designs', 'tasks' or 'plans'
- Manually invoke after processing 'requirements' (REQUIREMENTS.md exists)
- Coordinate with architect agent policies during design work

## Policy
ClaudeCode built-in Plan agent(s) respects architecture agent's policies

## Model Selection Guidance
This skill involves strategic and tactical work, requiring different model capabilities:

| Phase | Model | Rationale |
|-------|-------|-----------|
| **Phase A: Architecture** | Opus | Strategic decisions, technology trade-offs, ADR creation require deep reasoning |
| **Phase B: System Design** | Opus | Detailed design choices, component interactions, pattern selection need strong judgment |
| **Phase C: Task Breakdown** | Sonnet | Tactical decomposition, clear scope definition, practical sequencing |
| **Phase D: Planning** | Sonnet | Stage-based execution planning, resource estimation, dependency mapping |

**How to apply:**
- When invoking Task tool for Plan agents in Phases A-B, use `model='opus'`
- When invoking Task tool for Plan agents in Phases C-D, use default Sonnet
- Claude (assistant) should apply these preferences when orchestrating agents

## Workflow

### Phase A: Architecture (Model: Opus)
Create high-level system architecture and technology decisions

1. Plan agent(s) co-work with architect agent, respecting its policies
2. Read REQUIREMENTS.md (if exists)
3. Analyze the context and start designing (invoke Explore or relevant agents as needed)
4. Create system architecture using the model **Opus**
5. Apply reviewer agent policy for validation of architecture
6. Finalize outcome by this feedback loop
7. Preserve all outcome in docs/ARCHITECTURE.md
8. Next: Proceed to Phase B (System Design)

### Phase B: System Design (Model: Opus)
Create detailed system design based on architecture

9. Read docs/ARCHITECTURE.md (if exists)
10. Create system design using the model **Opus**
11. Apply reviewer agent policy for validation of design
12. Finalize outcome by this feedback loop
13. Preserve all outcome in docs/DESIGNS.md
14. Next: Proceed to Phase C (Task Breakdown)

### Phase C: Task Breakdown (Model: Sonnet)
Break down design into actionable tasks

15. Read docs/DESIGNS.md (if exists)
16. Create task breakdowns using the model **Sonnet**
17. Apply reviewer agent policy for validation of task breakdown
18. Finalize outcome by this feedback loop
19. Preserve all outcome in docs/TASKS.md
20. Next: Proceed to Phase D (Planning)

### Phase D: Planning (Model: Sonnet)
Create stage-based execution plans

21. Read docs/TASKS.md (if exists)
22. Create plans by staging concept using the model **Sonnet**
23. Apply reviewer agent policy for validation of plans
24. Finalize outcome by this feedback loop
25. Preserve all outcome in PLANS.md
26. Next: Invoke implement skill with built-in general-purpose agent(s)
