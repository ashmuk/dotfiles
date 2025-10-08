# CLAUDE.md — Project Policy

## Purpose
- Define the primary objectives and scope of the repository
- Example: Building a web application with API integration, focusing on reliability (testing/monitoring/reproducibility)

## Style & Priorities
1. Type safety and principle of least privilege
2. Documentation-first approach (ADR/README updates are mandatory)
3. Security linting and dependency vulnerability checks enforced in CI

## Tech Preference
- Languages: TypeScript / Python
- Frontend: Next.js (App Router)
- Server: FastAPI or Next.js API Routes
- Database: PostgreSQL (Prisma or SQLAlchemy)

## Definition of Done
- Lint/Typecheck/Unit tests/Minimal E2E tests all passing
- README and CHANGELOG updated
- Security considerations verified (secrets/keys/PII)

## Non-Goals
- Avoid excessive dependency on vendor-specific features
