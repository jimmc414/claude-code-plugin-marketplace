---
description: "For rule-based systems: store rules as data, easier to add/modify than if-elif chains, simplification tables, configuration."
---

# use-table-driven-rules

## When to Use
- Many special cases (simplification rules)
- Configuration-driven behavior
- Lookup tables
- State machines
- Rules that change frequently
- Making rules visible/maintainable

## When NOT to Use
- Few simple cases (use if-elif)
- Rules require complex logic
- Order of evaluation matters in complex ways

## The Pattern

Store rules in data structures instead of code.

```python
# Instead of:
def simplify(expr):
    if expr == ('+', 0, x): return x
    if expr == ('+', x, 0): return x
    if expr == ('*', 1, x): return x
    ...

# Use table:
simp_rules = {
    ('+', 0, 'x'): 'x',
    ('+', 'x', 0): 'x',
    ('*', 1, 'x'): 'x',
    ('*', 'x', 1): 'x',
    ('*', 0, 'x'): 0,
}

def simplify(expr):
    pattern = generalize(expr)  # Convert to pattern form
    if pattern in simp_rules:
        return instantiate(simp_rules[pattern], expr)
    return expr
```

## Example (from pytudes)

```python
# Simplification table (Differentiation.ipynb)
simp_table = {
    sin(0): 0,
    sin(pi): 0,
    sin(pi/2): 1,
    cos(0): 1,
    cos(pi): -1,
    cos(pi/2): 0,
    tan(0): 0,
    ln(1): 0,
    ln(e): 1,
}

def simp(y):
    """Simplify expression using table and rules."""
    if y in simp_table:
        return simp_table[y]
    # ... additional simplification logic

# Direction vectors (AdventUtils.ipynb)
arrow_direction = {
    '^': (0, -1),  # North
    'v': (0, 1),   # South
    '>': (1, 0),   # East
    '<': (-1, 0),  # West
    '.': (0, 0),   # Stay
}

def move(pos, arrow):
    dx, dy = arrow_direction[arrow]
    return (pos[0] + dx, pos[1] + dy)

# Factor multipliers (pal2.py)
factor = {'left': +1, 'right': -1}

def add_word(self, direction, word):
    self.diff += factor[direction] * len(word)

# Lisp operations (lis.py)
env = {
    '+': op.add,
    '-': op.sub,
    '*': op.mul,
    '/': op.truediv,
}
```

## Key Principles
1. **Data over code**: Rules as dict entries, not if statements
2. **Easy to extend**: Adding rule = adding dict entry
3. **Visible rules**: Can print/inspect the table
4. **Consistent lookup**: All rules checked same way
5. **Fallback logic**: Handle missing keys gracefully
