---
name: use-defaultdict-groups
description: "For grouping and auto-initialization: adjacency lists, grouping by key, multi-maps, nested structures without KeyError handling."
---

# use-defaultdict-groups

## When to Use
- Building adjacency lists for graphs
- Grouping items by some key
- Multi-maps (key -> list of values)
- Nested dict structures
- Avoiding `if key not in dict` checks
- Counting (though Counter is often better)

## When NOT to Use
- Simple key-value mapping (use regular dict)
- When missing key should raise error
- When default value is complex/expensive

## The Pattern

Use `defaultdict` to auto-initialize missing keys.

```python
from collections import defaultdict

# List default - for grouping
groups = defaultdict(list)
groups['a'].append(1)  # No KeyError, creates empty list first
groups['a'].append(2)
# {'a': [1, 2]}

# Set default - for unique grouping
unique_groups = defaultdict(set)
unique_groups['a'].add(1)
unique_groups['a'].add(1)  # Deduped
# {'a': {1}}

# Int default - for counting
counts = defaultdict(int)
counts['a'] += 1  # No KeyError, starts at 0
# {'a': 1}

# Nested defaultdict
tree = lambda: defaultdict(tree)
d = tree()
d['a']['b']['c'] = 1  # Auto-creates nested structure
```

## Example (from pytudes)

```python
from collections import defaultdict

# Adjacency list for graphs (AdventUtils.ipynb)
class multimap(defaultdict):
    """A mapping of {key: [val1, val2, ...]}."""
    def __init__(self, pairs=(), symmetric=False):
        self.default_factory = list
        for key, val in pairs:
            self[key].append(val)
            if symmetric:
                self[val].append(key)

# Usage
edges = [('a', 'b'), ('a', 'c'), ('b', 'd')]
graph = multimap(edges, symmetric=True)
# graph['a'] = ['b', 'c']
# graph['b'] = ['a', 'd']

# Grouping by attribute
students = [('Alice', 'Math'), ('Bob', 'CS'), ('Carol', 'Math')]
by_major = defaultdict(list)
for name, major in students:
    by_major[major].append(name)
# {'Math': ['Alice', 'Carol'], 'CS': ['Bob']}

# Precomputing relationships (Sudoku.ipynb concept)
units = defaultdict(list)
for unit in all_units:
    for square in unit:
        units[square].append(unit)
# units['A1'] = [row_unit, col_unit, box_unit]
```

## Key Principles
1. **Factory, not value**: Pass `list`, not `[]`
2. **Auto-creates on access**: Even `d[key]` creates entry
3. **Symmetric graphs**: Add both directions for undirected
4. **Nesting**: `defaultdict(lambda: defaultdict(int))`
5. **Check existence carefully**: `key in d` before access if you don't want creation
