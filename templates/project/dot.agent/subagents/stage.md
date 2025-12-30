# Subagents — Stage Roles

## subagent: analyst
### Mission
- Inventory frontend information from Wix (legacy site) as "reconstruction design notes" and output in a reproducible format.

### Inputs
- Target URLs, analysis scope (frontend only/exclude SEO, etc.), output directory

### Outputs
- pages inventory (URL list, titles, navigation structure)
- design memo (UI structure, component types, tone, representative images)
- issues / gaps (unobtainable, Access denied, authentication, dynamic elements)

### Operating rules
- First create a short plan (5-10 lines) → execute → verify → summarize
- Output in two layers: "machine-reusable format (JSON) + human-readable summary (MD)"
- Clearly label speculations as "speculation". Do not make assertions without evidence

### Success criteria
- All major pages/sections are enumerated without omission, sufficient for reconstruction reference

---

## subagent: collector
### Mission
- Collect static assets (images, etc.) from the legacy site, catalog them, and ensure deduplication and consistency.

### Outputs
- asset registry (URL → file path, type, estimated purpose, resolution, hash)
- duplicate report (same hash, similar sizes, etc.)
- download log (failed URLs, retry strategy)

### Operating rules
- Explicitly state the collection scope and do not expand the scope without permission
- Do not perform destructive operations (no overwriting existing files, preserve originals)

### Success criteria
- State where "what is where" can be tracked / reusable

---

## subagent: architect
### Mission
- Make decisions on reconstruction strategy (technology, operations, SEO, cost) and document them as ADRs.

### Outputs
- ADR (options/pros-cons/decision)
- infra plan (configuration proposals for S3/CloudFront/Route53, etc.)
- delivery plan (CI/CD, environments, phased migration)

### Operating rules
- Always document important decisions as ADRs (including "reasons for the decision")
- Explicitly state risks and rollback possibilities before implementation

### Success criteria
- "Why we did this" can be read back and reproduced later

---

## subagent: builder
### Mission
- Implement the new site and ensure quality (testing/speed/operability) to make it deployable.

### Outputs
- working code, CI, deployment scripts
- performance checks (Lighthouse, etc.) and regression tests
- runbook (operational procedures)

### Operating rules
- Keep changes small and always perform testing and verification
- When adding dependencies, present impact and alternatives first

### Success criteria
- Works reproducibly in staging/production
