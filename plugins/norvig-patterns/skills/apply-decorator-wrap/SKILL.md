---
name: apply-decorator-wrap
description: "For cross-cutting concerns: add behavior without modifying functions, caching, timing, logging, validation wrappers."
---

# apply-decorator-wrap

## When to Use
- Adding caching/memoization
- Timing function execution
- Logging function calls
- Input validation
- Retry logic
- Any cross-cutting concern

## When NOT to Use
- Behavior is specific to one function
- Would obscure function's purpose
- Simple inline code is clearer

## The Pattern

Decorators wrap functions to add behavior before, after, or around the original.

```python
def timing(func):
    """Decorator to time function execution."""
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.3f}s")
        return result
    return wrapper

@timing
def slow_function():
    time.sleep(1)
    return "done"

# Equivalent to: slow_function = timing(slow_function)
```

## Example (from pytudes)

```python
# Memoization decorator (ngrams.py)
def memo(f):
    """Memoize function f."""
    table = {}

    def fmemo(*args):
        if args not in table:
            table[args] = f(*args)
        return table[args]

    fmemo.memo = table  # Expose cache
    return fmemo

@memo
def segment(text):
    """Optimal word segmentation."""
    if not text:
        return []
    candidates = ([first] + segment(rest)
                  for first, rest in splits(text))
    return max(candidates, key=word_prob)

# Using functools for cleaner decorators
from functools import cache, lru_cache, wraps

@cache  # Built-in memoization
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

@lru_cache(maxsize=1000)  # Limited cache size
def expensive_lookup(key):
    ...

# Reusable decorator with parameter
cache = lru_cache(None)  # Alias for unlimited cache

@cache
def expressions(numbers):
    ...

@cache
def segment(text):
    ...
```

## Key Principles
1. **Wrapper preserves signature**: Use `@functools.wraps`
2. **Return wrapper**: Decorator returns the wrapped function
3. **Expose internals**: Attach cache/state as attribute
4. **Stack decorators**: Multiple decorators apply bottom-up
5. **Decorator factories**: `@lru_cache(n)` returns decorator
