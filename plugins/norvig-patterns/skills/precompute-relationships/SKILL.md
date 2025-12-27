---
name: precompute-relationships
description: "For static relationships: graph structure, grid neighbors, constraint peers. Calculate once at module load, reference throughout program."
---

# precompute-relationships

## When to Use
- Problem has fixed structure (grid, graph, hierarchy)
- Same relationships queried repeatedly
- Relationships can be computed from problem definition
- Constraint problems with peers/neighbors
- Any "what affects what" mapping

## When NOT to Use
- Relationships change during execution
- Structure is too large to precompute
- Only needed once

## The Pattern

Compute all static relationships at module load time. Store in dicts for O(1) lookup.

```python
# Define structure
rows = 'ABCDEFGHI'
cols = '123456789'

# Precompute all squares
squares = [r + c for r in rows for c in cols]

# Precompute all units (rows, cols, boxes)
unit_list = (
    [[r + c for c in cols] for r in rows] +  # Rows
    [[r + c for r in rows] for c in cols] +  # Columns
    [[r + c for r in rs for c in cs]         # Boxes
     for rs in ['ABC', 'DEF', 'GHI']
     for cs in ['123', '456', '789']]
)

# Precompute which units each square belongs to
units = {s: [u for u in unit_list if s in u] for s in squares}

# Precompute peers (squares that constrain this one)
peers = {s: set(sum(units[s], [])) - {s} for s in squares}
```

## Example (from pytudes Sudoku.ipynb)

```python
def cross(A, B):
    """Cross product of elements in A and B."""
    return [a + b for a in A for b in B]

digits = '123456789'
rows = 'ABCDEFGHI'
cols = digits

# All 81 squares
squares = cross(rows, cols)

# All 27 units
unitlist = ([cross(rows, c) for c in cols] +
            [cross(r, cols) for r in rows] +
            [cross(rs, cs)
             for rs in ('ABC', 'DEF', 'GHI')
             for cs in ('123', '456', '789')])

# units[s] = list of 3 units containing square s
units = {s: [u for u in unitlist if s in u]
         for s in squares}

# peers[s] = set of 20 squares that see square s
peers = {s: set(sum(units[s], [])) - {s}
         for s in squares}

# Now constraint propagation is fast:
def eliminate(values, s, d):
    for peer in peers[s]:  # O(1) lookup!
        eliminate(values, peer, d)
```

## Key Principles
1. **Compute once at load**: Module-level, not function-level
2. **Dict for O(1) lookup**: `units[square]` not `find_units(square)`
3. **Derive from structure**: Units derive from grid definition
4. **Transitive closure**: Peers = union of all units minus self
5. **Test the precomputation**: Verify expected sizes and relationships
