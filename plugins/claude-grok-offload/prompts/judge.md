# judge — option / decision scoring (read-only)

> **Product role:** Independent option comparator and decision scorer.  
> Niche split: **grill** = find design defects · **judge** = rank options · **verify** = plan/code/fact checks.  
> **Enforcement tier:** documented maker≠checker. Not a host deny-gate.

## Fill-ins

| Placeholder | Meaning |
|-------------|---------|
| `{{TARGET_PATH}}` | Absolute path to option brief / decision note |
| `{{AXES}}` | Scoring axes (e.g. cost, reversibility, ops burden, recall rate). Free text. |
| `{{CONTEXT_PATHS}}` | Optional SSOT paths options depend on |

## Sandbox / invoke

- Invoke: `scripts/invoke-grok.sh --mode judge --input {{TARGET_PATH}} …`
- Sandbox: `$CGO_SANDBOX` + RO tools + `--disable-web-search`.
- Usage log: `$CGO_DATA/usage.log` with field2 = `judge`.
- **Large / hard-to-reverse decisions:** run the same command **3 independent times** (no shared session) and take majority ranking or mark low confidence on 3-way split. Daily small decisions = 1 run.

## Prompt body (injected into grok)

```
You did not create these options. Do not advocate for a side. Score each option on the stated axes.
Read-only — do not modify files or change system state.

Subject: {{TARGET_PATH}}
Scoring axes: {{AXES}}
Contrast sources (read if needed): {{CONTEXT_PATHS}}

Procedure:
1. Read the subject and any contrast sources that exist.
2. Score each option on every axis with evidence tied to sources (no score without evidence).
3. Explicit trade-offs: where A beats B and where A loses.
4. No praise, no false balance. If one axis clearly ranks options, say so.
5. **Spectrum check:** if options sit on one expansion-width scale (narrow → wide), also score "widest option that does not hit the four guards" even when that axis was not listed. Four guards: real money cost · irreversibility · security · global session impact. State which option is the widest still-clear of those guards.
6. **Outside the list:** if a better approach exists outside the given options, state it as a separate item. Ranking stays inside the list; out-of-list answers are not forced into the rank order.

Output format:
- Ranking (1 → N) of given options only
- Per option: axis scores + 1–2 line evidence
- Spectrum status: yes (and widest clear option) / not a spectrum
- Out-of-list alternative: content or "none"
- One recommendation + one counter-view (how the recommendation could be wrong)
Overall: recommended option in one line + confidence (high|medium|low; if low, one follow-up measurement)
```

## Operator notes

- If an out-of-list alternative dominates across runs, majority ranking over the original list is weak — rebuild the option set around the intersection of out-of-list proposals rather than re-running the same list.
- Judge logs must not be treated as design-grill evidence in any host gate you build yourself.
