# ADR-20260306: Add Security Audit Prompt Templates for my-reviewer

## Status
Accepted

## Context
The design prompts pattern (`templates/project/dot.agent/prompts/design/`, 3 files) proved effective for enriching my-designer with deep, structured reference material that is loaded on-demand during design work. my-reviewer currently has a surface-level security checklist (injection, auth, data exposure, input validation, secrets) but lacks equivalent depth for security audits.

We need structured security prompt templates covering PSIRT, CSIRT, and application security disciplines that my-reviewer can read on-demand during deep security reviews.

## Decision
Create 3 security prompt templates in `templates/project/dot.agent/prompts/security/`, mirroring the design prompt pattern:

| File | Disciplines | Persona |
|------|-------------|---------|
| `appsec_threat_model_prompt.md` | Application Security + Threat Modeling | Senior AppSec Engineer (Google Project Zero) |
| `psirt_supply_chain_prompt.md` | Product Security + Supply Chain | Principal Product Security Engineer (Microsoft PSIRT) |
| `csirt_incident_response_prompt.md` | Incident Response + Security Operations | Senior IR Lead (CrowdStrike) |

### Grouping Rationale
- **AppSec + Threat Modeling**: Both pre-deployment, code-level — OWASP Top 10 2021, STRIDE, CVSS v4.0 scoring
- **PSIRT + Supply Chain**: Product lifecycle — CVE management, dependency audit, SBOM, secrets, secure SDLC gates
- **CSIRT + IR**: Post-incident/reactive — detection, containment, recovery, compliance, lessons learned

### Integration Points
- my-reviewer Context Loading references `.agent/prompts/security/` (line 16)
- cc-review workflow includes security prompt step for security-focused reviews

### Scope Boundary: my-reviewer only, not my-architect
These prompts are scoped to **my-reviewer** and deliberately excluded from **my-architect**. The two agents have distinct concerns:

- **my-reviewer** performs **verification and audit** — evaluating existing code/systems against security standards. The prompts provide checklists, scoring frameworks (CVSS), and compliance matrices that match this audit posture.
- **my-architect** performs **design and decision-making** — choosing technologies, designing systems, and documenting trade-offs in ADRs. Security considerations at the architecture level (e.g., "should we use mTLS?") are design decisions, not audit findings.

If my-architect needs security input, the appropriate pattern is to invoke my-reviewer as a collaborator (via cc-review or cc-remediate), not to load audit-oriented prompts into an agent whose job is to design. This preserves the separation of concerns: architects propose, reviewers validate.

## Token Budget
- **Per-session:** ~20 tokens (1 line added to my-reviewer Context Loading)
- **On-demand:** ~3,000-4,500 tokens (only when security prompts are read during deep audits)
- No auto-loading — prompts are reference material read explicitly by the agent

## Consequences
- my-reviewer gains deep, structured guidance for security audits across AppSec, PSIRT, and CSIRT disciplines
- Follows established pattern from design prompts, maintaining consistency
- On-demand loading avoids context window bloat for non-security reviews
- Industry frameworks are versioned and will need periodic updates: OWASP Top 10 (2021), CVSS v4.0, NIST SP 800-61r3 (2024), SLSA v1.0 (2023)

## Alternatives Considered
1. **Inline in my-reviewer.md** — Rejected: would bloat the agent definition loaded every session
2. **Single monolithic security prompt** — Rejected: too large, mixes unrelated disciplines
3. **Per-framework files (OWASP, STRIDE, NIST each separate)** — Rejected: too many small files, related disciplines benefit from co-location
