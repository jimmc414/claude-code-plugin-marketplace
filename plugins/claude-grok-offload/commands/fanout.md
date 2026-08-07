---
description: Parallel Grok fan-out (R=read targets, W=write worktrees)
disable-model-invocation: true
---

Parallel low-stakes offload. Contract: `${CLAUDE_PLUGIN_ROOT}/prompts/fanout.md`.

**User / orchestrator only** (`disable-model-invocation: true`). Do not fire without an explicit N-item plan.

**Args:** `R|W` plus paths / prompt text as needed.

### 1. Ready state

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

W mode needs `CGO_SANDBOX_WRITE`.

### 2. Mode R (read)

Each child **cwd = target path**. Product does **not** `cd /tmp` on the parent.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" R /path/to/tree "spawn N read-only recon children; report findings"
# dry-run
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" --print-only R /path/to/tree "probe"
```

Sandbox = `$CGO_SANDBOX`.

### 3. Mode W (write)

Prepare worktrees first, then one call per worktree (or orchestrate N calls):

```bash
WT="$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/worktree-prepare.sh" /path/to/repo)"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" W "$WT" "<5-kan spec for item i>"
```

Sandbox = `$CGO_SANDBOX_WRITE`.

### 4. Fan-in

Orchestrator judges adoption. Example job shapes: `examples/fanout-jobs.example.yaml`.
