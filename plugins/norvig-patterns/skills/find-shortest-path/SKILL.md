---
name: find-shortest-path
description: "For pathfinding and search: shortest path, maze solving, game AI, route planning, graph traversal, BFS/DFS, Dijkstra, A* problems."
---

# find-shortest-path

## When to Use
- Finding shortest/optimal path between two points
- Maze solving
- Game AI movement
- Route planning and navigation
- Graph traversal (BFS, DFS, A*)
- State-space search problems
- Puzzle solving (15-puzzle, Rubik's cube)

## When NOT to Use
- Simple iteration over all nodes (just use a loop)
- When there's no clear goal state
- Infinite graphs without good heuristics

## The Pattern

Use A* search with a problem abstraction that separates:
- State representation
- Goal testing
- Action generation
- Cost function
- Heuristic (optional, for A*)

```python
from heapq import heappush, heappop

def astar_search(problem, h=lambda n: 0):
    """A* search: expand nodes with minimum f(n) = g(n) + h(n)."""
    start = problem.initial
    frontier = [(h(start), 0, start, [])]  # (f, g, state, path)
    reached = {start: 0}

    while frontier:
        f, g, state, path = heappop(frontier)

        if problem.is_goal(state):
            return path + [state]

        for action, next_state, cost in problem.actions(state):
            new_g = g + cost
            if next_state not in reached or new_g < reached[next_state]:
                reached[next_state] = new_g
                new_f = new_g + h(next_state)
                heappush(frontier, (new_f, new_g, next_state, path + [state]))

    return None  # No path found
```

## Example (from pytudes AdventUtils.ipynb)

```python
class GridProblem:
    """Find shortest path on a grid."""
    def __init__(self, grid, start, goal):
        self.grid, self.initial, self.goal = grid, start, goal

    def is_goal(self, state):
        return state == self.goal

    def actions(self, state):
        """Yield (action, next_state, cost) tuples."""
        for neighbor in self.grid.neighbors(state):
            yield (neighbor, neighbor, 1)

    def h(self, state):
        """Manhattan distance heuristic."""
        return abs(state[0] - self.goal[0]) + abs(state[1] - self.goal[1])

# Usage
problem = GridProblem(grid, start=(0, 0), goal=(10, 10))
path = astar_search(problem, h=problem.h)
```

## Key Principles
1. **Separate problem from algorithm**: Problem defines states/actions, algorithm searches
2. **Priority queue**: Always expand most promising node first
3. **Reached set**: Track best cost to each state to avoid cycles
4. **Heuristic must not overestimate**: h(n) <= actual cost for A* optimality
5. **MRV heuristic**: When branching, try most constrained option first
