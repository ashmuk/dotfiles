# Prompt: Refactor (Safe & Minimal)

**Goal**: Improve code readability and maintainability while minimizing side effects.

**Steps**
1. Summarize purpose and constraints in one paragraph (performance, compatibility, API surface)
2. List issues (max 5 items with rationale)
3. Propose changes (in small commit units)
4. Suggest patches (code blocks per file)
5. Risks/regression test plan (bullet points)

**Constraints**
- Don't break existing public APIs
- No type errors/linter errors
- Supplement code intent with comments/docstrings

**Acceptance Checklist**
- [ ] Type checking/linting passes
- [ ] Existing tests are green
- [ ] Main logic intent is explainable
- [ ] Change rationale and impact summarized in PR description
