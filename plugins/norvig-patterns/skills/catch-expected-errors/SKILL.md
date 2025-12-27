---
name: catch-expected-errors
description: "For iteration with errors: catch exceptions during exploration, skip invalid cases, continue to next attempt."
---

# catch-expected-errors

## When to Use
- Trying many possibilities where some fail
- Division by zero might occur naturally
- Type conversion might fail
- Exploring invalid states in search

## When NOT to Use
- Errors indicate bugs (let them propagate)
- All inputs should be valid
- Exception overhead matters

## The Pattern

Wrap potentially failing code in try/except, continue on expected errors.

```python
for candidate in candidates:
    try:
        result = process(candidate)
        if is_valid(result):
            return result
    except (ValueError, ArithmeticError):
        continue  # Skip this candidate

return None  # None worked
```

## Example (from pytudes)

```python
# Cryptarithmetic solver (Cryptarithmetic.ipynb)
def faster_solve(formula):
    """Fill in digits to solve formula."""
    python_lambda, letters = translate_formula(formula)
    formula_fn = eval(python_lambda)

    for digits in permutations((1,2,3,4,5,6,7,8,9,0), len(letters)):
        try:
            if formula_fn(*digits) is True:
                yield format_solution(digits, letters, formula)
        except ArithmeticError:
            pass  # Division by zero - skip this combination

# Simple validator (Cryptarithmetic.ipynb)
def valid(pformula):
    """Valid iff no leading zero and evaluates to True."""
    try:
        return (not leading_zero(pformula)) and (eval(pformula) is True)
    except ArithmeticError:
        return False

# Type conversion cascade (lispy.py)
def atom(token):
    """Convert token to appropriate type."""
    if token == '#t': return True
    if token == '#f': return False
    if token[0] == '"': return token[1:-1]

    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            try:
                return complex(token.replace('i', 'j', 1))
            except ValueError:
                return Sym(token)

# Version compatibility (beal.py)
try:
    from math import gcd
except ImportError:
    from fractions import gcd
```

## Key Principles
1. **Specific exceptions**: Catch exactly what's expected
2. **Don't catch Exception**: Too broad, hides bugs
3. **pass or continue**: Skip failed case, try next
4. **Nested try for cascade**: Each level handles one failure
5. **Expected, not exceptional**: Error is part of normal operation
