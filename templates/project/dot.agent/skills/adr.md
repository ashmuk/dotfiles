# Skill — ADR (Architecture Decision Record)

## Purpose
- Document important decisions in a "reproducible format for later reference"
- Record options and reasons, adoption/rejection reasons, impact scope, and rollback feasibility

---

## skill: adr.create
### Inputs
- decision_title: string
- context: Background and challenges (why a decision is needed)
- options: Options (2-5 recommended)
- constraints: Constraints (deadline/cost/operations/compatibility, etc.)
- decision: Adopted option
- consequences: Impact (positive/negative, migration, operations, cost)

### Output
- `docs/decisions/ADR-YYYYMMDD-<slug>.md` (naming can be adjusted as preferred)

### ADR template
```md
# ADR-YYYYMMDD: <Decision Title>

## Status
- Proposed | Accepted | Superseded | Rejected

## Context
- (Background, challenges, assumptions)

## Decision Drivers
- (Decision criteria: e.g., cost, operability, portability, speed, learning curve)

## Options Considered
### Option A: ...
- Pros:
- Cons:
- Notes:

### Option B: ...
- Pros:
- Cons:
- Notes:

## Decision
- We choose **Option X** because ...

## Consequences
- Positive:
- Negative / Risks:
- Mitigations:
- Rollback plan:

## References
- Links / docs / tickets
```
