---
description: "For constraint problems: eliminate impossibilities before guessing, reduce search space through inference, fail fast on contradictions."
---

# propagate-then-search

## When to Use
- Constraint satisfaction problems
- When assigning one value constrains others
- Large search space that can be pruned
- Sudoku, scheduling, puzzles with rules

## When NOT to Use
- No constraint propagation possible
- Constraints are independent
- Simple brute force is fast enough

## The Pattern

**Propagate**: When you assign a value, infer all consequences.
**Search**: Only guess when propagation can't proceed.

```python
def solve(problem):
    """Solve by alternating propagation and search."""
    state = propagate(problem.initial_state)

    if state is None:
        return None  # Contradiction during propagation

    if is_complete(state):
        return state

    # Search: make a guess and recurse
    return search(state)

def search(state):
    # Choose variable with fewest remaining options (MRV)
    var = min(unassigned_vars(state),
              key=lambda v: len(possible_values(state, v)))

    for value in possible_values(state, var):
        new_state = assign(copy(state), var, value)
        new_state = propagate(new_state)

        if new_state is not None:
            result = solve(new_state)
            if result is not None:
                return result

    return None  # All values failed
```

## Example (from pytudes Sudoku.ipynb)

```python
def solve(grid):
    return search(parse_grid(grid))

def search(values):
    """DFS with constraint propagation."""
    if values is False:
        return False

    if all(len(values[s]) == 1 for s in squares):
        return values  # Solved!

    # MRV: choose unfilled square with fewest possibilities
    n, s = min((len(values[s]), s)
               for s in squares if len(values[s]) > 1)

    # Try each possibility
    for d in values[s]:
        result = search(assign(values.copy(), s, d))
        if result:
            return result

    return False

def assign(values, s, d):
    """Assign d to square s; propagate constraints."""
    other = values[s].replace(d, '')
    if all(eliminate(values, s, d2) for d2 in other):
        return values
    return False

def eliminate(values, s, d):
    """Remove d from values[s]; propagate consequences."""
    if d not in values[s]:
        return values  # Already gone

    values[s] = values[s].replace(d, '')

    # Rule 1: If square has no possibilities, fail
    if len(values[s]) == 0:
        return False

    # Rule 2: If square has one possibility, eliminate from peers
    if len(values[s]) == 1:
        d2 = values[s]
        if not all(eliminate(values, s2, d2) for s2 in peers[s]):
            return False

    # Rule 3: If only one place for d in unit, assign it there
    for u in units[s]:
        places = [s2 for s2 in u if d in values[s2]]
        if len(places) == 0:
            return False
        if len(places) == 1:
            if not assign(values, places[0], d):
                return False

    return values
```

## Key Principles
1. **Propagate fully**: Follow all inference chains before guessing
2. **Fail fast**: Detect contradictions immediately
3. **MRV heuristic**: Guess variable with fewest options first
4. **Copy before guess**: Don't mutate state during search
5. **Return False/None for failure**: Distinguish from empty solution
