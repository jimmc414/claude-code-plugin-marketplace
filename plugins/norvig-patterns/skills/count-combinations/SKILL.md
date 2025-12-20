---
description: "For probability and counting: permutations, combinations, sample spaces, Monte Carlo simulation, brute-force enumeration, card/dice problems."
---

# count-combinations

## When to Use
- Probability calculations
- Counting permutations or combinations
- Enumerating all possibilities (brute force)
- Monte Carlo simulation
- Card game probabilities
- Dice roll distributions
- Urn/ball problems

## When NOT to Use
- When closed-form formula exists and is simpler
- Astronomically large sample spaces (use simulation)
- When approximation is acceptable (use sampling)

## The Pattern

Define sample space explicitly, then count favorable outcomes.

```python
from fractions import Fraction
from itertools import combinations, permutations, product

def P(event, space):
    """Probability = favorable outcomes / total outcomes."""
    favorable = event & space if isinstance(event, set) else {x for x in space if event(x)}
    return Fraction(len(favorable), len(space))

# Sample spaces
die = {1, 2, 3, 4, 5, 6}
two_dice = {(a, b) for a in die for b in die}
deck = [r + s for r in 'A23456789TJQK' for s in 'SHDC']
hands = set(combinations(deck, 5))

# Events as sets or predicates
even = {2, 4, 6}
is_flush = lambda hand: len(set(c[1] for c in hand)) == 1
```

## Example (from pytudes Probability.ipynb)

```python
from fractions import Fraction
from itertools import combinations

def P(event, space):
    """The probability of an event, given a sample space."""
    favorable = {x for x in space if x in event} if isinstance(event, set) \
                else {x for x in space if event(x)}
    return Fraction(len(favorable), len(space))

# Urn problem: 6 blue, 9 red, 8 white balls; draw 6
def balls(color, n):
    return [f'{color}{i}' for i in range(1, n + 1)]

urn = balls('B', 6) + balls('R', 9) + balls('W', 8)
U6 = set(combinations(urn, 6))

def select(color, n, space=U6):
    """Event: exactly n balls of given color."""
    return {s for s in space if sum(1 for b in s if b[0] == color) == n}

# Probability of drawing 3 blue, 1 red, 2 white
P(select('B', 3) & select('R', 1) & select('W', 2), U6)
# Returns: Fraction(240, 4807)
```

## Key Principles
1. **Enumerate explicitly**: When feasible, list all outcomes
2. **Use Fraction**: Exact arithmetic, no floating point errors
3. **Events as sets**: Use set operations (union, intersection)
4. **Events as predicates**: Use functions for complex conditions
5. **itertools for generation**: `combinations`, `permutations`, `product`
