---
description: "For functional operations: named functions for operators, cleaner than lambdas for arithmetic, building interpreter environments."
---

# use-operator-module

## When to Use
- Building interpreters or expression evaluators
- Dict mapping symbols to operations
- Reduce with arithmetic operations
- Cleaner than `lambda a, b: a + b`
- Functional programming with operators

## When NOT to Use
- Simple inline expression is clearer
- Not doing functional programming
- Custom operator behavior needed

## The Pattern

Use `operator` module for named function versions of operators.

```python
import operator as op

# Instead of lambdas
add = op.add        # lambda a, b: a + b
mul = op.mul        # lambda a, b: a * b
neg = op.neg        # lambda x: -x
getitem = op.getitem  # lambda obj, key: obj[key]

# Reduce with operators
from functools import reduce
product = reduce(op.mul, [1, 2, 3, 4])  # 24
total = reduce(op.add, numbers)

# Comparison operators
op.lt(3, 5)  # True (3 < 5)
op.eq(3, 3)  # True (3 == 3)

# Attribute access
op.attrgetter('name')  # lambda obj: obj.name
op.itemgetter(0)       # lambda x: x[0]
```

## Example (from pytudes)

```python
# Lisp interpreter (lis.py)
import operator as op

env = {
    '+': op.add,
    '-': op.sub,
    '*': op.mul,
    '/': op.truediv,
    '>': op.gt,
    '<': op.lt,
    '>=': op.ge,
    '<=': op.le,
    '=': op.eq,
    'equal?': op.eq,
    'eq?': op.is_,
    'not': op.not_,
}

# Cleaner than:
# '+': lambda a, b: a + b,

# Extended Lisp interpreter (lispy.py)
import math

def add_globals(env):
    env.update(vars(math))  # sin, cos, sqrt, pi, ...
    env.update({
        '+': op.add, '-': op.sub, '*': op.mul, '/': op.truediv,
        '>': op.gt, '<': op.lt, '>=': op.ge, '<=': op.le, '=': op.eq,
        'not': op.not_,
        'cons': lambda x, y: [x] + y,
        'car': lambda x: x[0],
        'cdr': lambda x: x[1:],
    })
    return env

# Product function (AdventUtils.ipynb)
def prod(numbers):
    """Product of numbers."""
    return reduce(op.mul, numbers, 1)
```

## Key Principles
1. **Named is clearer**: `op.add` beats `lambda a,b: a+b`
2. **Works with reduce**: Standard pattern for aggregation
3. **Attrgetter/itemgetter**: Create key functions for sorting
4. **methodcaller**: `op.methodcaller('strip')` for method calls
5. **Consistent interface**: All binary operators have same signature
