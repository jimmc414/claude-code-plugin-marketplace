---
description: "For dynamic programming: overlapping subproblems, recursive solutions with repeated computations, memoization to avoid redundant work."
---

# cache-recursive-calls

## When to Use
- Recursive function computes same inputs multiple times
- Overlapping subproblems (DP)
- Fibonacci-like recurrence relations
- Tree/graph traversal with revisits
- Expensive pure functions called repeatedly

## When NOT to Use
- Function has side effects
- Inputs aren't hashable
- Cache would grow too large
- Each input computed only once

## The Pattern

Use `@functools.cache` (Python 3.9+) or `@functools.lru_cache(None)` to memoize.

```python
from functools import cache

@cache
def fib(n):
    """Fibonacci with memoization: O(n) instead of O(2^n)."""
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

# Or with size limit
from functools import lru_cache

@lru_cache(maxsize=1000)
def expensive_lookup(key):
    # ... expensive computation
    return result
```

## Example (from pytudes)

```python
from functools import cache

# TSP with dynamic programming (TSP.ipynb)
@cache
def shortest_segment(A, Bs, C):
    """Shortest path from A through all cities in Bs to C."""
    if not Bs:
        return [A, C]
    return min(
        (shortest_segment(A, Bs - {B}, B) + [C] for B in Bs),
        key=segment_length
    )

# Key insight: Bs must be frozenset (hashable)
cities = frozenset(['NYC', 'LA', 'CHI', 'HOU'])
tour = shortest_segment('START', cities, 'START')

# Expression counting (Countdown.ipynb)
@cache
def expressions(numbers):
    """All expressions makeable from numbers."""
    if len(numbers) == 1:
        return {numbers[0]: str(numbers[0])}

    table = {}
    for Lnums, Rnums in splits(numbers):
        for L, R in product(expressions(Lnums), expressions(Rnums)):
            for op in ops:
                # Combine L and R with op
                ...
    return table

# Word segmentation (ngrams.py)
@cache
def segment(text):
    """Best word segmentation of text."""
    if not text:
        return []
    candidates = ([first] + segment(rest)
                  for first, rest in splits(text))
    return max(candidates, key=word_probability)
```

## Key Principles
1. **Pure functions only**: Same input must give same output
2. **Hashable arguments**: Use tuples/frozensets, not lists/sets
3. **cache vs lru_cache**: `cache` is unbounded, `lru_cache` has size limit
4. **Inspect cache**: `func.cache_info()` shows hits/misses
5. **Clear when done**: `func.cache_clear()` frees memory
