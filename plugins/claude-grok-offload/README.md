# claude-grok-offload (plugin package)

Claude Code plugin: offload grill / verify / judge / impl / fanout / sweep to Grok CLI.

## Quick path

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-sandbox-profiles.sh"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cgo-check.sh"          # Ready: yes
bash "${CLAUDE_PLUGIN_ROOT}/scripts/invoke-grok.sh" --mode grill
```

## Scripts

| Script | Role |
|--------|------|
| `cgo-check.sh` | Ready state → `cgo-env` |
| `install-sandbox-profiles.sh` | `cgo_ro` / `cgo_impl` fragments |
| `invoke-grok.sh` | Shared invoke (`$CGO_SANDBOX` / `$CGO_SANDBOX_WRITE`) |
| `worktree-prepare.sh` | Non-temp git worktree |
| `staging-prepare.sh` | Copy tree; hardlink flags denied |
| `fanout_run.sh` | R/W fan-out (child cwd = target; no parent `/tmp`) |
| `sweep_run.sh` | Batch audit from targets file |

## Docs

Root repo [README.md](../../README.md) · [docs/REVERSE.md](../../docs/REVERSE.md) · [NOTICE](../../NOTICE)

**skills.sh** is not supported. Maker≠checker is documented procedure only.
