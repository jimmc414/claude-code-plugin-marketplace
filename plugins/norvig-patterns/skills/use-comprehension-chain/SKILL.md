---
name: use-comprehension-chain
description: "For data transformation: list/dict/set comprehensions, chained filtering and mapping, creating lookup structures concisely."
---

# use-comprehension-chain

## When to Use
- Transforming sequences (map)
- Filtering sequences
- Building dicts or sets from data
- Combining filter + map
- Creating lookup tables

## When NOT to Use
- Complex logic that needs multiple statements
- Side effects needed during iteration
- Code would be unreadable as one-liner

## The Pattern

Use comprehensions for concise, readable data transformation.

```python
# List comprehension: map + filter
squares = [x**2 for x in range(10)]
evens = [x for x in numbers if x % 2 == 0]
even_squares = [x**2 for x in numbers if x % 2 == 0]

# Dict comprehension: build lookup tables
word_lengths = {word: len(word) for word in words}
index = {item: i for i, item in enumerate(items)}
inverted = {v: k for k, v in original.items()}

# Set comprehension: unique values
unique_lengths = {len(word) for word in words}

# Nested comprehension: flatten or cross product
flat = [x for row in matrix for x in row]
pairs = [(x, y) for x in xs for y in ys]

# Conditional expression in comprehension
signs = ['pos' if x > 0 else 'neg' if x < 0 else 'zero' for x in numbers]
```

## Example (from pytudes)

```python
# Sudoku: precompute structure (sudoku.py)
def cross(A, B):
    return [a + b for a in A for b in B]

squares = cross('ABCDEFGHI', '123456789')  # 81 squares

unitlist = (
    [cross(r, '123456789') for r in 'ABCDEFGHI'] +  # Rows
    [cross('ABCDEFGHI', c) for c in '123456789'] +  # Cols
    [cross(rs, cs) for rs in ['ABC','DEF','GHI']    # Boxes
                   for cs in ['123','456','789']]
)

# Unit lookup
units = {s: [u for u in unitlist if s in u] for s in squares}

# Peer lookup
peers = {s: set(sum(units[s], [])) - {s} for s in squares}

# Word prefixes (Boggle.ipynb)
prefixes = {word[:i] for word in words for i in range(1, len(word))}

# Edits (spell.py)
splits = [(word[:i], word[i:]) for i in range(len(word) + 1)]
deletes = [L + R[1:] for L, R in splits if R]
transposes = [L + R[1] + R[0] + R[2:] for L, R in splits if len(R) > 1]
```

## Key Principles
1. **One line, one transformation**: Keep it readable
2. **Left to right**: `[expr for var in seq if cond]`
3. **Nested = flatten**: Inner loop varies fastest
4. **Dict for lookups**: O(1) access pattern
5. **Set for uniqueness**: Auto-deduplicate
