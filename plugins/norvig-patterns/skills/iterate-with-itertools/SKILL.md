---
description: "For combinatorial iteration: permutations, combinations, cartesian products, without storing all results in memory."
---

# iterate-with-itertools

## When to Use
- Need all permutations of a sequence
- Need all combinations of k items
- Need cartesian product of multiple sequences
- Chaining multiple iterables
- Grouping consecutive elements

## When NOT to Use
- Simple loop is clearer
- Only need a few specific elements
- Need random access to results

## The Pattern

Use `itertools` for memory-efficient iteration over combinatorial structures.

```python
from itertools import permutations, combinations, product, chain

# Permutations: all orderings
list(permutations('ABC'))
# [('A','B','C'), ('A','C','B'), ('B','A','C'), ...]

# Combinations: all subsets of size k
list(combinations('ABCD', 2))
# [('A','B'), ('A','C'), ('A','D'), ('B','C'), ('B','D'), ('C','D')]

# Product: cartesian product
list(product('AB', '12'))
# [('A','1'), ('A','2'), ('B','1'), ('B','2')]

# Chain: concatenate iterables
list(chain([1,2], [3,4], [5]))
# [1, 2, 3, 4, 5]

# All are lazy - generate on demand
for perm in permutations(range(10)):  # 3.6M permutations
    if is_valid(perm):
        break  # Stop early, don't generate rest
```

## Example (from pytudes)

```python
from itertools import permutations, combinations, product

# TSP: try all tours (TSP.ipynb)
def brute_force_tsp(cities):
    start, *rest = cities
    return min(
        ([start] + list(perm) for perm in permutations(rest)),
        key=tour_length
    )

# Card hands (Probability.ipynb)
deck = [r + s for r in 'A23456789TJQK' for s in 'SHDC']
hands = combinations(deck, 5)  # 2.6M hands, lazy

# Dice rolls (Probability.ipynb)
def roll(n, sides=6):
    """Distribution of sums from rolling n dice."""
    from collections import Counter
    die = range(1, sides + 1)
    return Counter(sum(roll) for roll in product(die, repeat=n))

# Expression building (Countdown.ipynb)
for L, R in product(left_expressions, right_expressions):
    for op in ['+', '-', '*', '/']:
        combine(L, op, R)

# Splits of a sequence
def splits(sequence):
    """All ways to split sequence into two non-empty parts."""
    return ((sequence[:i], sequence[i:])
            for i in range(1, len(sequence)))
```

## Key Principles
1. **Lazy by default**: itertools returns iterators, not lists
2. **product with repeat**: `product(range(6), repeat=3)` for 3 dice
3. **combinations_with_replacement**: Allow same item multiple times
4. **chain.from_iterable**: Flatten nested iterables
5. **islice for limits**: `islice(permutations(...), 100)` for first 100
