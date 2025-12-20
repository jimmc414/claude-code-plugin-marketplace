---
description: "For heterogeneous data: pattern matching on type/structure, interpreter eval loops, handling different expression types."
---

# dispatch-on-structure

## When to Use
- Interpreters: different behavior per expression type
- Processing heterogeneous data
- Pattern matching (before Python 3.10 match)
- AST walkers
- Multi-type handlers

## When NOT to Use
- Homogeneous data (use single code path)
- Object-oriented dispatch is clearer (use methods)
- Simple type checking suffices

## The Pattern

Check structure/type of input and dispatch to appropriate handler.

```python
def process(x):
    """Dispatch based on structure of x."""
    if isinstance(x, int):
        return handle_int(x)
    if isinstance(x, list) and len(x) == 0:
        return handle_empty()
    if isinstance(x, list) and x[0] == 'quote':
        return handle_quote(x[1])
    if isinstance(x, list):
        return handle_list(x)
    raise TypeError(f"Unknown type: {type(x)}")
```

## Example (from pytudes lis.py)

```python
def eval(x, env=global_env):
    """Evaluate an expression in an environment."""

    # Dispatch on structure of x
    if isinstance(x, Symbol):           # Variable reference
        return env[x]

    elif not isinstance(x, List):       # Constant literal
        return x

    elif x[0] == 'quote':               # (quote exp)
        (_, exp) = x
        return exp

    elif x[0] == 'if':                  # (if test conseq alt)
        (_, test, conseq, alt) = x
        exp = conseq if eval(test, env) else alt
        return eval(exp, env)

    elif x[0] == 'define':              # (define var exp)
        (_, var, exp) = x
        env[var] = eval(exp, env)

    elif x[0] == 'lambda':              # (lambda (var...) body)
        (_, parms, body) = x
        return Procedure(parms, body, env)

    else:                               # (proc arg...)
        proc = eval(x[0], env)
        args = [eval(exp, env) for exp in x[1:]]
        return proc(*args)

# Differentiation dispatch (Differentiation.ipynb)
def D(y, x):
    """Differentiate y with respect to x."""
    if y == x:
        return 1
    if not isinstance(y, Expression):
        return 0
    if len(y.args) == 1:          # Unary: sin, cos, etc.
        return D_unary(y, x)
    if len(y.args) == 2:          # Binary: +, *, etc.
        return D_binary(y, x)
    raise ValueError(f"Unknown arity: {y}")
```

## Key Principles
1. **Order matters**: Check specific cases before general
2. **Destructure inline**: `(_, test, conseq, alt) = x`
3. **isinstance for types**: Check type before accessing
4. **Sentinel values**: Check `x[0] == 'quote'` for tagged lists
5. **Fallback/error**: Handle unknown cases explicitly
