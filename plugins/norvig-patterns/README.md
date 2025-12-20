# Norvig Patterns Plugin

**54 elegant coding patterns derived from Peter Norvig's pytudes repository**

This plugin guides Claude to write cleaner, more Pythonic code using proven patterns for algorithms, data structures, testing, and code structure.

## Overview

Peter Norvig's [pytudes](https://github.com/norvig/pytudes) repository is a collection of Python programs for perfecting programming skills. Over decades, Norvig has refined a set of coding patterns that embody clarity, elegance, and efficiency.

This plugin extracts these patterns into 54 discrete skills that Claude Code automatically applies when relevant to your task.

## Installation

```
/plugin install norvig-patterns@community-claude-plugins
```

## How It Works

Claude automatically matches your current task against skill descriptions. When a match is found, the relevant pattern guidance is loaded to inform the implementation.

**Example matches:**
- "Build a maze solver" → `solve-grid-maze`, `find-shortest-path`
- "Parse this messy input file" → `parse-extract-input`
- "This function is too long" → `refactor-decompose-function`
- "Need to memoize these calls" → `cache-recursive-calls`

## Skill Categories

### Problem-Solving (8 skills)
| Skill | When to Use |
|-------|-------------|
| `solve-grid-maze` | 2D coordinates, board games, tile maps, mazes |
| `find-shortest-path` | Pathfinding, route planning, graph traversal |
| `solve-constraint-puzzle` | Sudoku-like puzzles, scheduling, CSP |
| `count-combinations` | Probability, permutations, Monte Carlo |
| `optimize-local-search` | NP-hard problems, greedy + 2-opt |
| `generate-tree-structure` | Spanning trees, maze generation |
| `match-stable-pairs` | Two-sided matching with preferences |
| `find-convex-hull` | Geometric algorithms, outer boundary |

### Data Structures (6 skills)
| Skill | When to Use |
|-------|-------------|
| `use-sparse-set` | Large space with few active elements |
| `use-counter-frequency` | Counting, histograms, most common |
| `use-namedtuple-record` | Lightweight immutable records |
| `use-defaultdict-groups` | Grouping, adjacency lists |
| `precompute-relationships` | Static relationships computed once |
| `build-priority-queue` | A*, Dijkstra, event simulation |

### Algorithm Optimization (5 skills)
| Skill | When to Use |
|-------|-------------|
| `cache-recursive-calls` | Overlapping subproblems, memoization |
| `use-generator-lazy` | Large/infinite sequences |
| `compile-once-call-many` | Same expression evaluated in loop |
| `iterate-with-itertools` | Products, permutations, combinations |
| `propagate-then-search` | Constraint propagation before guessing |

### Code Structure (5 skills)
| Skill | When to Use |
|-------|-------------|
| `refactor-decompose-function` | Long functions, nested logic |
| `define-domain-types` | New modules, DSLs, clear vocabulary |
| `write-docstring-first` | Any function where clarity matters |
| `compose-small-helpers` | Complex behavior from simple parts |
| `use-comprehension-chain` | Transform and filter sequences |

### Functional Programming (5 skills)
| Skill | When to Use |
|-------|-------------|
| `pass-function-as-arg` | Generic algorithms, strategy pattern |
| `capture-state-closure` | Persistent state without globals |
| `use-lambda-inline` | Trivial one-liner callbacks |
| `apply-decorator-wrap` | Add behavior without modifying |
| `use-operator-module` | Operations as first-class values |

### Metaprogramming (5 skills)
| Skill | When to Use |
|-------|-------------|
| `build-expression-tree` | Symbolic computation, math DSL |
| `dispatch-on-structure` | Pattern-match on expression types |
| `overload-operators-dsl` | Embed DSL with natural syntax |
| `use-table-driven-rules` | Many special cases as data |
| `intern-symbols-identity` | Fast identity checks with `is` |

### Parsing (4 skills)
| Skill | When to Use |
|-------|-------------|
| `parse-extract-input` | Extract data from messy text |
| `tokenize-then-parse` | Interpreters, structured text |
| `validate-before-process` | External input validation |
| `cascade-type-conversion` | Try int, then float, then string |

### Testing (5 skills)
| Skill | When to Use |
|-------|-------------|
| `verify-with-inline-tests` | Tests as documentation |
| `test-structural-invariants` | Properties that must hold |
| `verify-solution-properties` | Independent result verification |
| `benchmark-before-optimize` | Evidence for performance decisions |
| `test-with-examples` | Test cases as specification |

### Error Handling (4 skills)
| Skill | When to Use |
|-------|-------------|
| `handle-edge-cases` | Boundaries, empty, null, zero |
| `return-none-for-failure` | Graceful failure, caller checks |
| `catch-expected-errors` | Skip errors, don't crash |
| `fallback-compatibility` | Multiple versions, optional deps |

### Visualization (4 skills)
| Skill | When to Use |
|-------|-------------|
| `display-grid-state` | Debugging 2D algorithms |
| `format-statistics-table` | Tabular output for humans |
| `show-side-by-side` | Compare before/after states |
| `time-and-report` | Profiling, throughput reporting |

### State Machines (3 skills)
| Skill | When to Use |
|-------|-------------|
| `use-class-for-state` | Complex stateful algorithms |
| `stack-based-backtrack` | DFS with undo capability |
| `frontier-based-explore` | DFS/BFS/random via pop strategy |

## Core Principles

These principles from Norvig's code are always applicable:

1. **Functions should be 1-5 lines** - If longer, decompose
2. **Docstrings and code should match** - Iterate until isomorphic
3. **Define domain vocabulary as types** - Self-documenting code
4. **Prefer composition** - Small helpers that chain naturally
5. **Include inline tests** - Tests as documentation and examples

## Attribution

Patterns derived from [Peter Norvig's pytudes](https://github.com/norvig/pytudes) repository.

## License

MIT
