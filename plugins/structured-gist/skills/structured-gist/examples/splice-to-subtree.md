# splice-to-subtree — the golden before/after A node that joins ≥2 independent facts with a semicolon, colon, or a *chained*
mid-line `→` is N nodes wearing one marker. R9 flags it (any structural node
whose tail after a delimiter runs >2 words). The fix: split the packed node into
a subtree — each fact becomes its own child, and each keeps at most ONE `X → Y`
single-arrow idiom (the caveman causality glyph R9 deliberately preserves). ## Case 1 — chained arrow + semicolon splice BEFORE (flags R9 — the tail after the first `→` runs 9 words, three facts): ```
- Sync outcome ▸ Branches a. pin drift → refreshed; concurrent session raced it → redundant commit dropped
``` AFTER (clean — one fact per child, each with a single arrow): ```
- Sync outcome ▸ Pin a. pin drift → refreshed b. raced session → redundant commit
``` ## Case 2 — colon + parenthetical smuggling BEFORE (flags R9 — colon tail >2 words, and a >2-word parenthetical): ```
- Bench result ▸ Solver a. FAILED, measured: supplement 0.61× (55.0s vs 33.5s baseline; gate ≥2×)
``` AFTER (clean — verdict and measurements separated into named children): ```
- Bench result ▸ Verdict ↪ FAILED — supplement solver slower than the parity gate ▸ Measured a. supplement 0.61× b. 55.0s vs 33.5s baseline c. gate ≥2×
```
