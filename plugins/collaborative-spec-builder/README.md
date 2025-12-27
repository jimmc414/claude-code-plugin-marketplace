# collaborative-spec-builder

Collaborative specification building with iterative Q&A before implementation. Define unambiguous specifications through structured questioning, then either implement from scratch or analyze existing code against the spec.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install collaborative-spec-builder@community-claude-plugins
```

## Commands

### `/collaborative-spec-builder <task description>`

Start a collaborative specification building session for **new implementations**. Claude will:

1. Ask iterative clarifying questions across specification areas (intent, contracts, error cases, etc.)
2. Write a complete `SPECIFICATION.md` document
3. Enter plan mode to design an implementation that satisfies the spec

### `/collaborative-spec-builder-existing <feature or component>`

Build an **aspirational specification** for existing code and identify gaps. Claude will:

1. Ask questions about what the code SHOULD do (aspirational behavior)
2. Write a specification document as the target state
3. Analyze current implementation against the spec
4. Identify conforming areas, gaps, and unknowns
5. Create prioritized tasks to close the gaps

## Specification Areas Covered

- Intent and scope
- Domain types and vocabulary
- Input/output contracts
- Pre/postconditions and invariants
- Constraints and state transitions
- Side effects and error cases
- Boundary conditions and assumptions
- Dependencies, NFRs, security, concurrency (when relevant)
- Examples and acceptance criteria

## License

MIT
