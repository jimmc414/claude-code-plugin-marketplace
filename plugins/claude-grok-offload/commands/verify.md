---
description: Plan/code/fact verify via Grok (read-only)
---

Low-cost independent verification. Full contract: `${CLAUDE_PLUGIN_ROOT}/prompts/verify.md`.

**Args:** `<target-path> [plan|code|fact] [extra context paths…]`  
Default kind if omitted: `plan`. Target path is **required** (unlike grill — no fixture fallback).

### 1. Ready state

If cgo-env is missing, run check:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

Stop if `Ready: no`.

### 2. Parse args and invoke

Treat first path as `--input` target. If a bare token is `plan`, `code`, or `fact`, use it as `--verify-kind`. Remaining paths are further `--input` context.

```bash
# Example: plan verify
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode verify --verify-kind plan --input <target> $ARGUMENTS

# Example: code
# bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode verify --verify-kind code --input <file-or-diff>

# Example: fact (web tools allowed by invoke)
# bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode verify --verify-kind fact --input <research.md>
```

Prefer building the argv so `--verify-kind` is set explicitly from user intent.  
Dry run: `--print-only`.

### 3. Report

Surface **PASS / REVISE** and findings. Log tag on the data dir is `verify-<kind>`.  
Not a substitute for design grill; not a product-level code-entry deny.
