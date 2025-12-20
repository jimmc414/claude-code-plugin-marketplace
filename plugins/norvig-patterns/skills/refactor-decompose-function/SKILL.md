---
description: "For long functions: break into smaller pieces, extract helper functions, reduce nesting, improve testability and readability."
---

# refactor-decompose-function

## When to Use
- Function is longer than 10-15 lines
- Multiple levels of nesting
- Hard to understand at a glance
- Difficult to test parts independently
- Code has natural "chunks" with different purposes

## When NOT to Use
- Function is already simple and clear
- Decomposition would obscure the algorithm
- Helpers would only be used once with no clarity gain

## The Pattern

Extract cohesive chunks into named helper functions. Each function should do one thing.

```python
# BEFORE: Long, hard to test
def process_data(data):
    # Validate
    if not data:
        raise ValueError("Empty data")
    if not all(isinstance(x, int) for x in data):
        raise TypeError("Non-integer data")

    # Transform
    result = []
    for x in data:
        if x > 0:
            result.append(x * 2)
        else:
            result.append(0)

    # Summarize
    total = sum(result)
    avg = total / len(result)
    return {'data': result, 'total': total, 'average': avg}

# AFTER: Decomposed, each part testable
def process_data(data):
    validate(data)
    transformed = transform(data)
    return summarize(transformed)

def validate(data):
    if not data:
        raise ValueError("Empty data")
    if not all(isinstance(x, int) for x in data):
        raise TypeError("Non-integer data")

def transform(data):
    return [x * 2 if x > 0 else 0 for x in data]

def summarize(data):
    total = sum(data)
    return {'data': data, 'total': total, 'average': total / len(data)}
```

## Example (from pytudes)

```python
# Spelling correction (spell.py) - beautifully decomposed
def correction(word):
    """Most probable spelling correction for word."""
    return max(candidates(word), key=P)

def candidates(word):
    """Generate possible spelling corrections for word."""
    return known([word]) or known(edits1(word)) or known(edits2(word)) or [word]

def known(words):
    """The subset of words that appear in the dictionary."""
    return set(w for w in words if w in WORDS)

def edits1(word):
    """All edits one edit away from word."""
    letters = 'abcdefghijklmnopqrstuvwxyz'
    splits = [(word[:i], word[i:]) for i in range(len(word) + 1)]
    deletes = [L + R[1:] for L, R in splits if R]
    transposes = [L + R[1] + R[0] + R[2:] for L, R in splits if len(R) > 1]
    replaces = [L + c + R[1:] for L, R in splits if R for c in letters]
    inserts = [L + c + R for L, R in splits for c in letters]
    return set(deletes + transposes + replaces + inserts)

def edits2(word):
    """All edits two edits away from word."""
    return (e2 for e1 in edits1(word) for e2 in edits1(e1))
```

## Key Principles
1. **Each function = one job**: Name describes the job
2. **1-5 lines ideal**: If longer, consider splitting
3. **Testable units**: Each helper can be tested alone
4. **Read top-down**: High-level function shows the story
5. **Compose, don't nest**: `f(g(h(x)))` beats deeply nested code
