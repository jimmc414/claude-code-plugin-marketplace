---
description: "For test co-location: tests in same file as code, run with main, tests as documentation and examples."
---

# verify-with-inline-tests

## When to Use
- Tests should be near the code
- Tests serve as documentation
- Single-file modules
- Quick verification during development

## When NOT to Use
- Large test suites
- Need test isolation
- CI/CD expects tests in specific location

## The Pattern

Include tests in the module, run them when module is executed directly.

```python
def my_function(x):
    """Do something useful."""
    return x * 2

def test():
    """Run all tests."""
    assert my_function(2) == 4
    assert my_function(0) == 0
    assert my_function(-1) == -2
    print("All tests pass.")

if __name__ == '__main__':
    test()
```

## Example (from pytudes)

```python
# sudoku.py - structural invariant tests
def test():
    """A set of tests that must pass."""
    assert len(squares) == 81
    assert len(unitlist) == 27
    assert all(len(units[s]) == 3 for s in squares)
    assert all(len(peers[s]) == 20 for s in squares)
    assert units['C2'] == [
        ['A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2'],
        ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9'],
        ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']
    ]
    print('All tests pass.')

if __name__ == '__main__':
    test()
    solve_all(open("sudoku-easy50.txt"), "easy")
    solve_all(open("sudoku-top95.txt"), "hard")

# spell.py - comprehensive unit tests
def unit_tests():
    assert correction('speling') == 'spelling'
    assert correction('korrectud') == 'corrected'
    assert correction('bycycle') == 'bicycle'
    assert words('This is a TEST.') == ['this', 'is', 'a', 'test']
    assert len(WORDS) == 32198
    assert sum(WORDS.values()) == 1115585
    assert 0.07 < P('the') < 0.08
    return 'unit_tests pass'

if __name__ == '__main__':
    print(unit_tests())
    spelltest(Testset(open('spell-testset1.txt')))
```

## Key Principles
1. **`if __name__ == '__main__'`**: Only run tests when executed directly
2. **Assert for tests**: Simple, clear assertions
3. **Print success**: Confirm tests ran
4. **Test structure first**: Validate data structures built correctly
5. **Tests as examples**: Show how functions are used
