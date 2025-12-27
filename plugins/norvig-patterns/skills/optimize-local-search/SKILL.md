---
name: optimize-local-search
description: "For NP-hard optimization: TSP, scheduling, assignment problems. Uses greedy construction + local improvement (2-opt, hill climbing)."
---

# optimize-local-search

## When to Use
- Traveling Salesman Problem (TSP)
- Vehicle routing
- Job shop scheduling
- Facility location
- Any NP-hard optimization where "good enough" is acceptable
- When exact solution is too slow

## When NOT to Use
- Problems with polynomial-time exact algorithms
- When optimal solution is required (use exact methods)
- Very small instances (brute force is fine)

## The Pattern

**Greedy + Local Search**: Build initial solution fast, then improve iteratively.

```python
def optimize(initial_solution, neighbors, score, max_iterations=10000):
    """Hill climbing: repeatedly move to better neighbor."""
    current = initial_solution
    current_score = score(current)

    for _ in range(max_iterations):
        improved = False
        for neighbor in neighbors(current):
            neighbor_score = score(neighbor)
            if neighbor_score > current_score:
                current, current_score = neighbor, neighbor_score
                improved = True
                break
        if not improved:
            break  # Local optimum reached

    return current
```

## Example (from pytudes TSP.ipynb)

```python
def two_opt(tour):
    """Improve tour by reversing segments that reduce total distance."""
    tour = list(tour)
    improved = True

    while improved:
        improved = False
        for i in range(1, len(tour) - 2):
            for j in range(i + 2, len(tour)):
                if j == len(tour) - 1 and i == 1:
                    continue  # Skip if reversing whole tour

                # Check if reversing tour[i:j] improves distance
                A, B, C, D = tour[i-1], tour[i], tour[j-1], tour[j % len(tour)]
                if distance(A, B) + distance(C, D) > distance(A, C) + distance(B, D):
                    tour[i:j] = reversed(tour[i:j])
                    improved = True

    return tour

def nearest_neighbor_tsp(cities):
    """Greedy: always go to nearest unvisited city."""
    start = cities[0]
    tour = [start]
    unvisited = set(cities) - {start}

    while unvisited:
        nearest = min(unvisited, key=lambda c: distance(tour[-1], c))
        tour.append(nearest)
        unvisited.remove(nearest)

    return tour

# Combine: greedy construction + local improvement
def solve_tsp(cities):
    initial = nearest_neighbor_tsp(cities)
    return two_opt(initial)
```

## Key Principles
1. **Start greedy**: Quick initial solution (nearest neighbor, etc.)
2. **Define neighborhood**: What's a "small change" to current solution?
3. **2-opt for TSP**: Reverse segments to uncross edges
4. **First improvement**: Take first better neighbor (faster than best)
5. **Multiple restarts**: Run from different starting points, keep best
