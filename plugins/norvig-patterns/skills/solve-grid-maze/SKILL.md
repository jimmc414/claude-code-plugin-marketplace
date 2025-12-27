---
name: solve-grid-maze
description: "For 2D grid problems: mazes, board games, tile maps, pixel grids, coordinate systems, cellular automata, flood fill. Uses dict-based Grid class pattern."
---

# solve-grid-maze

## When to Use
- Working with 2D coordinates (x, y) or (row, col)
- Board games (chess, checkers, Go, tic-tac-toe)
- Tile-based maps or level editors
- Cellular automata (Game of Life)
- Maze generation or solving
- Flood fill algorithms
- Any spatial grid structure

## When NOT to Use
- Dense matrices where every cell is used (use numpy arrays instead)
- 3D or higher-dimensional grids (extend the pattern carefully)
- When you need matrix operations (multiplication, transposition)

## The Pattern

Represent grids as `dict[(x, y) -> contents]` instead of 2D arrays.

```python
Cell = Tuple[int, int]
Grid = Dict[Cell, Any]

# Sparse representation - only store what matters
world = {(3, 1): '#', (1, 2): '.', (1, 3): '#'}

# Neighbors via direction vectors
directions4 = [(1, 0), (0, 1), (-1, 0), (0, -1)]  # E, S, W, N
directions8 = directions4 + [(1, 1), (1, -1), (-1, 1), (-1, -1)]

def neighbors(point, directions=directions4):
    x, y = point
    return [(x + dx, y + dy) for dx, dy in directions]

def add(p, q):
    return (p[0] + q[0], p[1] + q[1])
```

## Example (from pytudes Life.ipynb)

```python
from collections import Counter

Cell = Tuple[int, int]
World = Set[Cell]  # Only store live cells (sparse!)

def neighbor_counts(world: World) -> Dict[Cell, int]:
    """Count live neighbors for each cell."""
    return Counter(n for cell in world for n in neighbors(cell))

def next_generation(world: World) -> World:
    """Apply Game of Life rules."""
    counts = neighbor_counts(world)
    return {cell for cell, count in counts.items()
            if count == 3 or (count == 2 and cell in world)}
```

## Key Principles
1. **Sparse is elegant**: Only store occupied/interesting cells
2. **Direction vectors**: Define movement as tuples to add
3. **Set operations**: Union, intersection work naturally on cell sets
4. **Counter for neighbors**: Count "backwards" from cells to neighbors
5. **Immutable cells**: Tuples are hashable, can be dict keys or set members
