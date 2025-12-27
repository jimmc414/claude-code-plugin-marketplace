---
name: cascade-type-conversion
description: "For flexible parsing: try multiple type conversions in order, graceful fallback from specific to general types."
---

# cascade-type-conversion

## When to Use
- Parsing mixed-type data
- User input that could be various types
- "Best effort" type inference
- Atom/literal parsing in interpreters

## When NOT to Use
- Known fixed types
- Type ambiguity is a bug, not a feature
- Performance-critical inner loops

## The Pattern

Try conversions from most specific to most general, catching failures.

```python
def parse_value(s):
    """Parse string as most specific type possible."""
    # Try int first
    try:
        return int(s)
    except ValueError:
        pass

    # Try float
    try:
        return float(s)
    except ValueError:
        pass

    # Try bool
    if s.lower() in ('true', 'false'):
        return s.lower() == 'true'

    # Fall back to string
    return s
```

## Example (from pytudes)

```python
# Lisp atom parsing (lispy.py)
def atom(token):
    """Numbers become numbers; #t/#f are booleans; strings stay strings."""
    if token == '#t':
        return True
    elif token == '#f':
        return False
    elif token[0] == '"':
        return token[1:-1]  # Strip quotes

    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            try:
                return complex(token.replace('i', 'j', 1))
            except ValueError:
                return Sym(token)

# Simpler version (lis.py)
def atom(token):
    """Numbers become numbers; every other token is a symbol."""
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            return Symbol(token)

# Advent of Code parsing (AdventUtils.ipynb)
def atom(text: str):
    """Parse text into a single float or int or str."""
    try:
        x = float(text)
        return round(x) if x.is_integer() else x
    except ValueError:
        return text.strip()

# Version compatibility (beal.py)
try:
    from math import gcd       # Python 3.6+
except ImportError:
    from fractions import gcd  # Older Python
```

## Key Principles
1. **Specific to general**: Try int before float before string
2. **Catch ValueError**: Standard exception for failed conversions
3. **Chain try/except**: Each failure falls through to next
4. **Final fallback**: Always have a catch-all (usually string)
5. **Return in try block**: Conversion succeeded, return immediately
