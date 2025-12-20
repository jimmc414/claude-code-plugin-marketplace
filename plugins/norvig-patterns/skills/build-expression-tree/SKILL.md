---
description: "For symbolic computation: ASTs, mathematical expressions, code that manipulates code structure, expression transformations."
---

# build-expression-tree

## When to Use
- Symbolic math (differentiation, simplification)
- Building ASTs for interpreters
- Query builders (SQL, API)
- Code generation
- Expression pattern matching

## When NOT to Use
- Just need to evaluate once (use direct computation)
- No transformation needed
- Structure too complex (use existing parser)

## The Pattern

Represent expressions as nested data structures (tuples, classes, or trees).

```python
# Tuple representation
expr = ('+', ('*', 'x', 2), 1)  # (x * 2) + 1

# Class representation
class Expr:
    def __init__(self, op, *args):
        self.op, self.args = op, args

    def __add__(self, other):
        return Expr('+', self, other)

    def __mul__(self, other):
        return Expr('*', self, other)

x = Expr('x')
expr = x * 2 + 1  # Builds expression tree

# Recursive evaluation
def evaluate(expr, env):
    if isinstance(expr, str):
        return env[expr]  # Variable lookup
    if isinstance(expr, (int, float)):
        return expr
    op, *args = expr if isinstance(expr, tuple) else (expr.op, *expr.args)
    values = [evaluate(a, env) for a in args]
    return {'+': lambda a,b: a+b, '*': lambda a,b: a*b}[op](*values)
```

## Example (from pytudes Differentiation.ipynb)

```python
class Expression:
    """A symbolic mathematical expression."""
    def __init__(self, op, *args):
        self.op, self.args = op, args

    def __add__(self, other):  return Expression('+', self, other)
    def __radd__(self, other): return Expression('+', other, self)
    def __mul__(self, other):  return Expression('*', self, other)
    def __rmul__(self, other): return Expression('*', other, self)
    def __neg__(self):         return Expression('-', self)

    def __repr__(self):
        if len(self.args) == 1:
            return f"({self.op}{self.args[0]})"
        return f"({self.args[0]} {self.op} {self.args[1]})"

class Function(Expression):
    """A function like sin or cos."""
    def __call__(self, x):
        return Expression(self, x)

# Create symbols and functions
x = Expression('x')
sin, cos = Function('sin'), Function('cos')

# Build expressions naturally
expr = sin(x) + cos(x) * 2
# Expression tree: (+ (sin x) (* (cos x) 2))

# Symbolic differentiation
def D(y, x=x):
    """Differentiate y with respect to x."""
    if y == x: return 1
    if not isinstance(y, Expression): return 0
    op, args = y.op, y.args
    if op == '+': return D(args[0], x) + D(args[1], x)
    if op == '*': return D(args[0], x) * args[1] + args[0] * D(args[1], x)
    if op == sin: return cos(args[0]) * D(args[0], x)
    # ... more rules
```

## Key Principles
1. **Operator overloading**: Natural syntax for building trees
2. **radd/rmul for commutativity**: Handle `2 + x` not just `x + 2`
3. **Recursive processing**: Walk tree to evaluate/transform
4. **Pattern matching on op**: Different behavior per operation
5. **Simplification rules**: Reduce `0 + x` to `x`, etc.
