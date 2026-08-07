# fanout — parallel low-stakes offload (R read / W write)

> **Product role:** N parallel low-stakes jobs. Not grill/verify/judge/impl.  
> **Orchestrator** (Claude session or operator) owns fan-in judgment.  
> **Enforcement:** documented-tier wrapper `scripts/fanout_run.sh`.

## Modes

| Mode | CWD | Sandbox env key | Notes |
|------|-----|-----------------|-------|
| **R** | each **target path** | `$CGO_SANDBOX` | RO tools + no web. **No parent `cd /tmp`.** |
| **W** | each **worktree** | `$CGO_SANDBOX_WRITE` | Prepare with `worktree-prepare.sh` first |

### Cross-tree R

Do not split into N wrapper calls when trees differ. One parent prompt may spawn subagents with **per-child `cwd`**. Wrapper still sets parent `--cwd` to a neutral anchor the operator chooses (not forced to `/tmp` by the product).

## Routing

Use fanout when **N≥3**, each item low-stakes, and parallel recon or disjoint writes help.  
High-quality reasoning, adversarial verify, and architecture judgment stay with the orchestrator (or grill/verify/judge modes).

## Cap

Optional weekly cap: `CGO_FANOUT_CAP` (default 20), counted from `$CGO_DATA/usage.log` rows with field2 `fanout`. Failed runs do not count.

## Fill-ins

| Placeholder | Meaning |
|-------------|---------|
| `{{TARGET_PATH}}` | Anchor cwd or primary tree |
| `{{PROMPT}}` | Operator-supplied parallel instruction |

## Prompt body (template; usually overridden by `--prompt` / wrapper arg)

```
Parallel fan-out task. Stay read-only unless the orchestrator labeled this write mode.

Anchor: {{TARGET_PATH}}

Follow the operator prompt for N parallel children. Prefer per-child cwd when trees differ.
Report structured findings per child. No auto-merge. No praise padding.
```

## Invoke

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" R /path/to/tree "<prompt>"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" W /path/to/worktree "<5-kan spec>"
# dry-run
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fanout_run.sh" --print-only R /path/to/tree "probe"
```

See `examples/fanout-jobs.example.yaml` for job shapes (operator-filled; not auto-run by product).
