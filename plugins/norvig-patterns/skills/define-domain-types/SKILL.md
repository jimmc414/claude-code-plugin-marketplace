---
name: define-domain-types
description: "For new modules: define type aliases as vocabulary, make code self-documenting, create domain-specific language feel."
---

# define-domain-types

## When to Use
- Starting a new module or problem domain
- Want code to read like prose
- Types would clarify function signatures
- Building a mini-DSL
- Complex nested types (list of tuples of...)

## When NOT to Use
- Simple scripts with obvious types
- Types would just add noise
- No domain-specific vocabulary needed

## The Pattern

Define type aliases at the top of your module to establish vocabulary.

```python
from typing import List, Dict, Set, Tuple, Optional

# Domain vocabulary
Point = Tuple[int, int]
Grid = Dict[Point, str]
Path = List[Point]
Score = float

# Now signatures are self-documenting
def find_path(grid: Grid, start: Point, goal: Point) -> Optional[Path]:
    ...

def calculate_score(path: Path) -> Score:
    ...
```

## Example (from pytudes)

```python
# Cryptarithmetic.ipynb - problem domain types
Formula = str        # "NUM + BER = PLAY"
Pformula = str       # Python formula: "NUM + BER == PLAY"
Solution = str       # "587 + 439 = 1026"

def solve(formula: Formula) -> Iterable[Solution]:
    ...

# Probability.ipynb - probability domain
Space = set          # Sample space of outcomes
Event = set          # Subset of sample space
Probability = float  # Value between 0 and 1

def P(event: Event, space: Space) -> Probability:
    ...

# TSP.ipynb - traveling salesman domain
City = complex       # Cities as points in complex plane
Cities = frozenset   # Set of cities
Tour = list          # Ordered visit sequence
Segment = list       # Part of a tour

def tour_length(tour: Tour) -> float:
    ...

def valid_tour(tour: Tour, cities: Cities) -> bool:
    ...

# Sudoku - constraint satisfaction domain
Digit = str          # '1' to '9'
Square = str         # 'A1' to 'I9'
Unit = List[Square]  # Row, column, or box
Grid = Dict[Square, str]  # Square -> possible digits

def eliminate(grid: Grid, square: Square, digit: Digit) -> Optional[Grid]:
    ...
```

## Key Principles
1. **Top of file**: Types as module header
2. **Simple names**: `City`, not `CityPointType`
3. **Comments for meaning**: What does this type represent?
4. **Signatures tell story**: `solve(formula) -> Solution`
5. **Gradual typing**: Add types where they help clarity
