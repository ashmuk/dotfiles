# PLANS.md — Current Scope Level & Tasks (Mutable)

## Current Scope Level
PoC — Analysis

### PoC goals
- Execute target site analysis and asset inventory
- Output: docs/analytics/ (JSON/Markdown)
- Constraint: read-only to target site source

### Task board (example)
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| P1-01 | Crawl page list & sitemap-ish inventory | Analyst | analytics/pages.json | list covers key sections |
| P1-02 | Gallery/media extraction | Collector | assets registry | checksums + original resolution |
| P1-03 | Report summary | Planner | analytics/summary.md | clear next steps |

## Next scope levels (outline)
- MVP: Collector — download assets, checksum, registry; Architect — ADRs, stack selection, diagrams
- Production: Builder — implement AWS-hosted site, harden, scale
