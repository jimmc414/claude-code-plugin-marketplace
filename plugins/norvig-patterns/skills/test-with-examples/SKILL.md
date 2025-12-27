---
name: test-with-examples
description: "For example-driven development: test cases as specifications, input/output pairs, documentation through examples."
---

# test-with-examples

## When to Use
- Clear, discrete input/output relationships
- Examples serve as specification
- Teaching or documenting behavior
- Regression testing

## When NOT to Use
- Behavior too complex for examples
- Need property-based testing
- Examples would be exhaustive

## The Pattern

Write tests as lists of (input, expected_output) pairs.

```python
# Test cases as data
tests = [
    (input1, expected1),
    (input2, expected2),
    (input3, expected3),
]

def run_tests(func, tests):
    """Run function on test cases."""
    for inp, expected in tests:
        result = func(inp)
        assert result == expected, f"{func.__name__}({inp}) = {result}, expected {expected}"
    print(f"All {len(tests)} tests pass.")
```

## Example (from pytudes)

```python
# lispytest.py - comprehensive test examples
lis_tests = [
    ("(quote (testing 1 (2.0) -3.14e159))", ['testing', 1, [2.0], -3.14e159]),
    ("(+ 2 2)", 4),
    ("(+ (* 2 100) (* 1 10))", 210),
    ("(if (> 6 5) (+ 1 1) (+ 2 2))", 2),
    ("(if (< 6 5) (+ 1 1) (+ 2 2))", 4),
    ("(define x 3)", None),
    ("x", 3),
    ("(+ x x)", 6),
    ("((lambda (x) (+ x x)) 5)", 10),
    ("(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))", None),
    ("(fact 10)", 3628800),
    ("(fact 50)", 30414093201713378043612608166064768844377641568960512000000000000),
]

# DocstringFixpoint.ipynb - rainfall tests
def test_rainfall():
    assert 0/2 == rainfall([0, 0]),                "no rain"
    assert 5/1 == rainfall([5]),                   "one day"
    assert 6/3 == rainfall([1, 2, 3]),             "mean of several days"
    assert 6/4 == rainfall([0, 1, 2, 3]),          "non-integer mean"
    assert 9/3 == rainfall([1, 2, -9, -100, 6]),   "negative values ignored"
    assert 7/5 == rainfall([1, 0, 2, 0, 4]),       "zeros not ignored"
    assert 8/3 == rainfall([1, 2, 5, -999, 404]),  "values after -999 ignored"
    return True

# Cryptarithmetic.ipynb - solver test examples
for solver in (solve, faster_solve):
    assert "1 + 2 = 3" in set(solver("A + B = C"))
    assert not set(solver("A + B = CDE"))  # No solution
    assert set(solver("A * B = CA")) == {
        '5 * 3 = 15', '5 * 7 = 35', '4 * 6 = 24',
        '8 * 6 = 48', '2 * 6 = 12', '5 * 9 = 45'
    }
```

## Key Principles
1. **Examples as spec**: Tests define expected behavior
2. **Comments explain**: Brief note on what each tests
3. **Cover edge cases**: Empty, zero, negative, boundary
4. **Expected first or last**: Consistent (input, expected) order
5. **Readable assertions**: `assert result == expected, message`
