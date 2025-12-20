---
description: "For writing clean functions: start with docstring, iterate until code matches docstring exactly, achieve docstring-code isomorphism."
---

# write-docstring-first

## When to Use
- Writing any new function
- When clarity of purpose matters
- Complex logic that needs explanation
- Functions that will be reused
- Teaching or educational code

## When NOT to Use
- Trivial one-liners (`return x + 1`)
- Private implementation details
- Rapidly prototyping (add later)

## The Pattern

**Docstring Fixpoint Theory**: Iterate between docstring and code until they are isomorphic - each reads like a translation of the other.

```python
# Step 1: Write docstring as specification
def rainfall(numbers):
    """Return the mean of the non-negative values in a list,
    up to the first -999 (if it shows up)."""
    ...

# Step 2: Write code that mirrors the docstring
def rainfall(numbers):
    """Return the mean of the non-negative values in a list,
    up to the first -999 (if it shows up)."""
    return mean(non_negative(upto(-999, numbers)))

# Notice: docstring and code are almost the same sentence!
```

## Example (from pytudes DocstringFixpoint.ipynb)

```python
# The Rainfall Problem - evolved through fixpoint iteration

# Version 1: Problem statement as docstring
def rainfall(numbers):
    """Design a program called rainfall that consumes a list of numbers
    representing daily rainfall amounts. The list may contain -999
    indicating end of data. Produce the average of non-negative values
    up to the first -999."""
    ...

# Version 2: Simplified docstring
def rainfall(numbers):
    """Produce the average of the non-negative values in a list,
    up to the first -999 (if it shows up)."""
    ...

# Version 3: Code mirrors docstring
def rainfall(numbers):
    """Return the mean of the non-negative values in a list,
    up to the first -999 (if it shows up)."""
    return mean(non_negative(upto(-999, numbers)))

# Helper functions (each with its own fixpoint)
def upto(sentinel, items):
    """Return items that appear before sentinel,
    or all items if sentinel doesn't appear."""
    return items[:items.index(sentinel)] if sentinel in items else items

def non_negative(numbers):
    """The numbers that are >= 0."""
    return [x for x in numbers if x >= 0]
```

## Key Principles
1. **Docstring first**: Specification before implementation
2. **Iterate both ways**: Edit docstring, then code, then docstring...
3. **Match vocabulary**: Use same words in both
4. **Helpers inherit pattern**: Each has its own docstring-code match
5. **Fixpoint = done**: When neither needs changing, you're done
