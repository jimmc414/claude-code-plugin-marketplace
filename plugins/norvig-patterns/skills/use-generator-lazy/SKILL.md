---
description: "For memory efficiency: large sequences, infinite streams, early termination possible, pipeline processing without materializing all data."
---

# use-generator-lazy

## When to Use
- Sequence is large or potentially infinite
- Only need one element at a time
- Early termination is common (find first match)
- Pipelining transformations
- Memory is constrained

## When NOT to Use
- Need random access to elements
- Need length before iterating
- Will iterate multiple times
- Sequence is small

## The Pattern

Use generator expressions and `yield` for lazy evaluation.

```python
# Generator expression (lazy)
squares = (x**2 for x in range(1000000))  # No memory used yet
first_ten = list(islice(squares, 10))     # Only computes 10

# Generator function
def fibonacci():
    a, b = 0, 1
    while True:  # Infinite!
        yield a
        a, b = b, a + b

# Take only what you need
from itertools import islice
first_20_fibs = list(islice(fibonacci(), 20))

# Early termination
def first_match(predicate, iterable):
    for item in iterable:
        if predicate(item):
            return item  # Stops iteration
    return None
```

## Example (from pytudes)

```python
# Cryptarithmetic solver (Cryptarithmetic.ipynb)
def solve(formula):
    """Yield solutions as found - don't compute all at once."""
    letters = all_letters(formula)
    for digits in permutations('1234567890', len(letters)):
        if valid(substitute(digits, letters, formula)):
            yield substitute(digits, letters, formula)

# Get just the first solution
first_solution = next(solve('SEND + MORE = MONEY'))

# Or get all solutions
all_solutions = list(solve('SEND + MORE = MONEY'))

# Game of Life generations (Life.ipynb)
def life(world, n=float('inf')):
    """Yield n generations."""
    for _ in range(n):
        yield world
        world = next_generation(world)

# Animate or process lazily
for generation, world in enumerate(life(glider, 100)):
    display(world)
    if is_stable(world):
        break  # Early termination

# Two edits away (spell.py)
def edits2(word):
    """All strings two edits from word."""
    return (e2 for e1 in edits1(word)
                for e2 in edits1(e1))  # Generator of generators
```

## Key Principles
1. **Parentheses = lazy**: `(x for x in ...)` vs `[x for x in ...]`
2. **yield = generator function**: Returns iterator, pauses between yields
3. **yield from = delegate**: `yield from iterable` yields each item
4. **next() for one**: Get single item from generator
5. **Can't rewind**: Once consumed, generator is exhausted
