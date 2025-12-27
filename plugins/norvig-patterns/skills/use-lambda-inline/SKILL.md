---
name: use-lambda-inline
description: "For inline callbacks: anonymous one-liner functions, key functions for sorting, trivial transformations as dict values."
---

# use-lambda-inline

## When to Use
- Simple one-liner needed inline
- `key=` argument to sorted/max/min
- Dict of operation functions
- Trivial transformations
- Callback registration

## When NOT to Use
- Multiple statements needed
- Function will be reused by name
- Complex logic that needs documentation
- Recursion needed (lambda can't easily recurse)

## The Pattern

Use `lambda` for anonymous, single-expression functions.

```python
# Sorting with custom key
sorted(items, key=lambda x: x.priority)
max(scores, key=lambda s: s.value)

# Dict of operations
ops = {'+': lambda a, b: a + b,
       '-': lambda a, b: a - b,
       '*': lambda a, b: a * b}

result = ops['+'](3, 4)  # 7

# Filter with inline predicate
positive = filter(lambda x: x > 0, numbers)

# Default argument for capturing
buttons = [Button(lambda i=i: click(i)) for i in range(10)]
```

## Example (from pytudes)

```python
# Lisp interpreter operations (lis.py)
env = {
    '+': op.add,
    '-': op.sub,
    'apply': lambda proc, args: proc(*args),
    'begin': lambda *x: x[-1],
    'car': lambda x: x[0],
    'cdr': lambda x: x[1:],
    'cons': lambda x, y: [x] + y,
    'length': len,
    'list': lambda *x: list(x),
    'map': lambda *args: list(map(*args)),
    'null?': lambda x: x == [],
    'number?': lambda x: isinstance(x, Number),
}

# Probability key functions (Probability.ipynb)
max(candidates, key=lambda c: probability(c))

# MRV heuristic (Sudoku.ipynb)
s = min((s for s in squares if len(values[s]) > 1),
        key=lambda s: len(values[s]))

# Sort by multiple criteria
sorted(items, key=lambda x: (x.category, -x.priority, x.name))

# Regex substitution callback (Cryptarithmetic.ipynb)
result = re.sub(r'[A-Z]+',
                lambda m: translate_word(m.group()),
                formula)
```

## Key Principles
1. **One expression only**: No statements, just return value
2. **Use `op` module for operators**: `op.add` clearer than `lambda a,b: a+b`
3. **Default args for capture**: `lambda i=i:` captures current `i`
4. **Keep it short**: If complex, use named function
5. **Readable keys**: `key=lambda x: x.name` is clear
