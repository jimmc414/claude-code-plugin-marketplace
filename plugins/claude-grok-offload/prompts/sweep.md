# sweep — batch audit (candidate collection only)

> **Product role:** Periodic read-only audit across operator-listed git repos.  
> Collects **candidates**; merge/judgment stays with the orchestrator (maker≠checker).  
> Targets come from a **file**, not hardcoded host paths.

## Targets

1. CLI arg: path to a targets file **or** a single repo directory  
2. Else env `CGO_SWEEP_TARGETS`  
3. Else `$HOME/.config/claude-grok-offload/sweep-targets.txt`

Format: one absolute path per line (`#` comments allowed).  
Example: `examples/sweep-targets.example.txt`

Non-git paths are skipped (product does not ship host-specific non-repo recipes).

## Sandbox / invoke

- Wrapper: `scripts/sweep_run.sh`
- Sandbox: `$CGO_SANDBOX` from Ready state
- CWD: each target repo
- Output: `$CGO_DATA/sweep/<ISO-WEEK>-<name>.md`
- Cap: `CGO_SWEEP_CAP` (default 20) on `sweep`+`sweep-fail` rows in usage.log

## Audit axes

1. silent failure  
2. dead code (static)  
3. TODO/FIXME (location/text only)  
4. test gaps  
5. error path / logging defects  

## Prompt body (runner substitutes scope/file list)

```
You did not author this code. Collect defect candidates only.
Read-only — do not modify files or change system state.

{{SCOPE}}
Scan list (stay inside; prioritize entry points):
{{FILE_LIST}}

If CLAUDE.md or PRINCIPLES.md exists at CWD root, read first (house style).

Audit axes:
1. silent failure — empty catch, broad except, silent fallback, unlogged failure
2. dead code — static zero-ref import/function only
3. TODO/FIXME — location and text only (no age judgment)
4. test gaps — core paths without tests
5. error path / log defects — unactionable messages, ignored exit codes

Output:
## Scan scope
(files actually read; note misses vs injected list)
## Candidates
- [candidate] axisN — file:line — one-line summary
  evidence: quoted code
(No verdict, no fix proposals, no praise.)
```

## After sweep

Orchestrator dedupes candidates, spot-checks evidence, and chooses fix / impl ticket / discard.  
Product does not auto-patch.
