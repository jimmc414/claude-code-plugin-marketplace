# structured-gist

Renders explanatory or process-recap output as a nested outline instead of a paragraph. A fixed four-role marker ladder (concept, attribute, enumerator, explanation) carries meaning by depth, so structure survives independent of how compressed the wording is.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install structured-gist@community-claude-plugins
```

## Usage

```bash
/structured-gist [skim|standard|deep] [block|responsive]
```

No level given defaults to `skim`. No mode given defaults by surface: `responsive` on any markdown-rendering surface (GitHub, chat apps), `block` on a plain terminal.

Trigger phrases: "structured-gist", "gist mode", "gist this", "outline this", "bullet this", "notes mode", "structure this", "break this down", "distill this", "give me the gist", "make this skimmable", "tighten this up", "condense this".

## The problem

A paragraph interleaves purpose, mechanism, and caveats in one prose block with no marker distinguishing them. The reader re-derives that structure by parsing sentence boundaries and connective words on every read.

## The ladder

- **concept** (`-`): the top-level claim or subject
- **attribute** (`▸`): a named property of its parent, "the parent has a ___"
- **enumerator** (`I.`/`A.` at depth 1, `i.`/`a.` deeper): ordered or grouped parts
- **explanation** (`↪`): one prose sentence, usually a leaf

Position carries the meaning, so individual node text can compress aggressively without losing the reader's ability to navigate the tree.

## Components

### Skills

- `structured-gist` — the outline-rendering skill, including a stdlib-only Python linter (15 rules) that checks conformance to the marker ladder and catches two common defects: a node long enough to be doing two jobs at once, and a fact spliced onto a node via punctuation instead of given its own child.

## Full documentation

The standalone repository has the complete specification, a before/after demonstration, and the render-mode detail: [domattioli/structured-gist](https://github.com/domattioli/structured-gist).

## License

MIT.
