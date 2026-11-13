# nested-notes — self-explain example Before (paragraph, 69 words): nested-notes replaces a paragraph with a depth-coded outline — a concept, its attributes (properties of the concept, marked `▸`), then ordered or grouped enumerators, then a hook-arrow leaf carrying the one long sentence. A marker never nests under the same marker; to go deeper a hook interposes. Terse at every rung, four spaces each. Its own properties — marker ladder, length gradient, spacing — are attributes of nested-notes, unfolded at skim, standard, deep below. skim (concept + its attributes): ```text
- nested-notes ▸ Marker ladder ▸ Length gradient ▸ Spacing
``` standard (attributes carry their enumerated content): ```text
- nested-notes ▸ Marker ladder a. roman for order b. letter for groups ↪ never mix roman and letter as siblings ▸ Length gradient a. enumerator stays terse b. connective clause to a leaf ↪ because/since inside a node means split it ▸ Spacing a. four spaces per rung b. blank line between siblings
``` deep (a non-leaf `↪` previews a branch; the hook interposes so detail nests without ▸ under ▸): ```text
- nested-notes ▸ Marker ladder ↪ marker family by depth carries the meaning a. roman: order matters b. letter: grouped peers ▸ Length gradient a. enumerator stays terse b. connective clause moves to a leaf ↪ "because," "since," "so that" inside a node means split it ▸ Spacing a. four spaces per rung b. blank line between siblings ↪ inline only; literal markers aren't real GFM list items
``` Here `Marker ladder`, `Length gradient`, `Spacing` are attributes *of* nested-notes (`▸`), not peer concepts — the fix. In deep, `▸ Marker ladder`'s first child is a non-leaf `↪` summarizing the branch before its `a.`/`b.` detail, and that hook is also what lets the detail nest without a `▸` directly under a `▸`. Before → after (framing paragraph vs. skim block's spine, arrows excluded), measured not asserted: ```text
$ wc -w <<< "$before"
69
$ wc -w <<< "$after"
6
``` -91%: naming the concept's attributes replaces the paragraph's connective prose. Rule index for properties not self-demonstrated above, and the
consolidation call vs. `skim.md`/`standard.md`/`deep.md`/`caveman-combo.md`:
`reference/self-explain-notes.md`.
