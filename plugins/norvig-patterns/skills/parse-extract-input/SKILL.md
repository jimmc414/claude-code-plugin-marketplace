---
description: "For text processing: extract numbers, words, structured data from messy text using regex patterns, parsing utilities."
---

# parse-extract-input

## When to Use
- Extracting numbers from text
- Finding words or identifiers
- Parsing structured input files
- Data cleaning
- Advent of Code input parsing

## When NOT to Use
- Structured format (use JSON/CSV parsers)
- Complex grammar (use proper parser)
- Simple split is enough

## The Pattern

Use regex or helper functions to extract structured data from text.

```python
import re

def ints(text):
    """Extract all integers from text."""
    return tuple(map(int, re.findall(r'-?[0-9]+', text)))

def words(text):
    """Extract all words from text."""
    return tuple(re.findall(r'[a-zA-Z]+', text))

def atoms(text):
    """Extract all atoms (numbers or identifiers)."""
    return tuple(atom(s) for s in re.findall(r'[+-]?\d+\.?\d*|\w+', text))

def atom(s):
    """Parse string as number or keep as string."""
    try:
        return int(s)
    except ValueError:
        try:
            return float(s)
        except ValueError:
            return s
```

## Example (from pytudes AdventUtils.ipynb)

```python
import re

def ints(text: str) -> Tuple[int, ...]:
    """A tuple of all the integers in text."""
    return tuple(map(int, re.findall(r'-?[0-9]+', text)))

def positive_ints(text: str) -> Tuple[int, ...]:
    """A tuple of all positive integers in text."""
    return tuple(map(int, re.findall(r'[0-9]+', text)))

def digits(text: str) -> Tuple[int, ...]:
    """A tuple of all single digits in text."""
    return tuple(map(int, re.findall(r'[0-9]', text)))

def words(text: str) -> Tuple[str, ...]:
    """A tuple of all alphabetic words in text."""
    return tuple(re.findall(r'[a-zA-Z]+', text))

def atoms(text: str) -> Tuple:
    """A tuple of all atoms (numbers or identifiers)."""
    return tuple(map(atom, re.findall(r'[+-]?\d+\.?\d*|\w+', text)))

def atom(text: str):
    """Parse text into a single float or int or str."""
    try:
        x = float(text)
        return round(x) if x.is_integer() else x
    except ValueError:
        return text.strip()

# Usage examples
ints("Robot at (3, -5) with speed 10")  # (3, -5, 10)
words("Hello, World! 123")  # ('Hello', 'World')
atoms("x=42, y=3.14, name=foo")  # ('x', 42, 'y', 3.14, 'name', 'foo')
```

## Key Principles
1. **Regex for patterns**: `r'-?[0-9]+'` for signed integers
2. **Return tuples**: Immutable, hashable results
3. **Cascading conversion**: Try int, then float, then string
4. **Negative-aware**: Include `-?` for negative numbers
5. **Reusable utilities**: Same functions for any input
