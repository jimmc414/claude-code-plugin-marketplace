---
description: Install portable cgo_ro/cgo_impl sandbox profiles into ~/.grok/sandbox.toml
---

Install the plugin's portable sandbox profiles (`cgo_ro`, `cgo_impl`) into the user Grok sandbox config.

Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-sandbox-profiles.sh"
```

- Upserts only `[profiles.cgo_ro]` and `[profiles.cgo_impl]`; other profiles are preserved.
- Backs up an existing file to `sandbox.toml.bak.<utc>` before writing.
- Expands `$HOME` to an absolute path (no tilde in the written file).
- Override target with `GROK_SANDBOX_TOML` when testing.

Report exit status and the resolved sandbox.toml path to the user.
