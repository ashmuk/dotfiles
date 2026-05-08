# Design: `policy-guard.sh` PreToolUse Hook

**Status:** Implemented + hardened (2026-05-08)
**Date:** 2026-05-08
**Related:** `docs/feedback/REMEDIATION.md` (Escalations + cycle 2), `docs/feedback/REVIEW-FINDINGS.md` (F-01)
**Implementation:** `config/claude/hooks/policy-guard.sh`; wired into `config/claude/settings.json` under `hooks.PreToolUse` Bash matcher; deployed via `make install-claude`. 36 verified test cases pass; 2 known limitations documented.
**Post-implementation hardening (cc-remediate cycle 2):** missing-jq fail-open now writes to stderr; `@tsv` + `read` replaced with two `jq -r` calls so real tabs and multi-line commands no longer slip through. Same hardening applied to `security-guard.sh` for parity.

---

## Context

A previous review (F-01) found that `config/claude/settings.json` carried a non-functional `autoMode.soft_deny` block whose strings (`"Never run terraform apply"`, `"Never push to main without review"`) read like enforced policy but were silently ignored by the harness — there is no `autoMode` key in the Claude Code settings schema. `/cc-remediate` removed the block to eliminate the false-confidence drift, with the actual enforcement deferred to a hook design (this document).

Two reasons a hook is the right enforcement mechanism, not `permissions.deny`:

1. **`--dangerously-skip-permissions` bypass.** The repo's `cld-teams-hard` alias enables this flag, which discards the deny list entirely. Hooks run regardless of permission mode.
2. **Pattern matching, not glob matching.** `permissions.deny` patterns operate on tool-call shapes (`Bash(git push:*)`); they cannot inspect *what* the `git push` actually targets. Refspec analysis requires a script.

This hook joins `security-guard.sh` (dangerous-command blocker) and `file-guard.sh` (sensitive-file warner) under `hooks.PreToolUse`.

---

## Decisions

### D1. Scope

**Chosen:** block `terraform apply`, `terraform destroy`, and `git push` whose refspec writes to `main` or `master` (including delete and force-rename variants).

**Reasoning:**
- `terraform apply` is the verbatim string from the original (silently ignored) policy. `terraform destroy` is its destructive twin and shares the same intent — irreversible state change against real infra. Adding it now costs one regex; deferring it leaves an obvious gap.
- `git push … main/master` is the second verbatim policy string. The trickiness is in *correctly* identifying main-targeting refspecs across all the syntactic forms `git push` accepts (see Patterns).
- **Out of scope, deliberately:**
  - `git push --force` / `-f` to main, `git reset --hard`, `rm -rf /`, `chmod 777`, `eval`, `bash -c`, `DROP TABLE` — already covered by `security-guard.sh`. Duplicating them here multiplies the maintenance surface for zero added safety.
  - `kubectl apply` to prod, `aws … --profile prod`, `gh release create`, npm/cargo publish, etc. — see Open Questions.
  - Non-`Bash` tools. Hook is `Bash`-matcher only, matching `security-guard.sh`.

### D2. Bypass mechanism

**Chosen:** environment variable `POLICY_GUARD_BYPASS=1`. When set, the hook short-circuits to `exit 0` with no evaluation.

**Reasoning:**
- `PreToolUse` hooks have **no TTY**. Stdin is the JSON payload; stdout/stderr are captured by the harness. There is no way to interactively prompt the user.
- An env-var override is not a security weakness — anyone able to set the env var is already running arbitrary code, and anyone editing the hook itself can disable it. The threat model (see below) is "the model auto-pilots into a destructive command," not "a hostile actor with shell access."
- The bypass is **per-session, not per-command**. The user must consciously prefix the *Claude launch* (e.g. `POLICY_GUARD_BYPASS=1 cld-teams-hard`) to disable it. This is the right friction point: the user opts into the looser policy at the moment they make that choice.
- Stderr on a block must mention the variable so the user knows the escape hatch exists.

### D3. Path / propagation

**Chosen:** `config/claude/hooks/policy-guard.sh` in this repo, propagated to `~/.claude/hooks/policy-guard.sh` via the existing `make install-claude` symlink loop.

**Reasoning:** Verified by reading `config/claude/setup_claude.sh`:

```bash
for hook_script in "$DOTFILES_DIR/config/claude/hooks/"*.sh; do
  [[ -f "$hook_script" ]] || continue
  ln -sf "$hook_script" "$HOME/.claude/hooks/$(basename "$hook_script")"
done
```

Any new `*.sh` in `config/claude/hooks/` is auto-symlinked on next `make install-claude` run. No Makefile change required. Confirmed by `ls -la ~/.claude/hooks/` — every existing hook is already a symlink to `config/claude/hooks/`.

---

## Threat Model

**The hook protects against:**
- The model auto-piloting into a destructive command under elevated permissions (`cld-teams-hard` / `--dangerously-skip-permissions`).
- A skilled-but-tired user (the operator) approving a tool call without noticing it targets `main` or runs `terraform apply`.
- Drift from intent: the user said "no `terraform apply`" once; the hook makes that durable across sessions.

**The hook does NOT protect against:**
- **Encoded / obfuscated commands.** `bash -c "$(echo Z2l0IHB1c2gg... | base64 -d)"` — defeats regex. Same caveat as `security-guard.sh`. (Note: `security-guard.sh` already blocks `bash -c` and `eval`, which raises the bar a little.)
- **Aliasing.** `alias gpm='git push origin main'; gpm` — `gpm` doesn't match. Out of scope.
- **Indirect execution.** Writing the command to a script file then executing it. Out of scope.
- **Variable indirection.** `B=main; git push origin "$B"` — won't match. Out of scope.
- **Non-`main` branches that the user considers protected** (`production`, `release/*`, etc.). Future work.
- **Tool calls other than `Bash`.** Edits to `.tf` files, MCP-driven git operations, etc. Out of scope for this iteration.

This is best-effort guardrail-as-checklist, not a sandbox. The same one-line caveat lives in `security-guard.sh`; the design accepts it explicitly rather than pretending otherwise.

---

## Hook Contract

Identical to `security-guard.sh` to keep the wire-up uniform.

**Stdin:** JSON payload from the harness:
```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "git push origin main" }
}
```

**Parsing:** single `jq` call extracting `[.tool_name // "", .tool_input.command // ""] | @tsv`, identical to `security-guard.sh`.

**Early exits (`exit 0`):**
- `tool_name != "Bash"` — not our concern.
- `POLICY_GUARD_BYPASS=1` — explicit override.
- Empty command string.

**Block (`exit 2`):**
- Pattern matched. Stderr line: `Blocked by policy-guard: <reason>. Set POLICY_GUARD_BYPASS=1 to override.`
- One stderr line per block. Reason must identify which rule fired (e.g. `terraform apply`, `git push to main`).

**Allow (`exit 0`):** no patterns matched.

**Anything else:** treated by harness as unexpected error. The script must be defensively written so jq failures or unset vars don't take this path — use `set -u` carefully or omit it (security-guard.sh omits it).

**Ordering with `security-guard.sh`:** Claude Code runs all matching `PreToolUse` hooks; if **any** exits non-zero with output, the call is blocked. Order within the array does not affect *whether* a block happens, but it does affect which stderr the user sees first if both fire. That's not load-bearing — we list `policy-guard.sh` *after* `security-guard.sh` so the older, broader rules report first when a single command trips both (e.g. `git push --force origin main` trips both — `security-guard.sh`'s force-push rule is the more actionable message).

---

## Patterns

### P1. `terraform apply` / `terraform destroy`

```regex
\bterraform\s+(apply|destroy)\b
```

**Should match:**
- `terraform apply`
- `terraform apply -auto-approve`
- `terraform apply -target=module.foo`
- `terraform apply -var-file=prod.tfvars`
- `cd infra && terraform apply`
- `terraform destroy -auto-approve`

**Should NOT match:**
- `terraform plan`
- `terraform validate`
- `terraform-apply.sh` — hyphen breaks `\s+`
- `# terraform apply` in a quoted heredoc — *will* match; accepted false-positive (same caveat as `security-guard.sh`'s `eval` rule)

### P2. `git push` to `main` / `master`

This is the load-bearing pattern. The naive `git push.*main` is wrong (matches `git push origin feature/main-page`). The token-anchored form:

```regex
\bgit\s+push\b.*(^|[[:space:]:+])(main|master)([[:space:]:^~]|$)
```

Read it as: "the line contains `git push`, AND somewhere later there is a `main` or `master` token bounded by whitespace, `:`, `+`, `^`, `~`, or line end."

The boundary classes are chosen against actual `git push` refspec syntax:
- **Leading boundary** — start-of-line, whitespace, `:` (in `HEAD:main`), or `+` (in `+main` for force).
- **Trailing boundary** — end-of-line, whitespace, `:` (in `main:main`), `^`/`~` (revision suffixes like `main^1`).

This excludes:
- `feature/main-page` — preceded by `/`, not in class.
- `maintenance` — followed by `t`, not in class.
- `mainline` — followed by `l`, not in class.

**Should match (block):**
- `git push origin main`
- `git push origin master`
- `git push origin HEAD:main`              ← refspec `src:dst`
- `git push origin main:main`
- `git push origin feature/foo:main`        ← rename-to-main on push
- `git push origin :main`                   ← delete remote main
- `git push origin --delete main`
- `git push origin -d main`
- `git push --set-upstream origin main`
- `git push -u origin master`
- `git push origin +main`                   ← force via `+` prefix
- `git push origin main^`                   ← unusual but valid

**Should NOT match (allow):**
- `git push origin develop`
- `git push origin feature/main-page`       ← substring inside branch name
- `git push origin maintenance`              ← prefix collision
- `git push origin release/v1.0`
- `git push origin HEAD:feature/foo`
- `git fetch origin main`                   ← not `git push`
- `cat main.md && git push origin develop`  ← `main` appears, but not as a refspec token after `git push`

**Known false-positive (accepted):** `git push origin develop && echo main` — matches because `main` appears as a token after `git push`. Acceptable: the user can always bypass with the env var, and this construction is rare. Documenting it here so future maintainers know it's deliberate, not a bug.

**Known false-negative (accepted):** `git push origin "main"` — quotes survive into the command string the hook sees. The leading boundary `[[:space:]:+]` doesn't include `"`, so this slips through. Fix is trivial (add `"'` to the class) and should be done in implementation; flagging here so cc-implement adds `"` and `'` to both boundary classes:

```regex
\bgit\s+push\b.*(^|[[:space:]:+"'])(main|master)([[:space:]:^~"']|$)
```

cc-implement: use the **quote-aware version above**, not the simpler one.

### P3. Combining

Both patterns evaluated independently. On match, identify which rule (P1 or P2) for the stderr message. Use the same `for p in ...; do grep -qE -- "$p" && echo ...; done` style as `security-guard.sh` for consistency.

---

## Bypass

**Check location:** immediately after parsing `tool_name` and confirming it's `Bash`, before any pattern evaluation. Skipping pattern evaluation on bypass is correct — there is no "log but allow" mode (that would be infrastructure this small hook does not need).

```bash
if [ "${POLICY_GUARD_BYPASS:-}" = "1" ]; then
  exit 0
fi
```

**Stderr on block:**
```
Blocked by policy-guard: <rule>. Set POLICY_GUARD_BYPASS=1 to override.
```

The bypass-hint suffix is mandatory on every block message so the user is never stuck wondering how to proceed.

**Anti-pattern explicitly avoided:** truthy parsing of arbitrary values (`true`, `yes`, `on`). Exact-match on `1` keeps the contract crisp and prevents accidental enabling via shell quirks.

---

## Settings.json Wire-up

Add a single object inside the existing `hooks.PreToolUse` array, alongside the current `security-guard.sh` entry. The matcher is identical (`Bash`); since Claude Code runs all matching hooks, sharing the matcher means both fire on every Bash call, which is what we want.

**Snippet to add** (cc-implement places this after the existing `security-guard.sh` entry, sharing the same `matcher: "Bash"` array OR as a sibling object — see ordering note below):

```jsonc
{
  "matcher": "Bash",
  "hooks": [
    { "type": "command", "command": "~/.claude/hooks/security-guard.sh" },
    { "type": "command", "command": "~/.claude/hooks/policy-guard.sh" }
  ]
}
```

**Why combine into one object instead of adding a sibling:** keeping both `Bash`-matcher hooks under a single `hooks` array is canonical and matches how the existing `Write|Edit` PostToolUse / PreToolUse entries are organized. cc-implement should *modify the existing object*, not append a new one.

**Ordering note:** within the `hooks` array, `security-guard.sh` first, `policy-guard.sh` second. Claude Code runs them in array order; on a command that trips both (e.g. `git push --force origin main`), the user sees `security-guard.sh`'s force-push message first. That message is more actionable ("never force-push to main") than policy-guard's generic block.

---

## Sync / Propagation

**Source:** `config/claude/hooks/policy-guard.sh` (this repo, version-controlled)
**Target:** `~/.claude/hooks/policy-guard.sh` (symlink)
**Mechanism:** `config/claude/setup_claude.sh`'s deploy loop, invoked by `make install-claude`.

**Verification (already confirmed):**
```
~/.claude/hooks/security-guard.sh -> /Users/hmukai/dotfiles/config/claude/hooks/security-guard.sh
```
All existing hooks are symlinks. The deploy loop globs `*.sh`, so a new file in `config/claude/hooks/` is picked up automatically — **no Makefile or setup-script change required**.

**Post-implementation step for cc-implement:**
1. `chmod +x config/claude/hooks/policy-guard.sh` (the loop doesn't chmod; the file must be executable in-repo).
2. Run `make install-claude` once to create the symlink on the current machine.
3. Verify `ls -la ~/.claude/hooks/policy-guard.sh` shows a symlink to the dotfiles path.

---

## Test Plan

Run these manually after implementation. Each invokes the hook directly via piped JSON, mirroring how the harness invokes it. No need to round-trip through Claude Code itself for unit-level confidence.

**Helper:**
```bash
test_hook() {
  local cmd="$1"
  printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$cmd" '$c')" \
    | ~/.claude/hooks/policy-guard.sh
  echo "exit=$?"
}
```

### Should BLOCK (exit 2, stderr message)

| # | Command | Reason |
|---|---------|--------|
| 1 | `terraform apply` | P1 base case |
| 2 | `terraform apply -auto-approve` | P1 with flag |
| 3 | `terraform destroy -target=module.db` | P1 destroy variant |
| 4 | `git push origin main` | P2 base case |
| 5 | `git push origin HEAD:master` | P2 refspec form |
| 6 | `git push origin :main` | P2 delete-remote form |
| 7 | `git push --set-upstream origin main` | P2 with `-u` |
| 8 | `git push origin feature/x:main` | P2 rename-to-main |
| 9 | `cd infra && terraform apply` | P1 in compound command |

### Should ALLOW (exit 0, no stderr)

| # | Command | Why allowed |
|---|---------|-------------|
| 10 | `terraform plan` | Not destroy/apply |
| 11 | `terraform validate` | Not destroy/apply |
| 12 | `git push origin develop` | Not main/master |
| 13 | `git push origin feature/main-page` | `main` substring inside branch |
| 14 | `git push origin maintenance` | Prefix collision |
| 15 | `git fetch origin main` | Not `git push` |
| 16 | `cat main.md` | Unrelated |
| 17 | `./terraform-apply.sh` | Hyphen, not whitespace |

### Should BYPASS (exit 0 even on otherwise-blocked input)

| # | Command | Env |
|---|---------|-----|
| 18 | `terraform apply` | `POLICY_GUARD_BYPASS=1` |
| 19 | `git push origin main` | `POLICY_GUARD_BYPASS=1` |

### Should still allow non-Bash tools

| # | Tool | Expected |
|---|------|----------|
| 20 | `tool_name=Edit` with `terraform apply` literally in `file_path` | exit 0 (not our matcher) |

### Acceptance

All 20 cases pass. Capture a transcript in the implementation PR description.

### Post-Implementation Verification (added 2026-05-08, cc-remediate cycle 2)

Sixteen additional cases were verified against the live hook. They are not strictly required by the original spec but document the boundary-class subtleties so future maintainers can re-validate after regex edits.

#### Refspec / quoting variants — should BLOCK

| # | Command | Why |
|---|---------|-----|
| 21 | `git push origin "main"` | Double-quoted main; quote-aware boundary class catches it |
| 22 | `git push origin 'main'` | Single-quoted main |
| 23 | `git push origin main^` | Revision suffix (`^`) — caret is in trailing class |
| 24 | `git push origin main^1` | `^1` revision form |
| 25 | `git push origin main~` | `~` revision suffix |
| 26 | `git push origin +main` | Force-prefix `+` is in leading class |
| 27 | `git push origin main:main` | Refspec form |
| 28 | `git push origin -d main` | `-d` short delete |
| 29 | `git push origin --delete main` | `--delete` long form |
| 30 | `terraform apply file.tfplan` | TF apply with plan file argument |

#### Boundary-class allows — should ALLOW

| # | Command | Why allowed |
|---|---------|-------------|
| 31 | `Git push origin main` | Case-sensitive `\bgit` — uppercase doesn't match (parity with `security-guard.sh`) |
| 32 | `git push origin mainline` | `mainline` ≠ `main` — `l` not in trailing class |
| 33 | `git push origin main-page` | `main-page` ≠ `main` — `-` not in trailing class |
| 34 | `git push origin foo/main` | `foo/main` is a *different* branch — `/` not in leading class |

#### F-01 evasion cases — should BLOCK (fixed in cc-remediate cycle 2)

These were added after discovering the original `@tsv` + `read` pipeline escaped real tabs and truncated at the first newline. Two-jq-call pipeline now preserves real whitespace; grep's default line-by-line scan handles multi-line.

| # | Command (raw) | Why |
|---|---------------|-----|
| 35 | `git<TAB>push origin main` | Real tab between `git` and `push` |
| 36 | `terraform<TAB>apply` | Real tab between `terraform` and `apply` |
| 37 | `echo hi\nterraform apply` (real newline) | Multi-line; line 2 trips P1 |
| 38 | `git push origin develop\nterraform apply` (real newline) | Allowed first line, blocked second line |

#### Known gaps — accepted, not blocked

| # | Command | Why accepted |
|---|---------|--------------|
| 39 | `git push origin\nmain` (real newline mid-refspec) | bash backslash continuation evasion — gap in line-by-line regex; documented in Threat Model |
| 40 | `git push origin develop && echo main` | Compound statement; `main` as token after `git push` triggers P2 — documented "accepted false-positive" in Patterns §

---

## Open Questions / Future Work

These are deliberately **not** in scope for this iteration. They are listed so the user can decide later, not now.

1. **`kubectl apply` / `kubectl delete` against prod contexts.** Would require parsing the current kubeconfig context, which is not in the command string. Probably best done as a separate hook reading `kubectl config current-context` rather than pattern-matching the command.
2. **`aws … --profile prod` (or `--profile production`).** Single-line regex is feasible (`\baws\b.*--profile[\s=](prod|production)\b`). Defer until there's a concrete prod profile to match.
3. **GitHub release / publish operations.** `gh release create`, `npm publish`, `cargo publish`, `docker push <prod-registry>` — all already in `permissions.ask`, which suffices unless `--dangerously-skip-permissions` is in play. Re-evaluate when the user starts shipping packages.
4. **Branch list as config.** Currently `main`/`master` are hardcoded. A future version could read protected branches from a sidecar file (e.g. `~/.claude/policy-guard.conf`) so per-project additions (`production`, `release/*`) don't require editing the script. **Defer until needed** — adding config without a second use case is premature.
5. **Logging.** No log of blocked attempts is written. If the user ever wants to audit "how often did the model try to push to main last week", we'd add an append to `~/.claude/logs/policy-guard.log`. Defer.
6. **Per-project policy.** A repo-local `.claude/policy-guard.conf` overriding the global list. Same deferral reasoning as #4.
7. **Test framework.** A `tests/policy-guard.bats` (or shell-equivalent) to run the test plan automatically. Worth adding once one of #4–6 lands and the script accumulates real complexity.

---

## Implementation Checklist

For cc-implement to execute. Strictly file-by-file.

### 1. Create `config/claude/hooks/policy-guard.sh`

- Shebang `#!/bin/bash`. No `set -e` (matches `security-guard.sh`).
- Read stdin into `INPUT`.
- Single `jq` call: `read -r TOOL COMMAND < <(printf '%s' "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv')`.
- Early exit 0 if `TOOL != "Bash"`.
- Early exit 0 if `${POLICY_GUARD_BYPASS:-} = "1"`.
- Early exit 0 if `COMMAND` empty.
- Define two patterns (use the **quote-aware** P2):
  - `TF_PATTERN='\bterraform\s+(apply|destroy)\b'`
  - `GP_PATTERN='\bgit\s+push\b.*(^|[[:space:]:+"'\''])(main|master)([[:space:]:^~"'\'']|$)'`
- For each, `grep -qE`; on match emit `Blocked by policy-guard: <rule>. Set POLICY_GUARD_BYPASS=1 to override.` to stderr and `exit 2`.
- Final `exit 0`.

### 2. Make it executable

```
chmod +x config/claude/hooks/policy-guard.sh
```

### 3. Edit `config/claude/settings.json`

Modify the existing PreToolUse `Bash`-matcher object (do **not** add a sibling). Append the policy-guard entry to the existing `hooks` array, after `security-guard.sh`:

```jsonc
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [
      { "type": "command", "command": "~/.claude/hooks/security-guard.sh" },
      { "type": "command", "command": "~/.claude/hooks/policy-guard.sh" }
    ]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [
      { "type": "command", "command": "~/.claude/hooks/file-guard.sh" }
    ]
  }
]
```

### 4. Deploy locally

```
make install-claude
ls -la ~/.claude/hooks/policy-guard.sh   # expect symlink to dotfiles path
```

### 5. Run the Test Plan

Capture exit codes for cases 1–20 above. Attach transcript to the PR.

### 6. Update `docs/feedback/REMEDIATION.md`

Mark the F-01 follow-up as RESOLVED and link to this design + the implementing PR.

### 7. Commit

Conventional message: `feat(claude/hooks): add policy-guard for terraform apply and git push to main`.
