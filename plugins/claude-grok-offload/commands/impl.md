---
description: Worktree/staging write impl via Grok (5-kan spec; needs CGO_SANDBOX_WRITE)
disable-model-invocation: true
---

Write-isolated implementation offload. Full contract: `${CLAUDE_PLUGIN_ROOT}/prompts/impl.md`.

**Model auto-invocation is disabled** (`disable-model-invocation: true`). This command is for **user / orchestrator** use after design approval — not for the model to fire mid-turn without a filled 5-kan spec.

**Args:** path to a 5-kan spec (or design containing Objective / Files / Interfaces / Constraints / Verification). Optional second token: `repo:<path>` or `stage:<path>` for prepare hints.

### 1. Ready state + write key

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

Stop if `Ready: no`. Write mode requires **`CGO_SANDBOX_WRITE`** in cgo-env (install write sandbox profile, then check again).  
Invoke refuses write modes when that key is missing.

### 2. Prepare isolation

**Git repo (worktree):**

```bash
WT="$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/worktree-prepare.sh" /path/to/repo)"
# stdout = non-temp worktree path (under repo/.cgo-worktrees/ by default)
```

**Non-repo tree (staging copy):**

```bash
ST="$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/staging-prepare.sh" /path/to/src-dir)"
# rejects hardlink flags (--link, -H); rsync -a --copy-links
```

Never place worktrees under `/tmp` (sandbox temp rules void CWD isolation).

### 3. Invoke

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode impl --input <spec-path> $ARGUMENTS
```

Sandbox value comes from **`$CGO_SANDBOX_WRITE`** (not a hardcoded profile name in the command).  
Dry run: `--print-only`.

### 4. Review and merge

- Review `git diff` in the worktree (or staging baseline tag).
- Merge is **operator responsibility** — this product does **not** ship vault merge or auto-apply.
- On Grok failure/timeout: **declare** downgrade to the user; do **not** silently implement in Claude.

### 5. Cleanup

```bash
# after merge decision
git -C /path/to/repo worktree remove "$WT"
# or rm -rf staging path when discarded
```
