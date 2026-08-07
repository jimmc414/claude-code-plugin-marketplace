# heavy-burn — meaningful volume playbook (Build / CLI)

> **Product role:** Operator checklist to spend SuperGrok / Grok CLI capacity on **useful Build work**, not chat noise.  
> **Not a quota guarantee.** SuperGrok UI usage and CLI headless spend are a **shared commercial pool**, not a product-promised parity or fixed weekly allotment. Treat Settings → Usage as the absolute meter; this playbook only ranks *what* to run.

## Principles

1. Prefer **volume that leaves artifacts**: impl · fanout-W · verify-code · sweep candidates · TUI grunt in a project cwd.  
2. Prefer **not** burning pool on: open-ended chat, image/voice toys, or extra grill rounds when volume is already starved.  
3. **Grill-heavy logs can be healthy quality** and still be a bad spend mix — do not add grill to “burn remaining.”  
4. Missing write sandbox (`CGO_SANDBOX_WRITE`) blocks impl/fanout-W until install + check succeed — fix Ready state first.

## Priority table (Build only)

| Rank | Action | Product surface | Log field2 |
|------|--------|-----------------|------------|
| P0 | Approved long implementation (5-kan + worktree/staging) | `/claude-grok-offload:impl` · `invoke --mode impl` | `impl` |
| P0 | Bounded pre-commit code check | `verify` kind `code` | `verify-code` |
| P1 | N≥3 read-only parallel recon | `fanout_run.sh R` | `fanout` |
| P1 | Small/exploratory loops (spec cost ≥ direct impl cost) | Interactive `grok` in project cwd (TUI) | optional local note |
| P1 | Multi-option decision | `judge` | `judge` |
| P2 | Weekly batch audit if not done | `sweep_run.sh` | `sweep` |
| Avoid | Voice / Imagine / idle chat for burn | — | — |
| Avoid | Expecting IDE plan modes to drain the same pool | — | — |

## Weekly rhythm (operator)

1. Run check: `scripts/cgo-check.sh` → `Ready: yes`.  
2. Glance SuperGrok **Settings → Usage** (Build share). No product script can read that UI.  
3. If you have **approved long impl** work: dispatch **impl** (or fanout-W), not more grill.  
4. If you only have authority-axis work (rules/hooks/settings): **impl zero is normal** — do not invent volume.  
5. If code changed this week and verify-code is empty: one `verify --verify-kind code` on a hot file.  
6. If no sweep output this ISO week and you maintain several repos: run sweep with your targets file.

## Cap honesty

- Product caps (`CGO_FANOUT_CAP`, `CGO_SWEEP_CAP`) are **local documented-tier** rate limits on log rows — not xAI entitlements.  
- Exhausting a local cap ≠ “Heavy used up.”  
- Exhausting SuperGrok Usage ≠ “CLI still free.” Plan work assuming they share a pool.

## Prompt body (session reminder; short)

```
Operator heavy-burn reminder:
1) Prefer impl / fanout-W / verify-code / sweep over extra grill.
2) SuperGrok shared pool ≠ guaranteed CLI quota — check Settings Usage.
3) Require Ready state and $CGO_SANDBOX_WRITE before write modes.
4) Do not invent volume when only authority-axis work remains.
```

## Related product surfaces

- `prompts/impl.md` · `fanout.md` · `sweep.md` · `verify.md` · `grill.md` · `judge.md`  
- Reverse maker≠checker when Grok orchestrates: `docs/REVERSE.md`
