# impl — write-isolated implementation offload

> **Product role:** Long implementation / multi-file work delegated to Grok after design approval.  
> **Only write axis** in this product — isolation is mandatory (worktree or staging + write sandbox).  
> **Enforcement tier:** documented procedure. Host deny-until-design-approval gates are **not** shipped.

## Spec 5-kan (required)

Dispatch prompts must fill all five slots. Grok has zero session context — incomplete slots mean decisions are still open; do not hand ambiguity to the implementer.

| Slot | Meaning |
|------|---------|
| **Objective** | What to build or change (one paragraph) |
| **Files** | Exact paths to create or edit |
| **Interfaces** | Signatures, types, API shapes to match |
| **Constraints** | Project conventions and do-not-touch list |
| **Verification** | Commands that prove the change works |

English aliases for the same five slots (keep labels exact in the prompt body):
`Objective` · `Files` · `Interfaces` · `Constraints` · `Verification`

## Isolation

| Path type | Prepare | CWD for grok |
|-----------|---------|--------------|
| Git repo | `scripts/worktree-prepare.sh <repo> [base-ref]` | printed worktree path (never under `/tmp`) |
| Non-repo tree | `scripts/staging-prepare.sh <src-dir>` | printed staging path (rsync copy; hardlinks forbidden) |

Then invoke with write sandbox from Ready state:

- Sandbox value = **`$CGO_SANDBOX_WRITE`** (from cgo-env after install-sandbox + check).  
  Do **not** hardcode profile names in callers; invoke loads the key.
- Missing `CGO_SANDBOX_WRITE` → refuse-to-start (exit 2). Install write profile + re-run check.
- **No vault merge path** in this product. Review + merge is operator / orchestrator responsibility.
- **Silent Claude fallback forbidden** if Grok fails or times out: declare downgrade explicitly and wait for operator gate. Quietly implementing in Claude is out of contract.

## Fill-ins

| Placeholder | Meaning |
|-------------|---------|
| `{{DESIGN_PATH}}` / `{{TARGET_PATH}}` | Path to the 5-kan spec (or design that contains it) |
| `{{SSOT_PATHS}}` | Optional neighbor modules / interfaces for contrast |

## Sandbox / invoke

```bash
# 1) prepare isolation
WT="$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/worktree-prepare.sh" /path/to/repo)"
# or: ST="$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/staging-prepare.sh" /path/to/scripts-tree)"

# 2) invoke write mode (uses $CGO_SANDBOX_WRITE)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode impl --input /path/to/spec.md
# For real runs with CWD = worktree, prefer fanout W or pass --cwd via extra grok args
# after review; product default RUN_CWD is under plugin data for staging inputs.
```

- Model default: `grok-4.5` · effort high · max-turns 20 (override via `CGO_*` env).
- Usage log field2: `impl`.
- No product support for vault-specific merge tooling.

## Prompt body (injected into grok)

```
You are implementing from a five-slot spec. Write only under the current working directory (isolated worktree or staging). Do not modify files outside CWD.

Spec / design: {{TARGET_PATH}}
Optional interfaces / neighbors: {{SSOT_PATHS}}

You must honor exactly these five slots from the spec (labels required):

1. Objective — what to build or change
2. Files — create/edit only listed paths (under CWD)
3. Interfaces — match signatures, types, and API shapes
4. Constraints — follow project conventions; do not touch listed exclusions
5. Verification — run the stated proof commands from CWD when possible

Rules:
- Incomplete slots: stop and report what is missing; do not invent product requirements.
- If Grok cannot finish, report failure clearly. Do not imply a silent handoff to another model.
- No git network push. Prefer local file edits; leave commit/merge to the orchestrator.
- Secrets: do not print secret values. Do not read .env contents into the report.
- Hardlinks are forbidden in staging setups; if you see hardlink isolation, stop.

Output:
- Summary of files changed
- Verification command results (exit codes)
- Open risks / follow-ups for the orchestrator
```

## Operator notes

- **Prepare first, then invoke.** Product scripts: `worktree-prepare.sh` / `staging-prepare.sh`.
- **Merge:** orchestrator reviews `git diff` in the worktree (or staging baseline tag) and applies intentionally — no automated vault merge in this plugin.
- **Skip:** small edits where writing a 5-kan costs more than doing the change directly; use interactive Grok TUI instead.
