---
name: capture-state-closure
description: "For persistent state: closures capture outer variables, alternative to classes for simple state, factory functions that remember context."
---

# capture-state-closure

## When to Use
- Need state that persists across function calls
- Simpler than defining a class
- Creating specialized functions from a template
- Memoization with accessible cache
- Callback factories

## When NOT to Use
- Multiple methods needed (use class)
- State is complex (use class)
- Need inheritance or protocols

## The Pattern

Nested function captures variables from enclosing scope.

```python
def make_counter(start=0):
    """Create a counter function with persistent state."""
    count = start  # Captured by inner function

    def counter():
        nonlocal count
        count += 1
        return count

    return counter

c = make_counter(10)
c()  # 11
c()  # 12
```

## Example (from pytudes)

```python
# Memoization via closure (ngrams.py)
def memo(f):
    """Memoize function f."""
    table = {}  # Captured mutable state

    def fmemo(*args):
        if args not in table:
            table[args] = f(*args)
        return table[args]

    fmemo.memo = table  # Expose cache for inspection
    return fmemo

@memo
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Access the cache
fibonacci.memo  # {(0,): 0, (1,): 1, (2,): 1, ...}

# Symbol interning (lispy.py)
def Sym(s, symbol_table={}):  # Mutable default = persistent state
    """Find or create unique Symbol for string s."""
    if s not in symbol_table:
        symbol_table[s] = Symbol(s)
    return symbol_table[s]

# Same symbol every time
assert Sym('quote') is Sym('quote')

# Partial application via closure
def make_multiplier(factor):
    """Create a function that multiplies by factor."""
    def multiply(x):
        return x * factor  # factor captured
    return multiply

double = make_multiplier(2)
triple = make_multiplier(3)
double(5)  # 10
triple(5)  # 15
```

## Key Principles
1. **Inner function sees outer scope**: Variables are captured
2. **Mutable objects shared**: Lists, dicts can be modified
3. **nonlocal for rebinding**: Needed to reassign immutable captured vars
4. **Default args persist**: Mutable default arg is like static variable
5. **Expose internals**: Attach captured state as attribute for inspection
