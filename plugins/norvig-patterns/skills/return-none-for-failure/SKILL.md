---
name: return-none-for-failure
description: "For graceful failure: return None or False instead of exceptions, let caller decide how to handle failure."
---

# return-none-for-failure

## When to Use
- Algorithm might not find solution
- Search can fail naturally
- Caller should check result
- Backtracking search patterns

## When NOT to Use
- Failure is a programming error (raise exception)
- Caller must handle failure (exception is clearer)
- None is a valid result

## The Pattern

Return None (or False) to indicate failure, let caller check.

```python
def find(items, predicate):
    """Find first item matching predicate, or None."""
    for item in items:
        if predicate(item):
            return item
    return None  # Not found

# Caller checks
result = find(items, is_valid)
if result is not None:
    process(result)
else:
    handle_not_found()
```

## Example (from pytudes)

```python
# Sudoku solver (sudoku.py)
def search(values):
    """Using depth-first search and propagation."""
    if values is False:
        return False  # Failed earlier

    if all(len(values[s]) == 1 for s in squares):
        return values  # Solved!

    # Choose unfilled square with fewest possibilities
    n, s = min((len(values[s]), s)
               for s in squares if len(values[s]) > 1)

    for d in values[s]:
        result = search(assign(values.copy(), s, d))
        if result:  # Found solution
            return result

    return False  # No solution found

# Constraint propagation
def eliminate(values, s, d):
    """Return values, or False if contradiction detected."""
    if d not in values[s]:
        return values  # Already done

    values[s] = values[s].replace(d, '')

    if len(values[s]) == 0:
        return False  # Contradiction

    # ... more propagation
    return values

# Usage pattern
solution = solve(puzzle)
if solution:
    display(solution)
else:
    print("No solution exists")

# Cryptarithmetic (Cryptarithmetic.ipynb)
def first(iterable):
    """First element of iterable, or None."""
    return next(iter(iterable), None)

solution = first(solve('SEND + MORE = MONEY'))
if solution:
    print(solution)
```

## Key Principles
1. **False/None for "not found"**: Not an exception
2. **Caller checks with `if`**: Natural control flow
3. **Propagate failure**: `if result is False: return False`
4. **Truthy check works**: `if result:` catches None/False
5. **Document the contract**: Docstring says what failure means
