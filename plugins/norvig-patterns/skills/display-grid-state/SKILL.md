---
description: "For 2D debugging: visualize grid/board state, show puzzle progress, make algorithm behavior visible."
---

# display-grid-state

## When to Use
- Debugging grid algorithms
- Showing puzzle state
- Visualizing search progress
- Making algorithm transparent

## When NOT to Use
- Non-visual data
- Grids too large to display
- Performance-critical code

## The Pattern

Create a formatted text representation of grid state.

```python
def display_grid(grid, width, height):
    """Print grid as 2D representation."""
    for y in range(height):
        row = ''.join(grid.get((x, y), '.') for x in range(width))
        print(row)
    print()
```

## Example (from pytudes)

```python
# sudoku.py - display with separators
def display(values):
    """Display values as a 2-D grid."""
    width = 1 + max(len(values[s]) for s in squares)
    line = '+'.join(['-' * (width * 3)] * 3)

    for r in rows:
        print(''.join(
            values[r + c].center(width) + ('|' if c in '36' else '')
            for c in cols
        ))
        if r in 'CF':
            print(line)
    print()

# Output:
# 4 8 3 |9 2 1 |6 5 7
# 9 6 7 |3 4 5 |8 2 1
# 2 5 1 |8 7 6 |4 9 3
# ------+------+------
# 5 4 8 |1 3 2 |9 7 6
# ...

# Side by side comparison (Sudoku.ipynb)
def print_side_by_side(left, right, width=20):
    """Print two strings side-by-side, line-by-line."""
    for L, R in zip(left.splitlines(), right.splitlines()):
        print(L.ljust(width), R.ljust(width))

# Grid class with print method (AdventUtils.ipynb)
class Grid(dict):
    def print(self, sep='', xrange=None, yrange=None):
        """Print a representation of the grid."""
        for row in self.to_rows(xrange, yrange):
            print(*row, sep=sep)

    def to_rows(self, xrange=None, yrange=None):
        """Contents as rectangular list of lists."""
        xrange = xrange or cover(Xs(self))
        yrange = yrange or cover(Ys(self))
        default = ' ' if self.default in (KeyError, None) else self.default
        return [[self.get((x, y), default) for x in xrange]
                for y in yrange]
```

## Key Principles
1. **Human readable**: Space/align for clarity
2. **Show boundaries**: Separators for structure
3. **Default for missing**: Empty cells have representation
4. **Configurable size**: Let caller specify range
5. **Print vs return**: Option to get string or print directly
