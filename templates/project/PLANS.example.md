# PLANS.md — Current Stage & Tasks (Mutable)

## Current Stage
Stage 1 — Analysis

### Stage 1 goals
- Execute target site analysis and asset inventory
- Output: docs/analytics/ (JSON/Markdown)
- Constraint: read-only to target site source

### Task board (example)
| ID | Task | Owner | Output | Acceptance |
|---|------|-------|--------|------------|
| S1-01 | Crawl page list & sitemap-ish inventory | Analyst | analytics/pages.json | list covers key sections |
| S1-02 | Gallery/media extraction | Collector | assets registry | checksums + original resolution |
| S1-03 | Report summary | Planner | analytics/summary.md | clear next steps |

## Next stages (outline)
- Stage 2: Collector — download assets, checksum, registry
- Stage 3-4: Architect — ADRs, stack selection, diagrams
- Stage 5+: Builder — implement AWS-hosted site
