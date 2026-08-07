# verify — plan / code / fact check (read-only)

> **Product role:** Low-cost independent verification outside design-grill.  
> Modes: `plan` · `code` · `fact`.  
> **Enforcement tier:** documented maker≠checker (procedure + RO defaults).  
> Host tollgates that deny code entry without verify evidence are **not** part of this product.

## Fill-ins

| Placeholder | Meaning |
|-------------|---------|
| `{{TARGET_PATH}}` | Absolute path to plan markdown, code file/diff, or research output |
| `{{MODE}}` | `plan` \| `code` \| `fact` (log tag becomes `verify-plan` / `verify-code` / `verify-fact`) |
| `{{CONTEXT_PATHS}}` | Contrast sources: design doc for plans, neighboring modules for code, cited primary sources for fact |

## Sandbox / invoke

- Invoke: `scripts/invoke-grok.sh --mode verify --verify-kind {{MODE}} --input {{TARGET_PATH}} …`
- Sandbox: `$CGO_SANDBOX` from Ready state (`cgo_ro` or `strict`+staging).
- Default: RO tools + `--disable-web-search`.
- **fact** mode may omit `--disable-web-search` and allow web tools when external primary sources must be checked (invoke does this when `--verify-kind fact`).
- **Untrusted code** (`code` mode on a third-party / first-seen tree): prefer `strict` with CWD = that tree so host home grants are not in scope. Product still uses env keys — do not hardcode profile names beyond documenting the strict+CWD pattern.
- Usage log: `$CGO_DATA/usage.log` with field2 = `verify-{{MODE}}`.

## Prompt body (injected into grok)

```
You did not author this artifact. Assume defects and verify it.
Read-only — do not modify files or change system state.

Target: {{TARGET_PATH}} · mode: {{MODE}}
Contrast sources: {{CONTEXT_PATHS}}

Mode axes:
- plan: task boundaries · interface fit (prior task outputs vs later task consumers) · placeholders (TBD, "as appropriate", vague verbs) · missing spec coverage
- code: logic defects · edge cases · silent failure (empty catch, overly broad except) · style violations vs neighbors · changes outside the requested scope
- fact: claim vs cited primary text · numbers without denominator/period · unsourced assertions · misattribution

Per finding: [fatal|important|note] axis — one line + evidence (path:quoted content). No praise. Only grounded findings.
Overall verdict: PASS / REVISE
```

## Operator notes

- Grill evidence and verify evidence are separate log tags — do not treat verify as a design-grill substitute.
- Prefer running verify after a real edit batch (code) or after plan solidifies (plan); one-liners and docs-only diffs may skip.
- Append usage rows only after a real verify run completes (do not pollute denominators with dry tags).
