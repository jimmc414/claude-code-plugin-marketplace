---
description: "For graph exploration: frontier collection with configurable pop order, BFS/DFS/random via strategy change."
---

# frontier-based-explore

## When to Use
- Graph/tree traversal
- When traversal order matters
- Want to switch between DFS/BFS easily
- Maze generation
- Coverage algorithms

## When NOT to Use
- Simple recursion suffices
- Fixed traversal order
- No exploration needed

## The Pattern

Maintain a frontier collection; how you pop determines traversal order.

```python
from collections import deque

def explore(start, neighbors, pop_strategy=deque.pop):
    """Explore graph with configurable traversal order.

    pop_strategy:
      deque.pop     -> DFS (depth-first, LIFO)
      deque.popleft -> BFS (breadth-first, FIFO)
      lambda d: d.pop(random.randrange(len(d))) -> Random
    """
    visited = set()
    frontier = deque([start])

    while frontier:
        current = pop_strategy(frontier)

        if current in visited:
            continue
        visited.add(current)

        yield current  # Process node

        for neighbor in neighbors(current):
            if neighbor not in visited:
                frontier.append(neighbor)
```

## Example (from pytudes Maze.ipynb)

```python
from collections import deque
import random

def random_tree(nodes, neighbors, pop=deque.pop):
    """Build spanning tree with configurable exploration.

    Different pop strategies create different tree shapes:
    - deque.pop (DFS): long winding paths
    - deque.popleft (BFS): short bushy branches
    - random pop: mixed/natural looking
    """
    tree = set()
    nodes = set(nodes)
    root = nodes.pop()
    frontier = deque([root])

    while nodes:
        current = pop(frontier)
        unvisited = [n for n in neighbors(current) if n in nodes]

        if unvisited:
            chosen = random.choice(unvisited)
            tree.add((current, chosen))
            nodes.remove(chosen)
            frontier.append(current)
            frontier.append(chosen)

    return tree

# Generate different maze styles
def dfs_maze(width, height):
    """Long, winding corridors."""
    return random_tree(all_cells(width, height), grid_neighbors, deque.pop)

def bfs_maze(width, height):
    """Short, branching paths."""
    return random_tree(all_cells(width, height), grid_neighbors, deque.popleft)

def random_maze(width, height):
    """Natural-looking structure."""
    def random_pop(d):
        i = random.randrange(len(d))
        d[i], d[-1] = d[-1], d[i]
        return d.pop()
    return random_tree(all_cells(width, height), grid_neighbors, random_pop)
```

## Key Principles
1. **Frontier abstraction**: deque supports both ends
2. **Pop strategy = behavior**: Same code, different traversals
3. **Yield for processing**: Generate results lazily
4. **Visited set**: Prevent cycles
5. **Strategy as parameter**: Inject behavior, don't hardcode
