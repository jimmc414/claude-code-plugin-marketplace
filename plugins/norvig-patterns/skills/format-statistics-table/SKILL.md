---
description: "For result reporting: tabular output, aligned columns, statistics summaries, human-readable reports."
---

# format-statistics-table

## When to Use
- Reporting test results
- Showing statistics
- Comparing alternatives
- Human inspection of data

## When NOT to Use
- Machine-parseable output (use JSON/CSV)
- Simple single values
- Too many columns

## The Pattern

Format data as aligned columns with headers and separators.

```python
def print_table(headers, rows, widths=None):
    """Print formatted table."""
    if widths is None:
        widths = [max(len(str(row[i])) for row in [headers] + rows)
                  for i in range(len(headers))]

    # Header
    print(' | '.join(h.ljust(w) for h, w in zip(headers, widths)))
    print('-+-'.join('-' * w for w in widths))

    # Rows
    for row in rows:
        print(' | '.join(str(v).ljust(w) for v, w in zip(row, widths)))
```

## Example (from pytudes)

```python
# SET.py - game statistics
def show(tallies, label):
    """Print out the counts."""
    print()
    print('Size |  Sets  | NoSets | Set:NoSet ratio for', label)
    print('-----+--------+--------+----------------')
    for size in sorted(tallies):
        y, n = tallies[size][True], tallies[size][False]
        ratio = ('inft' if n == 0 else int(round(float(y) / n)))
        print('{:4d} |{:7,d} |{:7,d} | {:4}:1'
              .format(size, y, n, ratio))

# Output:
# Size |  Sets  | NoSets | Set:NoSet ratio for random
# -----+--------+--------+----------------
#    3 |    100 |      0 | inft:1
#    4 |    200 |     50 |    4:1
#    5 |    400 |    100 |    4:1

# sudoku.py - solve statistics
def solve_all(grids, name=''):
    """Report solution statistics."""
    times, results = zip(*[time_solve(grid) for grid in grids])
    N = len(results)
    if N > 1:
        print("Solved %d of %d %s puzzles "
              "(avg %.2f secs (%d Hz), max %.2f secs)." % (
            sum(results), N, name,
            sum(times)/N, N/sum(times), max(times)))

# Output:
# Solved 50 of 50 easy puzzles (avg 0.01 secs (100 Hz), max 0.03 secs).

# spell.py - accuracy reporting
print('{:.0%} of {} correct ({:.0%} unknown) at {:.0f} words per second'
      .format(good/n, n, unknown/n, n/dt))

# Output:
# 74% of 270 correct (6% unknown) at 41 words per second
```

## Key Principles
1. **Align columns**: Consistent widths
2. **Format numbers**: Commas, percentages, decimals
3. **Headers and separators**: Visual structure
4. **Edge cases**: Handle zero, infinity
5. **Named columns**: Clear what each represents
