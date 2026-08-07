---
description: Heavy/volume spend playbook (user-only; no auto burn)
disable-model-invocation: true
---

Meaningful Build volume checklist. Full playbook: `${CLAUDE_PLUGIN_ROOT}/prompts/heavy-burn.md`.

**User-only** (`disable-model-invocation: true`). The model must **not** auto-invoke this to “burn tokens.”

### 1. Check first

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

Stop if `Ready: no`. Write volume needs `CGO_SANDBOX_WRITE`.

### 2. Read playbook

Open `${CLAUDE_PLUGIN_ROOT}/prompts/heavy-burn.md` and follow the priority table.

### 3. Dispatch real work (examples)

```bash
# P0 impl (after 5-kan + worktree/staging prepare)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode impl --input /path/to/spec.md

# P0 verify-code
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode verify --verify-kind code --input /path/to/file

# P1 fanout R
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" R /path/to/tree "<recon prompt>"

# P2 sweep
bash "${CLAUDE_PLUGIN_ROOT}/scripts/sweep_run.sh" ~/.config/claude-grok-offload/sweep-targets.txt
```

### 4. Quota honesty

SuperGrok UI usage and CLI spend share a commercial pool. This product **does not** promise quota parity or a fixed burn budget. Prefer Settings → Usage as the absolute meter.
