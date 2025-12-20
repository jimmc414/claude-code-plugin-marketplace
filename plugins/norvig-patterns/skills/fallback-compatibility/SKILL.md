---
description: "For cross-version support: try/except imports, optional dependencies, graceful degradation across Python versions."
---

# fallback-compatibility

## When to Use
- Supporting multiple Python versions
- Optional dependency handling
- Feature detection
- Graceful degradation

## When NOT to Use
- Single Python version target
- Required dependency (should fail if missing)
- Over-engineering simple code

## The Pattern

Try preferred import/feature, fall back to alternative.

```python
# Python version compatibility
try:
    from functools import cache
except ImportError:
    from functools import lru_cache
    cache = lru_cache(None)

# Optional dependency
try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

def process(data):
    if HAS_NUMPY:
        return np.array(data).mean()
    else:
        return sum(data) / len(data)
```

## Example (from pytudes)

```python
# beal.py - math.gcd location changed between versions
try:
    from math import gcd      # Python 3.5+
except ImportError:
    from fractions import gcd # Python 2.7 and early 3.x

# ngrams.py - use available modules
try:
    from functools import cache
except ImportError:
    from functools import lru_cache
    def cache(func):
        return lru_cache(None)(func)

# Pattern for conditional features
try:
    # Python 3.10+ pattern matching
    def dispatch(x):
        match x:
            case int(): return handle_int(x)
            case str(): return handle_str(x)
            case _: return handle_other(x)
except SyntaxError:
    # Fallback for older Python
    def dispatch(x):
        if isinstance(x, int):
            return handle_int(x)
        elif isinstance(x, str):
            return handle_str(x)
        else:
            return handle_other(x)

# Graceful feature degradation
try:
    import matplotlib.pyplot as plt
    def plot(data):
        plt.plot(data)
        plt.show()
except ImportError:
    def plot(data):
        print("Plotting requires matplotlib")
        print(f"Data: {data[:10]}...")
```

## Key Principles
1. **Try modern first**: Prefer newer, better APIs
2. **ImportError for missing**: Standard exception for imports
3. **Create compatible API**: Wrapper that works either way
4. **Flag for optional**: `HAS_FEATURE` pattern
5. **Fail gracefully**: Warn, don't crash
