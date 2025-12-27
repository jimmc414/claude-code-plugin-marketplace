---
name: use-sparse-set
description: "For sparse data: infinite grids, large spaces with few active elements, membership testing, set operations on coordinates or states."
---

# use-sparse-set

## When to Use
- Infinite or very large coordinate spaces
- Only a few elements are "active" at any time
- Need O(1) membership testing
- Natural union/intersection operations apply
- Game of Life, sparse matrices, active cell tracking

## When NOT to Use
- Dense data where most cells have values
- Need array indexing or slicing
- Matrix operations (use numpy)

## The Pattern

Use Python sets to represent sparse collections. Only store elements that exist/matter.

```python
# Instead of 2D array:
# grid = [[0]*1000 for _ in range(1000)]  # Wastes memory

# Use set of coordinates:
active_cells = {(3, 5), (10, 20), (100, 200)}

# Operations are natural
(5, 5) in active_cells  # O(1) membership
active_cells.add((7, 7))  # O(1) add
active_cells |= other_set  # Union
active_cells &= valid_region  # Intersection
```

## Example (from pytudes Life.ipynb)

```python
Cell = Tuple[int, int]
World = Set[Cell]  # Only live cells stored

# Initial state - just the active cells
glider = {(1, 0), (2, 1), (0, 2), (1, 2), (2, 2)}

def neighbors(cell):
    """All 8 neighbors of a cell."""
    x, y = cell
    return [(x+dx, y+dy)
            for dx in [-1, 0, 1]
            for dy in [-1, 0, 1]
            if (dx, dy) != (0, 0)]

def neighbor_counts(world):
    """Count neighbors for all relevant cells."""
    from collections import Counter
    return Counter(n for cell in world for n in neighbors(cell))

def next_generation(world):
    """Game of Life: 3 neighbors = born, 2-3 = survive."""
    counts = neighbor_counts(world)
    return {cell for cell, count in counts.items()
            if count == 3 or (count == 2 and cell in world)}

# Can handle any size - sparse representation!
huge_world = {(1000000, 1000000), (1000001, 1000000)}
next_gen = next_generation(huge_world)  # Works fine
```

## Key Principles
1. **Only store what exists**: Empty cells don't consume memory
2. **Infinite space is free**: No bounds needed
3. **Set operations map to problems**: Union = combine, intersection = overlap
4. **Tuples are hashable**: Coordinates work as set elements
5. **Counter for aggregation**: Count "votes" from neighbors
