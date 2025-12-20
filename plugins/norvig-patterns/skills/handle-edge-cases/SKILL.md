---
description: "For boundary conditions: empty collections, zero values, recursive base cases, null checks, prevent crashes at edges."
---

# handle-edge-cases

## When to Use
- Loop boundaries
- Empty collections
- Recursive base cases
- Division or modulo operations
- Array/string indexing

## When NOT to Use
- Already validated at boundary
- Edge case can't happen
- Over-defensive code

## The Pattern

Explicitly check boundary conditions before operations.

```python
def process(items):
    # Handle empty
    if not items:
        return default_value

    # Handle single element
    if len(items) == 1:
        return items[0]

    # Now safe to assume len >= 2
    return combine(items[0], process(items[1:]))

def divide(a, b):
    if b == 0:
        return None  # or raise, or return infinity
    return a / b
```

## Example (from pytudes)

```python
# Sudoku constraint propagation (sudoku.py)
def eliminate(values, s, d):
    """Eliminate d from values[s]; propagate."""
    if d not in values[s]:
        return values  # Already eliminated - edge case

    values[s] = values[s].replace(d, '')

    # Edge case: no values left
    if len(values[s]) == 0:
        return False  # Contradiction

    # Edge case: exactly one value left
    if len(values[s]) == 1:
        d2 = values[s]
        if not all(eliminate(values, s2, d2) for s2 in peers[s]):
            return False

    # Edge case: only one place for d in unit
    for u in units[s]:
        dplaces = [s for s in u if d in values[s]]
        if len(dplaces) == 0:
            return False  # No place for this value
        if len(dplaces) == 1:
            if not assign(values, dplaces[0], d):
                return False

    return values

# SET.py - zero division guard
def show(tallies, label):
    for size in sorted(tallies):
        y, n = tallies[size][True], tallies[size][False]
        ratio = ('inft' if n == 0 else int(round(float(y)/n)))
        print(f'{size:4d} |{y:7,d} |{n:7,d} | {ratio:4}:1')

# spell.py - word not found case
def candidates(word):
    """Generate possible spelling corrections for word."""
    return (known([word]) or          # Word itself if known
            known(edits1(word)) or    # 1 edit away
            known(edits2(word)) or    # 2 edits away
            [word])                   # Fallback: return original
```

## Key Principles
1. **Check before access**: Empty list before `list[0]`
2. **Return early**: Handle edge cases first, then main logic
3. **Zero checks**: Before division, modulo
4. **Fallback values**: `or default` pattern
5. **Explicit is clear**: `if not items:` shows intent
