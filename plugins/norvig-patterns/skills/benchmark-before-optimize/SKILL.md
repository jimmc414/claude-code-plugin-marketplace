---
name: benchmark-before-optimize
description: "For performance work: measure before changing, profile to find bottlenecks, compare before and after."
---

# benchmark-before-optimize

## When to Use
- Before attempting optimization
- Comparing algorithm implementations
- Finding bottlenecks
- Validating performance improvements

## When NOT to Use
- Obvious micro-optimizations
- Code that runs once
- When correctness is more important

## The Pattern

Measure performance with timing and profiling before making changes.

```python
import time

def time_it(func, *args, **kwargs):
    """Time a single function call."""
    start = time.process_time()
    result = func(*args, **kwargs)
    elapsed = time.process_time() - start
    return result, elapsed

def benchmark(func, inputs, name=""):
    """Benchmark function on multiple inputs."""
    times = []
    for inp in inputs:
        _, elapsed = time_it(func, inp)
        times.append(elapsed)

    print(f"{name}: avg={sum(times)/len(times):.4f}s, "
          f"max={max(times):.4f}s, "
          f"total={sum(times):.4f}s")
```

## Example (from pytudes)

```python
# sudoku.py - comprehensive benchmarking
import time

def time_solve(grid):
    """Time how long it takes to solve a grid."""
    start = time.process_time()
    values = solve(grid)
    t = time.process_time() - start
    return (t, solved(values))

def solve_all(grids, name=''):
    """Attempt to solve grids and report statistics."""
    times, results = zip(*[time_solve(grid) for grid in grids])
    N = len(results)
    if N > 1:
        print("Solved %d of %d %s puzzles "
              "(avg %.2f secs (%d Hz), max %.2f secs)." % (
            sum(results), N, name,
            sum(times)/N, N/sum(times), max(times)))

if __name__ == '__main__':
    solve_all(open("sudoku-easy50.txt"), "easy")
    solve_all(open("sudoku-top95.txt"), "hard")
    solve_all(open("sudoku-hardest.txt"), "hardest")

# spell.py - throughput measurement
def spelltest(tests, verbose=False):
    """Run correction on all (right, wrong) pairs; report results."""
    import time
    start = time.process_time()
    good, unknown = 0, 0
    n = len(tests)

    for right, wrong in tests:
        w = correction(wrong)
        good += (w == right)
        if w != right:
            unknown += (right not in WORDS)

    dt = time.process_time() - start
    print('{:.0%} of {} correct ({:.0%} unknown) at {:.0f} words per second'
          .format(good / n, n, unknown / n, n / dt))

# Cryptarithmetic.ipynb - profiling with %prun
%prun first(solve('NUM + BER = PLAY'))
# Output shows where time is spent:
#    ncalls  tottime  percall  cumtime  filename:lineno(function)
#    309270    1.779    0.000    1.833  {built-in method builtins.eval}
```

## Key Principles
1. **Measure first**: Don't optimize without data
2. **Use process_time**: CPU time, not wall clock
3. **Multiple samples**: Average over many runs
4. **Report Hz**: "puzzles per second" is intuitive
5. **Profile for bottlenecks**: `%prun` or `cProfile` to find hot spots
