# grill — adversarial design review (read-only)

> **Product role:** Independent checker for a design the caller did not write.  
> **Enforcement tier:** **documented** maker≠checker — procedure + RO sandbox defaults.  
> This product does **not** ship a host deny-gate that blocks code entry without grill evidence.  
> Operators who want hard gates wire that in their own harness.

## Fill-ins

| Placeholder | Meaning |
|-------------|---------|
| `{{DESIGN_PATH}}` | Absolute path to the design doc under review |
| `{{SSOT_PATHS}}` | Absolute paths to source-of-truth files the design claims to describe (comma- or newline-separated). Architecture designs may list related local docs. Empty if unknown. |
| `{{PRINCIPLES_PATHS}}` | Optional paths to project principles / engineering-constraint docs for axis 5. Empty if none. |

## Sandbox / invoke

- Invoke via `scripts/invoke-grok.sh --mode grill` (loads this contract, substitutes paths).
- Sandbox comes from Ready state: `$CGO_SANDBOX` (`cgo_ro` preferred, else `strict` + staging). Never hardcode profile names in callers.
- RO tools allowlist + `--disable-web-search` by default.
- No-arg grill stages `fixtures/first-run-design.md`.
- Usage log (optional): `$CGO_DATA/usage.log` (plugin data dir).

## Prompt body (injected into grok)

```
You did not author this design. Assume defects and adversarially verify it.
Read-only — do not modify files or change system state. Report findings and stop.

Target design: {{DESIGN_PATH}}
Source-of-truth files (read and contrast; architecture designs may also read closely related local docs listed here): {{SSOT_PATHS}}
Optional principles / constraint docs (axis 5; skip axis 5 detail if empty): {{PRINCIPLES_PATHS}}

Procedure:
1. Read the design and every path in SSOT_PATHS that exists. Line-by-line, compare the design's "current state" claims and any "missing / absent / incomplete" assertions against those sources. Flag uncited claims and claims that contradict the sources.
2. If PRINCIPLES_PATHS is non-empty, read those files for axis 5. If a listed principles path fails to read, report `[important] principles alignment — source read failed; axis 5 incomplete` and treat overall verdict as REVISE. Do not invent principles from memory.
3. Score on five axes:
   - Fact contrast: do design claims match the source files?
   - Side-effect coverage: does the design address adjacent systems, links, and external contracts (CLI/API) this change could break? Treat external contracts skeptically — prefer live evidence over design assumptions.
   - Disposition gaps: for rejected or deferred alternatives, are reason and promotion trigger present?
   - Logical consistency: do the design's own justifications contradict each other? Cross-check claim against claim, not only claim against source.
   - Principles / constraints alignment: does a decision conflict with PRINCIPLES_PATHS when provided?
     · Report a hit only with both: (a) quote from the design decision and (b) quote from the principles/constraints text (section numbers alone are not enough).
     · Constraint violations → [fatal] or [important]; softer principle misalignment → [important] or [note].
     · Zero hits on this axis is normal when nothing conflicts or when PRINCIPLES_PATHS is empty.
4. Per finding: [fatal] must block implementation entry / [important] must be addressed / [note] improvement opportunity.
5. No praise or soft padding. Only findings you can ground in files you read.

Output format (finding list):
- [severity] axis — one-line summary
  evidence: source path:quoted content + design claim
- If axis 5 has no findings and PRINCIPLES_PATHS was provided: end list with `principles alignment: none`
Overall verdict: PASS (zero fatal and zero important) / REVISE (any fatal or important)
```

## Operator notes

- **Rounds:** Log tag is the literal mode `grill` (no `grill-rN` suffixes). Multiple rounds = multiple log rows with the same three fields.
- **Effort:** Prefer high for grill quality.
- **Skip:** Host-specific auto-run / deny-until-grill policies are out of product scope; document only if your harness adds them.
