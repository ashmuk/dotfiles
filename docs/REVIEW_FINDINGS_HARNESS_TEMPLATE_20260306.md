# Review Findings: templates/ Harness (excluding experimental/)

**Date:** 2026-03-06
**Scope:** `templates/project/` and `templates/global/` (~55 files)
**Reviewers:** my-reviewer (agent harness) + my-reviewer (scaffolding/infra)

---

## Overall Rating: 7.0 / 10

| Dimension | Agent Harness | Scaffolding/Infra | Combined |
|-----------|:---:|:---:|:---:|
| **Robustness** | 7 | 7 | 7 |
| **Smartness** | 8 | 8 | 8 |
| **Safety** | 8 | 7 | 7.5 |
| **Coherence** | 7 | 5 | 6 |
| **Overall** | **7.5** | **6.5** | **7.0** |

**Top-line**: The agent coordination system (subagents, skills, prompts, remediation loop) is well-architected and production-ready. The scaffolding infrastructure (sync, upstream management, init wizard) is cleverly engineered. The main drag is **project-specific content leaked into generic templates** -- README, GitHub workflows, and PR template are hardcoded to an Astro/AWS portfolio site.

---

## MUST-FIX (7 findings)

| # | File | Issue |
|---|------|-------|
| 1 | `dot.agent/README.md:118-121` | Subagent listing stale -- uses old names (no `my-` prefix), omits `my-designer` |
| 2 | `dot.agent/README.md:115-116` | Skills listing omits `cc-test` and `cc-remediate` |
| 3 | `README.md` | Pre-filled with Astro/Tailwind/AWS portfolio content instead of generic placeholders |
| 4 | `PLANS.example.md` | Filename mismatch -- `setup_project.sh` copies `PLANS.md` which doesn't exist |
| 5 | `dot.github/workflows/pr-checks.yml:9-10` | Path filter hardcoded to `frontend/**` -- misses root files entirely |
| 6 | `dot.github/workflows/pr-checks.yml:128` + `deploy.yml` | Astro-specific checks and S3/CloudFront deploy -- not generic |
| 7 | `scripts/boilerplate/push-to-upstream.sh:357-369` | `prompt_user` return code bug -- `local result=$?` after `if !` never captures correctly; diff-then-re-prompt path unreachable |

## SHOULD-FIX (13 findings)

| # | File | Issue |
|---|------|-------|
| 1 | `commands/cc-commit.md:16` | Suggests `git add -p` (interactive) which doesn't work in Claude Code |
| 2 | `commands/cc-push.md:12` | `git log origin/...` fails when no upstream tracking branch exists |
| 3 | `commands/cc-pr-create.md:20-22` | Default base conflicts with documented Git Flow (`develop` should be default for feature branches) |
| 4 | `skills/cc-define.md:28` | Auto-chains to cc-design -- should "suggest" not "invoke" |
| 5 | `skills/cc-implement.md:24` | Recommends Haiku/Sonnet with no guidance on when to choose which |
| 6 | `skills/cc-design.md:32-34` | Assumes Task tool accepts `model='opus'` parameter -- may not exist |
| 7 | `skills/cc-review.md:21` | Hardcoded `.claude/agents/` path instead of source-of-truth `.agent/subagents/` |
| 8 | `prompts/design/design_system_prompt.md:81` | Pandoc-specific `{=html}` syntax won't render in standard markdown |
| 9 | `dot.agent/mcp/README.md:58` | References `servers/*.json` that don't ship with template |
| 10 | `dot.devcontainer/post-create.sh:9` | Uses `set -e` but not `set -euo pipefail` (inconsistent with other scripts) |
| 11 | `dot.devcontainer/post-create.sh:231-241` | Custom hooks execute arbitrary YAML commands without sandboxing |
| 12 | `dot.github/workflows/protect-main.yml:22` | Squash merge regex is brittle -- GitHub uses PR title, not fixed prefix |
| 13 | `dot.devcontainer/lib/parse-requirements.sh` | Library exists but `post-create.sh` duplicates its logic instead of sourcing it |

## SUGGESTION (10 findings)

| # | File | Issue |
|---|------|-------|
| 1 | `commands/cc-commit.md` | No handling for detached HEAD state |
| 2 | `prompts/design/design_prompts_critique_and_code.md` | Two prompts in one file breaks one-file-one-prompt convention |
| 3 | `prompts/design/*.md` | Pandoc-escaped `\[PLACEHOLDER\]` brackets look awkward in standard markdown |
| 4 | `dot.agent/starters/PLANS.md:7-10` | Stage numbering inconsistent with PROJECT.staged.yaml |
| 5 | `dot.devcontainer/init-firewall.sh` | Entire script is a no-op (exits 0 immediately) |
| 6 | `scripts/boilerplate/init-project.sh:504-518` | `git add .` could stage secrets if .gitignore not deployed |
| 7 | `scripts/boilerplate/init-project.sh:589` | `--no-verify` on initial push (arguably justified) |
| 8 | `scripts/boilerplate/sync-agents.sh:19` | Silently removes manually placed .md files from `.claude/agents/` |
| 9 | `scripts/boilerplate/fetch-from-upstream.sh:249` | sed fallback only updates timestamp, per-file metadata becomes stale |
| 10 | `commands/cc-push.md` | No merge conflict detection before push |

---

## Key Strengths

- **Agent separation of concerns** -- analyst/architect/designer/builder/reviewer boundaries are clean and well-documented
- **Remediation loop** -- 3-iteration cap with systemic issue escalation prevents infinite fix cycles
- **Safety gates** -- reviewer is strictly read-only, destructive ops require approval, upstream sync creates timestamped backups
- **Multi-AI sync system** -- `.agent/` as single source of truth syncing to Claude/Cursor/Codex is clever
- **Security prompts** -- current frameworks (CVSS v4.0, NIST 800-61r3, SLSA v1.0, OWASP 2021) with good lifecycle coverage
- **Init wizard** -- excellent interrupt recovery and partial state handling
- **Upstream sync** -- tiered system with backup/divergence detection is sophisticated

## Key Weakness

**Template is half-generic, half-project-specific.** README, GitHub workflows, PR template, and path filters are all baked to one Astro/AWS project. This is the single biggest barrier to reusability and accounts for most of the coherence score drag.

---

## Recommendations (Priority Order)

1. **Genericize project-specific templates** -- README.md, pr-checks.yml, deploy.yml, PULL_REQUEST_TEMPLATE.md
2. **Fix PLANS filename mismatch** -- rename or update setup_project.sh reference
3. **Fix push-to-upstream.sh prompt_user bug** -- restructure return code capture
4. **Update dot.agent/README.md** -- reflect current `my-` prefixed filenames and full skill inventory
5. **Harden git commands** -- handle no-upstream, detached HEAD, and conflict states
6. **Align cc-pr-create with Git Flow** -- default base to `develop` for feature branches
7. **Clean up Pandoc artifacts** -- remove `{=html}` blocks and escaped brackets from design prompts
8. **Use parse-requirements.sh library** -- eliminate duplication in post-create.sh
