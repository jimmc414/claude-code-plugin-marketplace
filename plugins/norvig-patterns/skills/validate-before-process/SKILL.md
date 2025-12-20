---
description: "For input validation: check format and constraints before processing, fail fast with clear errors, defensive parsing."
---

# validate-before-process

## When to Use
- Accepting external/user input
- File format must be exact
- Early failure is better than silent corruption
- Building robust parsers

## When NOT to Use
- Trusted internal data
- Validation overhead too high
- Best-effort processing is acceptable

## The Pattern

Validate input structure before processing, with clear error messages.

```python
def parse_grid(grid_string):
    """Parse and validate a grid."""
    lines = grid_string.strip().split('\n')

    # Validate structure
    if not lines:
        raise ValueError("Empty grid")

    width = len(lines[0])
    for i, line in enumerate(lines):
        if len(line) != width:
            raise ValueError(f"Line {i} has wrong width: {len(line)} != {width}")

    # Now safe to process
    return [[c for c in line] for line in lines]

def validate(data, predicate, message):
    """Validate data with predicate, raise with message if fails."""
    if not predicate(data):
        raise ValueError(f"{message}: {data}")
    return data
```

## Example (from pytudes)

```python
# Grid validation (sudoku.py)
def grid_values(grid):
    """Convert grid into a dict of {square: char}."""
    chars = [c for c in grid if c in digits or c in '0.']

    # Validate length
    if len(chars) != 81:
        print(grid, chars, len(chars))
    assert len(chars) == 81, f"Expected 81 chars, got {len(chars)}"

    return dict(zip(squares, chars))

# Formula validation (Cryptarithmetic.ipynb)
def valid(pformula):
    """A formula is valid iff it has no leading zero and evaluates to True."""
    try:
        return (not leading_zero(pformula)) and (eval(pformula) is True)
    except ArithmeticError:
        return False

leading_zero = re.compile(r'\b0[0-9]').search

# Number of letters check
def translate_formula(formula):
    letters = all_letters(formula)
    assert len(letters) <= 10, f'{len(letters)} letters is too many; only 10 allowed'
    ...

# Lispy require function (lispy.py)
def require(x, predicate, msg="wrong length"):
    """Signal a syntax error if predicate is false."""
    if not predicate:
        raise SyntaxError(to_string(x) + ': ' + msg)

# Usage in parsing
def expand(x):
    require(x, x != [])  # Empty list is error
    if x[0] is _quote:
        require(x, len(x) == 2)  # quote needs exactly 2 elements
        return x
```

## Key Principles
1. **Fail fast**: Check early, before processing
2. **Clear messages**: Say what's wrong and show the data
3. **Assert for invariants**: Use assert for "should never happen"
4. **Raise for input errors**: Use exceptions for invalid input
5. **Validate at boundaries**: Check external input, trust internal data
