---
description: Run Ready state machine — grok binary, auth, fixture, sandbox mode
---

Run the plugin readiness check and persist sandbox mode to the state file.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"
```

**Probes (design §4.5):**

1. Resolve `grok` (`PATH` or `GROK_BINARY`)
2. Soft auth: `grok models` (timeout; skip when `CGO_MOCK_GROK=1`)
3. `PLUGIN_ROOT` / `CLAUDE_PLUGIN_ROOT`
4. `fixtures/first-run-design.md` exists and is non-empty
5. Prefer `cgo_ro` if installed in sandbox.toml → `CGO_SANDBOX=cgo_ro`, `CGO_STAGING=0`
6. Else built-in `strict` → `CGO_SANDBOX=strict`, `CGO_STAGING=1`
7. If `cgo_impl` present → `CGO_SANDBOX_WRITE=cgo_impl`

**Stdout:** `Ready: yes|no` plus mode lines.  
**Exit:** 0 if Ready:yes, 1 if Ready:no.  
**State file:** `${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/claude-grok-offload}/cgo-env`

If Ready:no, follow the printed `reason:` (install grok / auth / `:install-sandbox` / reinstall plugin).  
For tests, set `HOME`, `CLAUDE_PLUGIN_DATA`, and `GROK_SANDBOX_TOML` under a temp tree only — never point overrides at the live host config without intent.
