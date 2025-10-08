# CLAUDE.md — Project Policy

> Quick reference for AI assistants working with this repository. See [CLAUDE.full.md](./CLAUDE.full.md) for comprehensive documentation.

---

## Project Overview

**Purpose**: [Define primary objectives and scope]

**Current Stage**: [e.g., Planning / MVP / Production / Migration]

**Tech Stack**:
- Languages: [e.g., TypeScript, Python]
- Frontend: [e.g., Next.js, React]
- Backend: [e.g., FastAPI, Express]
- Database: [e.g., PostgreSQL, MongoDB]
- Cloud: [e.g., AWS, GCP]

**Key Files**:
```
src/          # Source code
tests/        # Test files
docs/         # Documentation
README.md     # Project overview
```

---

## AI Assistant Guidelines

### Scope of Support

**✅ Do:**
- Suggest technology options with Pros/Cons analysis
- Provide incremental, reviewable changes (small diffs)
- Ask for clarification before destructive operations
- Follow existing code patterns and conventions
- Document significant decisions and changes

**❌ Avoid:**
- Making destructive changes without confirmation
- Adding dependencies without discussion
- Committing secrets, API keys, or credentials
- Implementing entire features from scratch without context
- Bypassing existing review/testing processes

### Examples

```text
✅ Good
"Refactor the authentication module to use JWT, maintaining backward compatibility."

❌ Avoid
"Delete all authentication code and rebuild from scratch."
```

---

## Core Priorities

1. **Type Safety & Security**
   - Use strong typing (TypeScript, type hints)
   - Validate inputs, sanitize outputs
   - Never commit secrets (use environment variables)

2. **Documentation-First**
   - Update README/docs alongside code changes
   - Document API contracts and breaking changes
   - Keep comments focused on "why" not "what"

3. **Incremental & Testable**
   - Small, focused commits with clear messages
   - Tests required for new features
   - Code review before merging

4. **Follow Conventions**
   - Respect existing code style and patterns
   - Use project linter/formatter settings
   - Maintain consistency across codebase

---

## Definition of Done

Before considering work complete:
- [ ] Code passes lint/typecheck/tests
- [ ] Documentation updated (README, inline comments)
- [ ] No secrets or sensitive data in code
- [ ] Changes reviewed and approved
- [ ] Follows project conventions

---

## Important Constraints

### Do Not Modify
- [Specify protected files/directories, e.g., `config/production.json`, `migrations/`, etc.]

### Special Considerations
- [e.g., Maintain backward compatibility with v1.x API]
- [e.g., Performance: Keep response times under 200ms]
- [e.g., Security: All user input must be validated]

### Known Limitations
- [e.g., External API rate limits: 1000 requests/hour]
- [e.g., Legacy module X requires manual testing]

---

## Common Tasks

**Commit Messages**: Use conventional commits format
```
feat: add user authentication
fix: resolve memory leak in data processor
docs: update API documentation
chore: upgrade dependencies
```

**PR Workflow**:
1. Create feature branch from `main` or `develop`
2. Make changes with tests
3. Push and create PR with clear description
4. Address review feedback
5. Merge after approval

---

**For detailed guidelines, see [CLAUDE.full.md](./CLAUDE.full.md)**
