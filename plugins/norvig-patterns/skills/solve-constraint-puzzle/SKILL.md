---
description: "For constraint satisfaction: Sudoku, scheduling, N-queens, logic puzzles, SAT-like problems, assignment problems. Uses propagate-then-search pattern."
---

# solve-constraint-puzzle

## When to Use
- Sudoku and Sudoku-like puzzles
- Scheduling problems (classes, shifts, tournaments)
- N-queens and placement puzzles
- Logic puzzles (Einstein's riddle)
- Resource assignment problems
- Any problem with variables, domains, and constraints

## When NOT to Use
- Optimization problems (use local search instead)
- Problems without clear constraints
- When brute force is fast enough

## The Pattern

**Constraint Propagation + Search**: Eliminate impossibilities first, then guess only when necessary.

```python
def solve(puzzle):
    """Solve by propagation, then search if needed."""
    state = propagate(puzzle)
    if state is None:
        return None  # Contradiction found
    if is_solved(state):
        return state
    return search(state)

def search(state):
    """DFS with constraint propagation at each step."""
    # Choose variable with Minimum Remaining Values (MRV)
    var = min(unassigned(state), key=lambda v: len(state[v]))

    for value in state[var]:
        new_state = assign(copy(state), var, value)
        new_state = propagate(new_state)
        if new_state is not None:
            result = search(new_state)
            if result is not None:
                return result
    return None
```

## Example (from pytudes Sudoku.ipynb)

```python
def eliminate(values, s, d):
    """Eliminate digit d from values[s]; propagate constraints."""
    if d not in values[s]:
        return values  # Already eliminated

    values[s] = values[s].replace(d, '')

    # Constraint 1: If only one value left, eliminate from peers
    if len(values[s]) == 0:
        return None  # Contradiction
    elif len(values[s]) == 1:
        d2 = values[s]
        if not all(eliminate(values, peer, d2) for peer in peers[s]):
            return None

    # Constraint 2: If only one place for d in a unit, assign it
    for unit in units[s]:
        places = [sq for sq in unit if d in values[sq]]
        if len(places) == 0:
            return None  # Contradiction
        elif len(places) == 1:
            if not assign(values, places[0], d):
                return None

    return values

def search(values):
    """DFS with MRV heuristic."""
    if values is None:
        return None
    if all(len(values[s]) == 1 for s in squares):
        return values  # Solved!

    # MRV: choose square with fewest possibilities
    n, s = min((len(values[s]), s) for s in squares if len(values[s]) > 1)

    for d in values[s]:
        result = search(assign(values.copy(), s, d))
        if result:
            return result
    return None
```

## Key Principles
1. **Propagate before search**: Eliminate impossibilities to reduce search space
2. **MRV heuristic**: Try most constrained variable first (fail fast)
3. **Copy on branch**: Don't mutate state during search; copy before guessing
4. **Return None for failure**: Distinguishes "no solution" from "not yet solved"
5. **Precompute constraints**: Build `units` and `peers` once, use everywhere
