---
name: pass-function-as-arg
description: "For generic algorithms: strategy pattern, callbacks, configurable behavior. Pass functions as parameters to customize algorithm behavior."
---

# pass-function-as-arg

## When to Use
- Algorithm should work with different implementations
- Strategy pattern: same algorithm, different strategies
- Callbacks for event handling
- Sorting/filtering with custom criteria
- Higher-order functions (map, filter, reduce)

## When NOT to Use
- Only one implementation needed
- Function parameter adds complexity without benefit
- Object-oriented approach is clearer

## The Pattern

Accept a function as a parameter to customize behavior.

```python
def generic_algorithm(data, key=lambda x: x, filter_fn=lambda x: True):
    """Process data with customizable key and filter."""
    filtered = [x for x in data if filter_fn(x)]
    return sorted(filtered, key=key)

# Use with different strategies
result1 = generic_algorithm(items, key=lambda x: x.priority)
result2 = generic_algorithm(items, key=lambda x: -x.size, filter_fn=lambda x: x.active)
```

## Example (from pytudes)

```python
# Hill climbing with configurable objective (ngrams.py)
def hillclimb(x, objective_fn, neighbors_fn, steps=10000):
    """Search for x that maximizes objective_fn, using neighbors_fn to explore."""
    best = x
    best_score = objective_fn(x)

    for _ in range(steps):
        for neighbor in neighbors_fn(best):
            score = neighbor_score = objective_fn(neighbor)
            if score > best_score:
                best, best_score = neighbor, score
                break

    return best

# Use with specific objective and neighbor functions
decoded = hillclimb(initial_guess,
                   objective_fn=log_probability,
                   neighbors_fn=swap_adjacent_chars)

# Priority queue with custom key (AdventUtils.ipynb)
class PriorityQueue:
    def __init__(self, items=(), key=lambda x: x):
        self.key = key
        self.items = []
        for item in items:
            self.add(item)

    def add(self, item):
        heapq.heappush(self.items, (self.key(item), item))

# A* search with custom heuristic
frontier = PriorityQueue(initial_nodes, key=lambda n: n.cost + h(n))

# Tree generation with configurable pop strategy (Maze.ipynb)
def random_tree(nodes, neighbors, pop=deque.pop):
    """Pop strategy determines tree shape."""
    ...
    current = pop(frontier)  # DFS, BFS, or random based on pop function
```

## Key Principles
1. **Functions are values**: Pass them like any other argument
2. **Default identity**: `key=lambda x: x` as sensible default
3. **Name the role**: `objective_fn`, `neighbors_fn`, `key`
4. **Keep signatures simple**: Callback should match expected interface
5. **Document expected signature**: What arguments, what return type?
