# self-explain.md — rule index + consolidation notes Pointer target from `examples/self-explain.md`. This is context *about* the
example, not the example itself — it doesn't belong in `examples/` (an
example should be the demonstration, not an essay about the demonstration),
so it lives here per the progressive-disclosure pattern the rest of this
skill's `reference/` already uses. ## Rule index `examples/self-explain.md` renders nested-notes describing its own marker
mechanics, so its skim/standard/deep blocks naturally demonstrate: the
depth-ladder (dash → ordinal/nominal → deeper ordinal/nominal), the
ordinal-vs-nominal choice, the hook-arrow `↪` leaf (single-depth and
multi-depth), length gradient (terser at shallow depth), nest-by-dependency,
and the granularity ladder itself (skim < standard ≤ deep, same content). A few rules describe properties of the skill as a whole rather than
something a self-referential outline about its own marker mechanics would
naturally trigger. Named here instead of forced into the outline: - **render modes** (`## Render modes`) — `block` = one fenced code block (chat/terminal); `inline` = raw markdown lines (GitHub), needs a blank line between siblings since the literal glyphs aren't real GFM list items.
- **emphasis taxonomy** (`## Emphasis taxonomy`) — `inline` mode only: bold L1 concepts, `code`/*italic*/~~strike~~ sparingly deeper, `<u>` for definition anchors.
- **carve-outs** (`## Carve-outs`) — security/irreversible warnings, single-fact replies, code/commits/template fields, explicit prose requests all skip outlining.
- **caveman coexistence** (`## Caveman coexistence`) — wording compresses per whatever caveman level is active; the `↪` leaf is exempt regardless; markers stay Latin even under `wenyan-*`.
- **install** (`## Install`) — DomI marketplace skill, pulled via `skills.manifest.json` / the sync contract; never vendored. GitHub-authoring (which surfaces render as `inline` outlines, which
template/footer scaffolding stays verbatim) is intentionally **absent**
from this index as of v0.2.11/ — it was never a rule of this skill. It
was DomI comment-discipline policy defined in terms of ``'s
own template grammar, wearing a nested-notes section; it now lives at
, owned by the skill
that actually defines the templates. ## Consolidation `examples/self-explain.md` proves the granularity ladder and most rules on
its OWN self-description. `examples/{skim,standard,deep}.md` and
`examples/caveman-combo.md` are unaffected and still required: they're the
pytest-linted fixtures (`tests/test_lint.py`) proving the same
properties — granularity monotonicity, caveman-wording independence — on a
different topic (the `load_local_skills` hook). Deleting them would break 4
pytest cases and the smoke suite's monotonicity check for no benefit; they
stay as-is.
