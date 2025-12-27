---
name: overload-operators-dsl
description: "For domain-specific languages: operator overloading, make Python look like math/domain notation, expression builders."
---

# overload-operators-dsl

## When to Use
- Mathematical DSL
- Query builders
- Expression builders
- Matrix operations
- Custom numeric types
- Making code look like domain notation

## When NOT to Use
- Would be confusing to readers
- Standard operators have meaning already
- Single-use code

## The Pattern

Implement `__add__`, `__mul__`, etc. to make operators build structure.

```python
class Vector:
    def __init__(self, *components):
        self.components = components

    def __add__(self, other):
        return Vector(*(a + b for a, b in zip(self.components, other.components)))

    def __mul__(self, scalar):
        return Vector(*(c * scalar for c in self.components))

    def __rmul__(self, scalar):
        return self * scalar  # Handle 2 * v

v = Vector(1, 2, 3)
w = Vector(4, 5, 6)
result = 2 * v + w  # Vector math with natural syntax
```

## Example (from pytudes Differentiation.ipynb)

```python
class Expression:
    """DSL for symbolic math."""
    def __init__(self, op, *args):
        self.op, self.args = op, args

    # Arithmetic operators build expressions
    def __add__(self, other):  return Expression('+', self, other)
    def __radd__(self, other): return Expression('+', other, self)
    def __sub__(self, other):  return Expression('-', self, other)
    def __rsub__(self, other): return Expression('-', other, self)
    def __mul__(self, other):  return Expression('*', self, other)
    def __rmul__(self, other): return Expression('*', other, self)
    def __truediv__(self, other): return Expression('/', self, other)
    def __pow__(self, other):  return Expression('**', self, other)
    def __neg__(self):         return Expression('-', self)

    # Equality and hashing for use in dicts
    def __eq__(self, other):
        return (isinstance(other, Expression) and
                self.op == other.op and self.args == other.args)

    def __hash__(self):
        return hash((self.op, self.args))

# Create symbols
x, y, z = Expression('x'), Expression('y'), Expression('z')

# Natural mathematical syntax
polynomial = 3*x**2 + 2*x + 1
derivative = D(polynomial, x)  # 6*x + 2

# Simplification table uses expressions as keys
simp_table = {
    sin(0): 0,
    cos(0): 1,
    ln(1): 0,
}
```

## Key Principles
1. **Implement `__r*__` methods**: Handle `2 + x` not just `x + 2`
2. **Return new instances**: Operators build structure, don't mutate
3. **Implement `__eq__` and `__hash__`**: For use in sets/dicts
4. **Readable `__repr__`**: Show expression structure clearly
5. **Match domain notation**: Math DSL looks like math
