---
description: Adversarial design grill via Grok (read-only, fixture if no path)
---

Independent design review (documented maker≠checker). Full contract: `${CLAUDE_PLUGIN_ROOT}/prompts/grill.md`.

**Args:** optional design path(s). **No args** → package fixture `fixtures/first-run-design.md` (handled by invoke).

### 1. Ready state

If `${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/claude-grok-offload}/cgo-env` is missing or incomplete, run check first:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

Stop if `Ready: no` and follow the printed `reason:`.

### 2. Invoke

```bash
# No user path → fixture (S1 first-run)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode grill $ARGUMENTS

# Explicit path example (when $ARGUMENTS has a design path):
# bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode grill --input /path/to/design.md
```

Optional SSOT paths: pass extra `--input` flags after the design (invoke stages out-of-grant paths).  
Print-only dry run: add `--print-only`.

### 3. Report

Surface grok stdout, overall **PASS / REVISE**, and fatal/important findings.  
Do not treat this as a host deny-gate — product enforcement is procedural + RO sandbox only.
