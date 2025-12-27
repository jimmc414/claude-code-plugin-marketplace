---
name: show-side-by-side
description: "For comparison: display before/after, multiple solutions, diffs side by side for visual comparison."
---

# show-side-by-side

## When to Use
- Comparing before and after states
- Showing multiple solutions
- Visual diff for debugging
- Parallel algorithm outputs

## When NOT to Use
- Single output
- Very wide outputs
- Non-textual data

## The Pattern

Print two or more outputs in parallel columns.

```python
def side_by_side(left, right, width=40, labels=('Left', 'Right')):
    """Print two strings side by side."""
    left_lines = left.splitlines()
    right_lines = right.splitlines()

    # Header
    print(f"{labels[0]:<{width}} {labels[1]:<{width}}")
    print('-' * width + ' ' + '-' * width)

    # Content
    for l, r in zip_longest(left_lines, right_lines, fillvalue=''):
        print(f"{l:<{width}} {r:<{width}}")
```

## Example (from pytudes)

```python
# Sudoku.ipynb - puzzle vs solution
def print_side_by_side(left, right, width=20):
    """Print two strings side-by-side, line-by-line."""
    for L, R in zip(left.splitlines(), right.splitlines()):
        print(L.ljust(width), R.ljust(width))

# Usage
puzzle = '''
4 . . |. . . |8 . 5
. 3 . |. . . |. . .
. . . |7 . . |. . .
------+------+------
. 2 . |. . . |. 6 .
. . . |. 8 . |4 . .
. . . |. 1 . |. . .
------+------+------
. . . |6 . 3 |. 7 .
5 . . |2 . . |. . .
1 . 4 |. . . |. . .
'''

solution = '''
4 1 7 |3 6 9 |8 2 5
6 3 2 |1 5 8 |9 4 7
9 5 8 |7 2 4 |3 1 6
------+------+------
8 2 5 |4 3 7 |1 6 9
7 9 1 |5 8 6 |4 3 2
3 4 6 |9 1 2 |7 5 8
------+------+------
2 8 9 |6 4 3 |5 7 1
5 7 3 |2 9 1 |6 8 4
1 6 4 |8 7 5 |2 9 3
'''

print_side_by_side(puzzle, solution)

# Multiple comparison
def show_algorithms(puzzle, *algorithms):
    """Compare multiple algorithm results."""
    results = [algo(puzzle) for algo in algorithms]
    names = [algo.__name__ for algo in algorithms]

    # Print headers
    width = 25
    print(' '.join(name.center(width) for name in names))
    print(' '.join('-' * width for _ in names))

    # Print results line by line
    result_lines = [r.splitlines() for r in results]
    for lines in zip(*result_lines):
        print(' '.join(line.ljust(width) for line in lines))
```

## Key Principles
1. **Consistent width**: Fixed column widths
2. **Aligned rows**: zip_longest for unequal lengths
3. **Labels**: Headers identify what's being compared
4. **Separators**: Visual distinction
5. **ljust for padding**: Clean alignment
