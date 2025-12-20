---
description: "For performance reporting: timing wrappers, throughput calculations, profiling summaries."
---

# time-and-report

## When to Use
- Benchmarking algorithms
- Tracking performance
- Comparing implementations
- Progress reporting

## When NOT to Use
- Timing not meaningful
- Would slow down hot paths
- Single quick operations

## The Pattern

Wrap execution with timing, report statistics.

```python
import time

def timed(func):
    """Decorator to time function calls."""
    def wrapper(*args, **kwargs):
        start = time.process_time()
        result = func(*args, **kwargs)
        elapsed = time.process_time() - start
        print(f"{func.__name__}: {elapsed:.3f}s")
        return result
    return wrapper

def time_many(func, inputs, name=""):
    """Time function on multiple inputs, report statistics."""
    times = []
    for inp in inputs:
        start = time.process_time()
        func(inp)
        times.append(time.process_time() - start)

    print(f"{name}: n={len(times)}, "
          f"avg={sum(times)/len(times):.4f}s, "
          f"max={max(times):.4f}s, "
          f"rate={len(times)/sum(times):.0f}/s")
```

## Example (from pytudes)

```python
# sudoku.py - comprehensive timing
import time

def time_solve(grid):
    """Time solving a single grid."""
    start = time.process_time()
    values = solve(grid)
    t = time.process_time() - start
    return (t, solved(values))

def solve_all(grids, name=''):
    """Solve grids and report timing statistics."""
    times, results = zip(*[time_solve(grid) for grid in grids])
    N = len(results)
    if N > 1:
        print("Solved %d of %d %s puzzles "
              "(avg %.2f secs (%d Hz), max %.2f secs)." % (
            sum(results), N, name,
            sum(times)/N, N/sum(times), max(times)))

# Usage
if __name__ == '__main__':
    test()
    solve_all(open("sudoku-easy50.txt"), "easy")
    solve_all(open("sudoku-top95.txt"), "hard")
    solve_all(open("sudoku-hardest.txt"), "hardest")

# Output:
# Solved 50 of 50 easy puzzles (avg 0.01 secs (141 Hz), max 0.02 secs).
# Solved 95 of 95 hard puzzles (avg 0.03 secs (30 Hz), max 0.19 secs).
# Solved 11 of 11 hardest puzzles (avg 0.01 secs (100 Hz), max 0.02 secs).

# spell.py - throughput
def spelltest(tests, verbose=False):
    import time
    start = time.process_time()
    good = sum(correction(wrong) == right for right, wrong in tests)
    dt = time.process_time() - start
    n = len(tests)
    print(f'{good/n:.0%} of {n} correct at {n/dt:.0f} words per second')
```

## Key Principles
1. **process_time for CPU**: More stable than wall clock
2. **Report rate and time**: Hz and seconds both useful
3. **Summary statistics**: Average, max, total
4. **Count successes**: Track pass rate alongside speed
5. **Meaningful units**: "puzzles/sec" not "iterations"
