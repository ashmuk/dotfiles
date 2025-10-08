# CLAUDE.md — Project Policy

> This file provides guidance to Claude Code and other AI assistants when working with code in this repository.

---

## Project Overview

**Purpose**: Define the primary objectives and scope of the repository.

<!-- Example: Building a web application with API integration, focusing on reliability (testing/monitoring/reproducibility) -->

### Current Stage
<!-- Describe the current phase of the project (e.g., planning, MVP, production) -->

To be defined...

### Architecture

#### Tech Stack
To be determined...

Considerations:
- Languages: TypeScript / Python / Go / Java
- Frontend: Next.js (App Router) / React / Vue.js
- Server: FastAPI / Next.js API Routes / Express
- Database: PostgreSQL (Prisma or SQLAlchemy) / MongoDB / DynamoDB
- Cloud: AWS / GCP / Azure
- CI/CD: GitHub Actions / GitLab CI / CircleCI

#### File Structure
```text
<project-root>/
├─ .claude/          # Claude Code configuration
├─ .codex/           # Codex configuration (if using)
├─ .cursor/          # Cursor AI configuration (if using)
├─ src/              # Source code
├─ tests/            # Test files
├─ docs/             # Documentation
├─ scripts/          # Build/deployment scripts
├─ README.md
└─ CLAUDE.md         # This file
```

---

## Development Guidelines

### AI Context/Goals

#### Scope of Support
AI assistants are expected to assist in:
- Generating and refactoring code components
- Writing deployment and automation scripts
- Reviewing documentation for consistency
- Suggesting accessibility, performance, and security improvements
- Analyzing code patterns and identifying potential issues

**✅ Do:**
- Suggest technology options with Pros/Cons analysis
- Provide incremental, reviewable changes
- Ask for clarification before making destructive changes
- Follow project conventions and existing patterns
- Document rationale for significant decisions

**❌ Avoid:**
- Making destructive file operations without confirmation
- Committing changes directly without review
- Adding external dependencies without discussion
- Implementing entire features from scratch without context
- Exposing secrets or sensitive data in code/logs

#### Examples
```text
✅ Good
"Refactor the authentication module to use JWT with refresh tokens, maintaining backward compatibility."

❌ Avoid
"Delete all existing authentication code and rebuild from scratch."
```

### Style & Priorities

1. **Type safety and principle of least privilege**
   - Use strong typing (TypeScript, Python type hints, etc.)
   - Minimize access scopes and permissions
   - Validate inputs and sanitize outputs

2. **Documentation-first approach**
   - Update README, ADR, and inline documentation alongside code
   - Document API contracts and interfaces
   - Maintain changelog for significant changes

3. **Security and quality checks**
   - Security linting and dependency vulnerability scanning in CI
   - Code review required before merging
   - Secrets management (use environment variables, never commit)

4. **Incremental and testable changes**
   - Small, focused commits with clear messages
   - Unit tests > Integration tests > E2E tests (in order of priority)
   - Feature flags for gradual rollout

### Coding Standards

To be formalized...

- **Naming**: Descriptive, consistent with project conventions
- **Formatting**: Follow project linter/formatter (Prettier, Black, gofmt, etc.)
- **Comments**: Explain "why" not "what", keep code self-documenting
- **Error handling**: Explicit, informative, logged appropriately

### Review Policy

- All AI-generated code must be reviewed by a maintainer before merging
- Lint and format checks required before commit
- Sensitive keys/credentials must be excluded from commits (`.env`, `config.json`)
- Breaking changes require migration documentation

### Testing

To be determined...

- Test coverage targets
- Testing frameworks and conventions
- Mock/fixture strategies

---

## Deployment

To be determined...

### Environments
- Development
- Staging
- Production

### CI/CD Pipeline
- Automated testing on PR
- Deployment procedures
- Rollback strategy

---

## Definition of Done

Before considering work complete:
- [ ] Lint/Typecheck/Unit tests all passing
- [ ] README and CHANGELOG updated
- [ ] Security considerations verified (no secrets/keys/PII in code)
- [ ] Code reviewed and approved
- [ ] Documentation updated (inline comments, API docs, ADR if needed)

---

## Non-Goals

What this project explicitly avoids:
- Excessive dependency on vendor-specific features (maintain portability)
- Over-engineering for未realized requirements
- Premature optimization before measurement

---

## Common Tasks

### Version Control
- **Branching**: Feature branches from `develop` or `main`
- **Commit messages**: Use conventional commits format (feat:, fix:, docs:, chore:, etc.)
- **PR workflow**:
  1. Create feature branch
  2. Make changes with tests
  3. Push and create PR
  4. Address review comments
  5. Merge after approval

### How to Create a PR
1. Ensure all tests pass locally
2. Update documentation
3. Push feature branch to origin
4. Create PR with clear description
5. Request review
6. Address feedback
7. Merge when approved

---

## Important Notes

### Files/Areas Not to Modify
- To be specified (e.g., legacy modules, generated code, vendor libraries)

### Special Considerations
- To be specified (e.g., backward compatibility, performance constraints, regulatory requirements)

### Known Issues and Restrictions
- To be documented (e.g., technical debt, external dependencies, limitations)
