---
description: "For counting and frequency: histograms, most common elements, vote tallying, neighbor counting, word frequencies, distribution analysis."
---

# use-counter-frequency

## When to Use
- Counting occurrences of items
- Finding most common elements
- Building histograms
- Vote/tally counting
- Word frequency analysis
- Neighbor counting in grids
- Any "how many of each" question

## When NOT to Use
- When you need the items themselves, not counts
- Single occurrence checking (use set)
- When counts need to be updated in complex ways

## The Pattern

Use `collections.Counter` - a dict subclass optimized for counting.

```python
from collections import Counter

# Count anything iterable
Counter('abracadabra')  # {'a': 5, 'b': 2, 'r': 2, 'c': 1, 'd': 1}
Counter([1, 1, 2, 3, 3, 3])  # {3: 3, 1: 2, 2: 1}

# Most common
counter.most_common(3)  # Top 3 as [(item, count), ...]

# Arithmetic
Counter('abc') + Counter('bcd')  # {'b': 2, 'c': 2, 'a': 1, 'd': 1}

# Total count
sum(counter.values())
```

## Example (from pytudes)

```python
from collections import Counter

# Word frequency from text (spell.py)
def words(text):
    return re.findall(r'\w+', text.lower())

WORDS = Counter(words(open('big.txt').read()))
# WORDS['the'] = 79809

def P(word, N=sum(WORDS.values())):
    """Probability of word."""
    return WORDS[word] / N

# Neighbor counting (Life.ipynb)
def neighbor_counts(world):
    """For each cell, count how many live neighbors it has."""
    return Counter(neighbor
                   for cell in world
                   for neighbor in neighbors(cell))

# Use for Game of Life rules
counts = neighbor_counts(world)
new_world = {cell for cell, count in counts.items()
             if count == 3 or (count == 2 and cell in world)}

# Probability distribution (Probability.ipynb)
class Dist(Counter):
    """A distribution of {outcome: frequency}."""
    pass

DK = Dist(GG=121801, GB=126840, BG=127123, BB=135138)
# Access: DK['GG'], DK.most_common(), sum(DK.values())
```

## Key Principles
1. **Counter is a dict**: All dict methods work
2. **Missing keys = 0**: No KeyError for missing items
3. **most_common(n)**: Get top n items efficiently
4. **Arithmetic works**: Add, subtract, intersect counters
5. **Generator input**: `Counter(x for x in iterable if condition)`
