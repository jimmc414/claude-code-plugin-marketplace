---
description: "For lightweight records: immutable data with named fields, hashable structures for sets/dicts, self-documenting tuple alternatives."
---

# use-namedtuple-record

## When to Use
- Need tuple-like efficiency with named access
- Data should be immutable
- Will use as dict keys or in sets
- Want self-documenting code
- Replacing anonymous tuples with meaning
- Coordinates, points, records

## When NOT to Use
- Need mutable fields (use dataclass)
- Need methods beyond basic access
- Complex initialization logic needed

## The Pattern

Use `namedtuple` for lightweight, immutable records with named fields.

```python
from collections import namedtuple

# Define the type
Point = namedtuple('Point', ['x', 'y'])
# Or: Point = namedtuple('Point', 'x y')

# Create instances
p = Point(3, 4)
p = Point(x=3, y=4)

# Access by name or index
p.x  # 3
p[0]  # 3

# Immutable and hashable
{p: 'origin'}  # Can be dict key
{p, q, r}  # Can be in set

# Tuple operations work
x, y = p  # Unpacking
```

## Example (from pytudes)

```python
from collections import namedtuple

# Geometry (Convex Hull.ipynb)
Point = namedtuple('Point', 'x y')

def turn(A, B, C):
    """Direction of turn A -> B -> C."""
    diff = (B.x - A.x) * (C.y - B.y) - (B.y - A.y) * (C.x - B.x)
    return 'right' if diff < 0 else 'left' if diff > 0 else 'straight'

# Much clearer than:
# diff = (B[0] - A[0]) * (C[1] - B[1]) - (B[1] - A[1]) * (C[0] - B[0])

# Game structures (Maze.ipynb)
Maze = namedtuple('Maze', 'width height edges')

maze = Maze(width=10, height=10, edges=set())
print(f"Maze is {maze.width}x{maze.height}")

# Complex data (AdventUtils.ipynb)
Node = namedtuple('Node', 'state parent action path_cost')

node = Node(state=(0,0), parent=None, action=None, path_cost=0)
child = Node(state=(1,0), parent=node, action='E', path_cost=1)
```

## Key Principles
1. **Immutable by design**: Can't accidentally modify
2. **Hashable**: Use in sets and as dict keys
3. **Memory efficient**: Same as tuple, smaller than dict
4. **Self-documenting**: `p.x` beats `p[0]`
5. **Tuple compatible**: Unpacking, indexing still work
