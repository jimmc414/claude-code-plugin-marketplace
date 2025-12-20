---
description: "For ordered processing: A* search, Dijkstra, event simulation, task scheduling. Efficient min/max extraction with heap-based queue."
---

# build-priority-queue

## When to Use
- A* or Dijkstra pathfinding
- Event-driven simulation
- Task scheduling by priority
- Any "process best/smallest first" pattern
- Merging sorted streams
- Top-K problems

## When NOT to Use
- FIFO order (use deque)
- LIFO order (use list as stack)
- Need to update priorities frequently (use indexed heap)

## The Pattern

Use `heapq` for O(log n) push/pop of minimum element.

```python
import heapq

# Basic usage
heap = []
heapq.heappush(heap, 3)
heapq.heappush(heap, 1)
heapq.heappush(heap, 2)
heapq.heappop(heap)  # Returns 1 (minimum)

# With tuples for priority ordering
tasks = []
heapq.heappush(tasks, (priority, task_id, task_data))
_, _, task = heapq.heappop(tasks)

# heapify existing list
data = [3, 1, 4, 1, 5]
heapq.heapify(data)  # In-place, O(n)
```

## Example (from pytudes AdventUtils.ipynb)

```python
import heapq

class PriorityQueue:
    """A queue where the item with minimum key is always popped first."""

    def __init__(self, items=(), key=lambda x: x):
        self.key = key
        self.items = []  # Heap of (score, item) pairs
        for item in items:
            self.add(item)

    def add(self, item):
        """Add item to the queue."""
        pair = (self.key(item), item)
        heapq.heappush(self.items, pair)

    def pop(self):
        """Pop and return the item with minimum key."""
        return heapq.heappop(self.items)[1]

    def top(self):
        """Peek at minimum item without removing."""
        return self.items[0][1]

    def __len__(self):
        return len(self.items)

# Usage in A* search
def astar_search(problem, h):
    frontier = PriorityQueue([Node(problem.initial)],
                             key=lambda n: n.path_cost + h(n))

    while frontier:
        node = frontier.pop()
        if problem.is_goal(node.state):
            return node
        for child in expand(problem, node):
            frontier.add(child)

    return None
```

## Key Principles
1. **Heap property**: Parent <= children (for min-heap)
2. **Tuple ordering**: `(priority, tiebreaker, data)` for stable ordering
3. **heapify is O(n)**: Faster than n pushes for initial data
4. **No decrease-key**: Python heapq doesn't support it; add duplicates instead
5. **Wrap for clarity**: PriorityQueue class hides heap details
