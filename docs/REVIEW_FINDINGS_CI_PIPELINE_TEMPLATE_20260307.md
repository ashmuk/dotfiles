# Review Findings: CI Pipeline Template Fails Without Node.js Project

**Date**: 2026-03-07
**Status**: Open
**Severity**: High — all CI checks fail for non-Node.js projects

---

## Root Cause

The workflow templates `pr-checks.yml` and `deploy.yml` hard-code `actions/setup-node@v4` with `cache: 'npm'` and `npm ci` in all jobs. When a downstream project has no `package.json` or `package-lock.json` (e.g., litcrop), every job fails at the "Set up runtime" step because the npm cache action cannot find a lockfile.

This means **branch protection rules are unsatisfiable** for any project that hasn't added Node.js dependencies yet.

## Affected Files

| Template file | Issue |
|---|---|
| `templates/project/dot.github/workflows/pr-checks.yml` | All 4 jobs (`lint`, `test`, `build`, `pr-summary`) assume Node.js |
| `templates/project/dot.github/workflows/deploy.yml` | Same hard-coded Node.js setup |

**Unaffected**: `protect-main.yml` — shell-only, no runtime dependency.

## Recommended Fix: Approach D — Conditional Runtime Steps

Add a project-type detection step after checkout in each job. Gate runtime setup, dependency installation, and build steps on the detection result. Jobs always run and always succeed when no matching runtime is found, satisfying branch protection.

### Detection Step

```yaml
      - name: Detect project type
        id: detect
        run: |
          if [ -f package.json ]; then
            echo "has_nodejs=true" >> "$GITHUB_OUTPUT"
          else
            echo "has_nodejs=false" >> "$GITHUB_OUTPUT"
          fi
```

### Conditional Steps

```yaml
      - name: Set up runtime
        if: steps.detect.outputs.has_nodejs == 'true'
        uses: actions/setup-node@v4
        with:
          node-version-file: .node-version
          cache: 'npm'

      - name: Install dependencies
        if: steps.detect.outputs.has_nodejs == 'true'
        run: npm ci

      - name: Build
        if: steps.detect.outputs.has_nodejs == 'true'
        run: npm run build --if-present
```

### Why This Works

- Jobs always run (not skipped) so GitHub branch protection sees `success` status
- `pr-summary` needs no changes — upstream jobs still report `success`
- All existing TODO comments and multi-language examples in the templates are preserved
- Zero friction: new projects work immediately without editing workflows

### Why Not Alternatives

| Approach | Why rejected |
|---|---|
| **A — Skip entire jobs** via `if:` at job level | `skipped` status may not satisfy required branch protection checks |
| **B — Comment out defaults** | Higher friction; every new project must manually uncomment/edit CI |
| **C — Detection job + fan-out** | Over-engineered for a template; adds complexity without benefit |

## Prerequisite: Workflow Syncing

`.github/workflows/` is **not currently synced** by `fetch-from-upstream`. This means:

- Downstream projects cannot automatically receive CI template updates
- Each downstream project must manually copy workflow changes after a template fix
- A new sync tier for workflow files should be added to the `fetch-from-upstream` mechanism so that CI fixes propagate automatically

Until workflow syncing is implemented, any fix to the templates must be manually applied to existing downstream projects.

## Verification Checklist

After implementing the fix:

- [ ] A project with `package.json` still gets full lint/test/build CI
- [ ] A project without `package.json` has all jobs pass (steps skipped gracefully)
- [ ] Branch protection rules are satisfied in both cases
- [ ] `pr-summary` job correctly aggregates results
- [ ] `deploy.yml` handles the same conditional logic
