# Skill — ADR (Architecture Decision Record)

## Purpose
- 重要な意思決定を「後から再現できる形」で残す
- 選択肢と理由、採用/不採用理由、影響範囲、巻き戻し可否を記録する

---

## skill: adr.create
### Inputs
- decision_title: string
- context: 背景・課題（なぜ決める必要があるか）
- options: 選択肢（2〜5個推奨）
- constraints: 制約（期限/コスト/運用/互換性など）
- decision: 採用案
- consequences: 影響（良い/悪い、移行、運用、コスト）

### Output
- `docs/decisions/ADR-YYYYMMDD-<slug>.md`（命名は好みで調整可）

### ADR template
```md
# ADR-YYYYMMDD: <Decision Title>

## Status
- Proposed | Accepted | Superseded | Rejected

## Context
- （背景・課題・前提）

## Decision Drivers
- （判断基準：例 コスト、運用性、移植性、速度、学習コスト）

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
