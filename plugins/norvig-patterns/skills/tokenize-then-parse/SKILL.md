---
name: tokenize-then-parse
description: "For interpreters: separate lexing from parsing, token stream to AST, structured text processing in stages."
---

# tokenize-then-parse

## When to Use
- Building interpreters or compilers
- Processing parenthesized expressions
- Structured text with clear token boundaries
- Multi-stage processing pipeline

## When NOT to Use
- Simple fixed format (just split)
- Very complex grammar (use parser generator)
- No clear token boundaries

## The Pattern

Tokenize text into a stream of tokens, then parse tokens into a structure.

```python
def tokenize(s):
    """Convert string to list of tokens."""
    return s.replace('(', ' ( ').replace(')', ' ) ').split()

def parse(tokens):
    """Parse tokens into nested structure."""
    token = tokens.pop(0)
    if token == '(':
        result = []
        while tokens[0] != ')':
            result.append(parse(tokens))
        tokens.pop(0)  # Remove ')'
        return result
    else:
        return atom(token)

def atom(token):
    """Convert token to appropriate type."""
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            return token
```

## Example (from pytudes lis.py)

```python
def tokenize(s):
    """Convert a string into a list of tokens."""
    return s.replace('(', ' ( ').replace(')', ' ) ').split()

def read_from_tokens(tokens):
    """Read an expression from a sequence of tokens."""
    if len(tokens) == 0:
        raise SyntaxError('unexpected EOF')

    token = tokens.pop(0)

    if token == '(':
        L = []
        while tokens[0] != ')':
            L.append(read_from_tokens(tokens))
        tokens.pop(0)  # Remove ')'
        return L
    elif token == ')':
        raise SyntaxError('unexpected )')
    else:
        return atom(token)

def atom(token):
    """Numbers become numbers; every other token is a symbol."""
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            return Symbol(token)

def parse(program):
    """Read a Scheme expression from a string."""
    return read_from_tokens(tokenize(program))

# Usage
parse("(+ 2 (* 3 4))")
# Returns: ['+', 2, ['*', 3, 4]]

parse("(define square (lambda (x) (* x x)))")
# Returns: ['define', 'square', ['lambda', ['x'], ['*', 'x', 'x']]]
```

## Key Principles
1. **Tokenize first**: Separate lexing from parsing
2. **pop(0) consumes**: Mutable token list, pop as you parse
3. **Recursive descent**: Parse nested structures recursively
4. **Error on malformed**: Raise SyntaxError for bad input
5. **atom() for literals**: Handle number conversion
