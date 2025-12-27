---
name: intern-symbols-identity
description: "For fast comparison: ensure only one instance of each symbol, use 'is' instead of '==', symbol tables for interpreters."
---

# intern-symbols-identity

## When to Use
- Building interpreters/compilers
- Need fast identity comparison (`is` vs `==`)
- Symbol tables
- Interned strings
- Singleton patterns for symbols

## When NOT to Use
- String comparison is fast enough
- Symbols are temporary/disposable
- No performance benefit

## The Pattern

Use a table to ensure each unique symbol exists only once.

```python
class Symbol(str):
    """A symbol is a unique string."""
    pass

def Sym(s, symbol_table={}):
    """Return the unique Symbol for string s."""
    if s not in symbol_table:
        symbol_table[s] = Symbol(s)
    return symbol_table[s]

# Now identity comparison works
quote = Sym('quote')
assert Sym('quote') is quote  # Same object!
assert Sym('quote') is Sym('quote')  # Always same object

# Fast dispatch with 'is'
if x[0] is quote:  # Faster than x[0] == 'quote'
    return handle_quote(x)
```

## Example (from pytudes lispy.py)

```python
class Symbol(str):
    """A Lisp Symbol is implemented as a Python str subclass."""
    pass

def Sym(s, symbol_table={}):
    """Find or create unique Symbol entry for str s in symbol table."""
    if s not in symbol_table:
        symbol_table[s] = Symbol(s)
    return symbol_table[s]

# Pre-intern common symbols
_quote, _if, _set, _define, _lambda, _begin, _definemacro = map(Sym,
    "quote   if   set!  define   lambda   begin   define-macro".split())

_quasiquote, _unquote, _unquotesplicing = map(Sym,
    "quasiquote   unquote   unquote-splicing".split())

# Fast dispatch in eval using 'is'
def eval(x, env=global_env):
    if isinstance(x, Symbol):
        return env.find(x)[x]
    elif not isinstance(x, list):
        return x
    elif x[0] is _quote:          # Fast identity check
        return x[1]
    elif x[0] is _if:             # Fast identity check
        (_, test, conseq, alt) = x
        return eval(conseq if eval(test, env) else alt, env)
    elif x[0] is _define:         # Fast identity check
        (_, var, exp) = x
        env[var] = eval(exp, env)
    # ... more special forms

# Note: Using 'is' instead of '==' because symbols are interned
```

## Key Principles
1. **Mutable default = singleton table**: `symbol_table={}` persists
2. **Subclass str**: Symbol inherits string methods
3. **Pre-intern keywords**: Common symbols created at module load
4. **Use `is` for dispatch**: Faster than string comparison
5. **Single source of symbols**: All symbols come from `Sym()`
