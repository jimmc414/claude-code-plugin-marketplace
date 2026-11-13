# Example — `nested-notes` attribute marker `▸` (v0.3) Source: "Describe the fort.14 mesh file." The properties *of* the file are `▸`
attributes; its ordered record blocks are enumerators; prose rides `↪`. Shows
the distinction — "a fort.14 *has a* header" (attribute) vs. "the body is
*composed of* these ordered blocks" (enumerator) — and the no-self-nest escape
hatch (a `↪` interposes so a property can carry deeper properties without
`▸`→`▸`). ```
- fort.14 ▸ Purpose ↪ the ADCIRC unstructured-mesh exchange format, one grid per file ▸ Encoding a. plain text b. one-based node ids ▸ Body i. header line ii. node table iii. element table iv. boundary segments ↪ open then land, each a counted run of node ids
- Why attributes here ▸ faithful ↪ "Encoding" is a property of the format, not a peer concept or a step ▸ scannable ↪ a reader sees the format's properties without reading each part below
``` `Purpose`, `Encoding`, `Body` are attributes *of* fort.14 (`▸`); `Body`'s
children are genuinely ordered record blocks, so they enumerate (lowercase
`i.`–`iv.`, because the `▸` already occupies the first rung). No `▸` sits
directly under a `▸` — where a property needs its own detail, the `↪` carries
it.
