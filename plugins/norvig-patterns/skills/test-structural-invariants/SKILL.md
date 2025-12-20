---
description: "For data structure validation: test lengths, relationships, constraints that must hold, verify setup is correct."
---

# test-structural-invariants

## When to Use
- After building complex data structures
- Verifying precomputed relationships
- Checking initialization is correct
- Invariants that should always hold

## When NOT to Use
- Simple data
- No structural constraints
- Runtime performance critical

## The Pattern

Assert properties that must be true about your data structures.

```python
# After building structure, verify invariants
def test_structure():
    # Size invariants
    assert len(items) == EXPECTED_SIZE

    # Relationship invariants
    assert all(condition(item) for item in items)

    # Coverage invariants
    assert set(keys) == expected_keys

    # Bidirectional relationship
    for a, bs in graph.items():
        for b in bs:
            assert a in graph[b]  # Symmetric
```

## Example (from pytudes)

```python
# sudoku.py - Sudoku structure invariants
def test():
    """A set of tests that must pass."""
    # Size invariants
    assert len(squares) == 81       # 9x9 grid
    assert len(unitlist) == 27      # 9 rows + 9 cols + 9 boxes

    # Relationship invariants
    assert all(len(units[s]) == 3 for s in squares)   # Each square in 3 units
    assert all(len(peers[s]) == 20 for s in squares)  # Each square has 20 peers

    # Specific structure verification
    assert units['C2'] == [
        ['A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2'],  # Column
        ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9'],  # Row
        ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']   # Box
    ]
    assert peers['C2'] == set([...20 peers...])

    print('All tests pass.')

# beal.py - mathematical structure tests
def tests():
    assert make_Apowers(6, 10) == {
        1: [1],
        2: [8, 16, 32, 128],
        3: [27, 81, 243, 2187],
        ...
    }
    assert make_Czroots(make_Apowers(5, 8)) == {1: 1, 8: 2, 16: 2, ...}
    assert 3 ** 3 + 6 ** 3 in Czroots
    assert 99 ** 97 in Czroots
    assert 101 ** 100 not in Czroots

# spell.py - corpus statistics invariants
def unit_tests():
    assert len(WORDS) == 32198
    assert sum(WORDS.values()) == 1115585
    assert WORDS.most_common(10) == [
        ('the', 79809), ('of', 40024), ('and', 38312), ...
    ]
```

## Key Principles
1. **Test after construction**: Verify build was correct
2. **Size invariants**: Expected counts
3. **Relationship invariants**: Things that must be connected
4. **Specific examples**: Check known cases manually
5. **Use `all()` for universal checks**: Clean assertion syntax
