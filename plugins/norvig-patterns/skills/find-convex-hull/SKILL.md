---
description: "For computational geometry: convex hull, point enclosure, polygon operations. Uses monotone chain algorithm with stack-based turn detection."
---

# find-convex-hull

## When to Use
- Finding convex hull of point set
- Determining if point is inside polygon
- Computational geometry problems
- Collision detection bounds
- Geographic/map computations

## When NOT to Use
- When hull is given (just use it)
- Very few points (< 5, just check manually)
- When you need concave hull

## The Pattern

**Monotone Chain Algorithm**: Sort points, build upper and lower hulls separately using stack.

```python
def convex_hull(points):
    """Find convex hull using monotone chain algorithm. O(n log n)."""
    points = sorted(set(points))  # Sort by x, then y

    if len(points) <= 3:
        return points

    # Build upper hull
    upper = []
    for p in points:
        while len(upper) >= 2 and turn(upper[-2], upper[-1], p) != 'left':
            upper.pop()
        upper.append(p)

    # Build lower hull
    lower = []
    for p in reversed(points):
        while len(lower) >= 2 and turn(lower[-2], lower[-1], p) != 'left':
            lower.pop()
        lower.append(p)

    return upper[:-1] + lower[:-1]  # Remove duplicate endpoints

def turn(A, B, C):
    """Determine turn direction A -> B -> C using cross product."""
    cross = (B[0] - A[0]) * (C[1] - B[1]) - (B[1] - A[1]) * (C[0] - B[0])
    if cross > 0:
        return 'left'
    elif cross < 0:
        return 'right'
    else:
        return 'straight'
```

## Example (from pytudes Convex Hull.ipynb)

```python
from collections import namedtuple

Point = namedtuple('Point', 'x y')

def turn(A, B, C):
    """Cross product determines turn direction."""
    diff = (B.x - A.x) * (C.y - B.y) - (B.y - A.y) * (C.x - B.x)
    return 'right' if diff < 0 else 'left' if diff > 0 else 'straight'

def half_hull(sorted_points):
    """Build one half of the hull."""
    hull = []
    for C in sorted_points:
        # Pop points that don't make left turn
        while len(hull) >= 2 and turn(hull[-2], hull[-1], C) != 'left':
            hull.pop()
        hull.append(C)
    return hull

def convex_hull(points):
    """Complete convex hull from two half-hulls."""
    if len(points) <= 3:
        return list(points)

    sorted_pts = sorted(points)
    upper = half_hull(sorted_pts)
    lower = half_hull(reversed(sorted_pts))

    return upper + lower[1:-1]  # Avoid duplicate endpoints

# Usage
points = [Point(0, 0), Point(1, 1), Point(2, 0), Point(1, 2), Point(0.5, 0.5)]
hull = convex_hull(points)
# Returns: [Point(0, 0), Point(2, 0), Point(1, 2)]
```

## Key Principles
1. **Sort first**: O(n log n) sorting dominates
2. **Stack-based**: Pop non-left-turning points
3. **Cross product**: Positive = left turn, negative = right turn
4. **Two passes**: Upper hull left-to-right, lower hull right-to-left
5. **Named tuples**: Make geometry code readable with .x and .y
