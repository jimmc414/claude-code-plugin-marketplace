---
description: Batch Grok audit over operator target list (candidates only)
disable-model-invocation: true
---

Batch audit. Contract: `${CLAUDE_PLUGIN_ROOT}/prompts/sweep.md`.

**User-only recommended** (`disable-model-invocation: true`). Weekly / manual cadence.

### 1. Ready state

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

### 2. Targets file

Copy and edit:

```text
# ~/.config/claude-grok-offload/sweep-targets.txt
# one absolute git repo path per line
```

Example template in the plugin package: `examples/sweep-targets.example.txt`  
(or under repo root `examples/` after install layout).

### 3. Run

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sweep_run.sh"
# or
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sweep_run.sh" /path/to/targets.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sweep_run.sh" /path/to/one-repo
# dry-run
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sweep_run.sh" --print-only /path/to/targets.txt
```

Outputs under `$CLAUDE_PLUGIN_DATA/sweep/` (or default plugin data dir).  
Sandbox = `$CGO_SANDBOX`. Candidates only — you merge/judge.
