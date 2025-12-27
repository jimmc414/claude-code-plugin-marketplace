---
name: generate-tree-structure
description: "For tree/maze generation: spanning trees, random mazes, graph coverage. Uses frontier-based exploration with configurable traversal order."
---

# generate-tree-structure

## When to Use
- Generating random mazes
- Building spanning trees
- Covering all nodes exactly once
- Procedural generation of connected structures
- When you need different tree "styles" (twisted vs. branchy)

## When NOT to Use
- When you need a specific tree structure (build directly)
- Shortest path trees (use BFS/Dijkstra)
- When cycles are needed (not a tree)

## The Pattern

Use frontier-based exploration where the **pop strategy** determines tree shape.

```python
from collections import deque
import random

def random_tree(nodes, neighbors, pop=deque.pop):
    """Build spanning tree by frontier exploration.

    pop strategy determines tree shape:
    - deque.pop (DFS): long winding paths
    - deque.popleft (BFS): short bushy branches
    - random.choice: random structure
    """
    tree = set()
    nodes = set(nodes)
    root = nodes.pop()
    frontier = deque([root])

    while nodes:
        # Pop from frontier according to strategy
        current = pop(frontier)

        # Find unvisited neighbors
        unvisited = [n for n in neighbors(current) if n in nodes]

        if unvisited:
            # Pick random neighbor, add edge
            chosen = random.choice(unvisited)
            tree.add((current, chosen))
            nodes.remove(chosen)

            # Add both back to frontier
            frontier.append(current)
            frontier.append(chosen)

    return tree
```

## Example (from pytudes Maze.ipynb)

```python
from collections import deque
import random

def make_maze(width, height):
    """Generate a random maze using DFS-based tree generation."""

    def neighbors(cell):
        x, y = cell
        candidates = [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]
        return [(nx, ny) for nx, ny in candidates
                if 0 <= nx < width and 0 <= ny < height]

    all_cells = {(x, y) for x in range(width) for y in range(height)}

    # DFS creates long winding passages
    edges = random_tree(all_cells, neighbors, pop=deque.pop)

    return Maze(width, height, edges)

def solve_maze(maze, start, goal):
    """BFS to find shortest path through maze."""
    frontier = deque([(start, [start])])
    visited = {start}

    while frontier:
        current, path = frontier.popleft()
        if current == goal:
            return path

        for neighbor in maze.neighbors(current):
            if neighbor not in visited:
                visited.add(neighbor)
                frontier.append((neighbor, path + [neighbor]))

    return None
```

## Key Principles
1. **Frontier controls shape**: DFS=winding, BFS=bushy, random=mixed
2. **Remove from node set**: Prevents revisiting
3. **Add both nodes back**: Current might have more unvisited neighbors
4. **Tree = set of edges**: Natural representation
5. **Same pattern, different results**: Just change the pop function
