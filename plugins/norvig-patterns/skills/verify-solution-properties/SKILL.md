---
name: verify-solution-properties
description: "For solution checking: independent verification that result is correct, separate from how it was computed."
---

# verify-solution-properties

## When to Use
- After solver/algorithm produces result
- When solution is complex but verification is simple
- Testing optimizers and search algorithms
- Building confidence in results

## When NOT to Use
- Verification as expensive as solving
- Trivially correct results
- No independent definition of "correct"

## The Pattern

Write a separate function that checks if a proposed solution satisfies all requirements.

```python
def solve(problem):
    """Find a solution (complex algorithm)."""
    ...
    return solution

def is_valid_solution(solution, problem):
    """Check if solution is valid (simple verification)."""
    return (satisfies_constraint_1(solution, problem) and
            satisfies_constraint_2(solution, problem) and
            covers_all_requirements(solution, problem))

# Use both together
solution = solve(problem)
assert is_valid_solution(solution, problem)
```

## Example (from pytudes)

```python
# sudoku.py - solution verification
def solved(values):
    """A puzzle is solved if each unit is a permutation of digits 1-9."""
    def unitsolved(unit):
        return set(values[s] for s in unit) == set(digits)
    return values is not False and all(unitsolved(unit) for unit in unitlist)

# More detailed solution check (Sudoku.ipynb)
def is_solution(solution, puzzle):
    """Is this proposed solution to the puzzle actually valid?"""
    return (solution is not None and
            # Solution respects original puzzle constraints
            all(solution[s] in puzzle[s] for s in squares) and
            # Each unit is a permutation of 1-9
            all({solution[s] for s in unit} == set(digits)
                for unit in all_units))

# SET.py - game rule verification
def is_set(cards):
    """Are these 3 cards a valid SET?"""
    for f in range(4):  # 4 features
        values = {card[f] for card in cards}
        if len(values) == 2:  # 2 distinct values = not a set
            return False
    return True

# Cryptarithmetic solution verification
def valid(pformula):
    """A formula is valid iff it has no leading zero and evaluates to True."""
    try:
        return (not leading_zero(pformula)) and (eval(pformula) is True)
    except ArithmeticError:
        return False

# Usage pattern
for digits in permutations(...):
    solution = substitute(digits, formula)
    if valid(solution):  # Independent verification
        yield solution
```

## Key Principles
1. **Verification != solving**: Often much simpler than finding
2. **Check all constraints**: Every rule must be satisfied
3. **Use in tests**: `assert is_valid(solve(problem), problem)`
4. **Independent definition**: Don't reuse solver logic
5. **Handle failure cases**: Return False, don't crash
