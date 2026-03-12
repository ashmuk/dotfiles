---
name: cc-design
description: >-
  Create system architecture, UI/UX and API designs, task breakdowns and
  implementation plans. Use when user asks for "architecture", "system design",
  "UI/UX design", "API design", "task breakdown", or "implementation plan". Do
  NOT use for requirements gathering (use cc-define) or code implementation
  (use cc-implement).
metadata:
  version: 1.0.0
  category: workflow-automation
---

# SKILL - Design architecture, system, tasks and plans

## Purpose
Create system architecture, designs, task breakdowns and plans, co-working with ClaudeCode built-in Plan agent(s)

## When to use
- Use this skill when end-user asks for 'architecture', 'system designs', 'tasks' or 'plans'
- Manually invoke after processing 'requirements' (REQUIREMENTS.md exists)
- Coordinate with my-architect agent policies during architecture work
- Coordinate with my-designer agent policies during UX/UI and API design work

## Policy
ClaudeCode built-in Plan agent(s) respects my-architect agent's policies and my-designer agent's policies for UI/UX and API design

## Model Selection Guidance
This skill involves strategic and tactical work, requiring different model capabilities:

| Phase | Model | Rationale |
|-------|-------|-----------|
| **Phase A: Architecture** | Opus | Strategic decisions, technology trade-offs, ADR creation require deep reasoning |
| **Phase B: UX/API Design** | Opus | Design judgment, Apple HIG, accessibility, API ergonomics require deep reasoning |
| **Phase C: System Design** | Opus | Detailed design choices, component interactions, pattern selection need strong judgment |
| **Phase D: Task Breakdown** | Sonnet | Tactical decomposition, clear scope definition, practical sequencing |
| **Phase E: Planning** | Sonnet | Stage-based execution planning, resource estimation, dependency mapping |

**How to apply:**
- For Phases A-B-C, prefer deeper reasoning (Opus-class agents) for strategic decisions
- For Phases D-E, default Sonnet is sufficient for tactical decomposition
- Claude (assistant) should apply these preferences when orchestrating agents

## Workflow

### Phase A: Architecture (Model: Opus)
Create high-level system architecture and technology decisions

1. Plan agent(s) co-work with my-architect agent, respecting its policies
2. Read REQUIREMENTS.md (if exists)
3. Analyze the context and start designing (invoke Explore or relevant agents as needed)
4. Create system architecture using the model **Opus**
5. Include scope progression recommendation (PoC/MVP/Production) per my-architect's Scope Progression policy
6. Apply my-reviewer agent policy for validation of architecture
7. Finalize outcome by this feedback loop
8. Preserve all outcome in docs/ARCHITECTURE.md (including scope progression level)
9. Next: Proceed to Phase B (UX/UI & API Design)

### Phase B: UX/UI & API Design (Model: Opus)
Create user experience, interface, and API design based on architecture

Phase B adapts to project context:
- Frontend project: Focus on UX/UI design, Apple HIG, accessibility
- Backend project: Focus on API contracts, data modeling, DX
- Full-stack: Both aspects
- Skip entirely if project has no UI or API design needs

10. Plan agent(s) co-work with my-designer agent, respecting its policies
11. Read docs/ARCHITECTURE.md (from Phase A)
12. Read .agent/prompts/design/ for detailed design guidance (if available)
13. Create UX/UI and/or API design using the model **Opus** (scope per context above)
14. Apply my-reviewer agent policy for validation of design
15. Finalize outcome by this feedback loop
16. Preserve all outcome in docs/UX-DESIGNS.md
17. Next: Proceed to Phase C (System Design)

### Phase C: System Design (Model: Opus)
Create detailed system design based on architecture. Incorporate design decisions from Phase B.

18. Read docs/ARCHITECTURE.md (if exists)
19. Read docs/UX-DESIGNS.md (if exists, from Phase B)
20. Create system design using the model **Opus**
21. Apply my-reviewer agent policy for validation of design
22. Finalize outcome by this feedback loop
23. Preserve all outcome in docs/DESIGNS.md
24. Next: Proceed to Phase D (Task Breakdown)

### Phase D: Task Breakdown (Model: Sonnet)
Break down design into actionable tasks

25. Read docs/DESIGNS.md (if exists)
26. Create task breakdowns using the model **Sonnet**
27. Apply my-reviewer agent policy for validation of task breakdown
28. Finalize outcome by this feedback loop
29. Preserve all outcome in docs/TASKS.md
30. Next: Proceed to Phase E (Planning)

### Phase E: Planning (Model: Sonnet)
Create stage-based execution plans respecting my-architect's scope progression (PoC → MVP → Production)

31. Read docs/TASKS.md (if exists)
32. Create plans by staging concept using the model **Sonnet**, aligning stages with the scope progression level recommended by my-architect
33. Apply my-reviewer agent policy for validation of plans
34. Finalize outcome by this feedback loop
35. Preserve all outcome in PLANS.md
36. Next: Invoke cc-test skill to define test strategy before implementation

## Examples

### Example 1: Full design from requirements
User says: "Design the architecture for our new e-commerce platform"
Actions:
1. Phase A: my-architect creates system architecture with scope progression (PoC/MVP/Production)
2. Phase B: my-designer creates UX flows and API contracts
3. Phase C: Detailed system design with component interactions
4. Phase D: Task breakdown into implementable units
5. Phase E: Stage-based execution plan
Result: docs/ARCHITECTURE.md, docs/UX-DESIGNS.md, docs/DESIGNS.md, docs/TASKS.md, PLANS.md

### Example 2: API design only
User says: "Design the REST API for the payment service"
Actions:
1. Phase A: my-architect defines service boundaries and technology choices
2. Phase B: my-designer creates API contracts, data models, error patterns (skip UX)
3. Phase C-E: System design, tasks, and plans for the API
Result: Focused API design artifacts

## Troubleshooting

### REQUIREMENTS.md not found
Cause: Requirements haven't been defined yet.
Solution: Run cc-define skill first to produce REQUIREMENTS.md, or ask the user for specific design goals.

### Phase B unclear (frontend vs. backend)
Cause: Project context doesn't clearly indicate whether UI or API design is needed.
Solution: Ask the user. Phase B adapts: frontend projects focus on UX/UI, backend on API contracts, full-stack on both. Skip entirely if neither applies.

### Architecture scope too broad
Cause: Trying to design everything at once.
Solution: Use my-architect's scope progression (PoC → MVP → Production) to constrain initial scope. Start with the smallest viable architecture.
