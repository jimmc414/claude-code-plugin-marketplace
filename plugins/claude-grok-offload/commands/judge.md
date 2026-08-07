---
description: Option/decision judge via Grok (read-only)
---

Independent option scoring. Full contract: `${CLAUDE_PLUGIN_ROOT}/prompts/judge.md`.

**Args:** `<brief-path> [axes text…]` — path required. Axes free-form (default if omitted: cost, reversibility, ops burden, security).

### 1. Ready state

If cgo-env is missing, run check:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

Stop if `Ready: no`.

### 2. Invoke

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode judge --input <brief-path> $ARGUMENTS
```

Large decisions (real money / irreversible / security / global session): run invoke **three** times independently and majority-rank; daily small briefs = once.  
Dry run: `--print-only`.

### 3. Report

Surface ranking, spectrum note, out-of-list alternative, recommendation + counter-view, confidence.  
Judge evidence is not design-grill evidence.
