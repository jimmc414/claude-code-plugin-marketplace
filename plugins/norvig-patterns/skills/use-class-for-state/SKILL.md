---
description: "For complex state: encapsulate multiple interacting variables, stateful algorithms, backtracking search state."
---

# use-class-for-state

## When to Use
- Multiple related state variables
- State needs to be copied/restored
- Complex state transitions
- Backtracking algorithms
- State machine implementations

## When NOT to Use
- Simple single value
- Stateless algorithm
- Closure is simpler

## The Pattern

Encapsulate state in a class with methods for transitions.

```python
class SearchState:
    def __init__(self, initial):
        self.position = initial
        self.visited = set()
        self.path = []
        self.cost = 0

    def copy(self):
        """Create copy for branching."""
        new = SearchState.__new__(SearchState)
        new.position = self.position
        new.visited = set(self.visited)
        new.path = list(self.path)
        new.cost = self.cost
        return new

    def move(self, direction):
        """Apply move, update state."""
        self.visited.add(self.position)
        self.position = self.position + direction
        self.path.append(direction)
        self.cost += 1
```

## Example (from pytudes)

```python
# pal2.py - palindrome search state
class Panama:
    """State for palindrome search."""

    def __init__(self, L='A man, a plan', R='a canal, Panama', dict=paldict):
        self.left = []        # Words added on left
        self.right = []       # Words added on right
        self.diff = 0         # Character difference
        self.stack = []       # Backtrack stack
        self.seen = {}        # Visited states
        self.starttime = time.process_time()
        self.dict = dict

    def add(self, direction, word):
        """Add word to one side."""
        if direction == 'left':
            self.left.append(word)
            self.diff += len(word)
        else:
            self.right.append(word)
            self.diff -= len(word)
        self.stack.append(('added', direction, None, word))
        return self

    def remove(self, direction, word):
        """Undo adding a word."""
        if direction == 'left':
            self.left.pop()
            self.diff -= len(word)
        else:
            self.right.pop()
            self.diff += len(word)

    def search(self, steps=50000000):
        """Depth-first search with backtracking."""
        for _ in range(steps):
            if not self.stack:
                return 'done'

            action, direction, substr, arg = self.stack[-1]

            if action == 'added':
                self.remove(direction, arg)
            elif action == 'trying':
                if arg:
                    word = arg.pop()
                    self.add(direction, word)
                    self.consider_candidates()
                else:
                    self.stack.pop()

        return 'incomplete'
```

## Key Principles
1. **Related state together**: All variables in one place
2. **copy method**: For branching in search
3. **Undo operations**: Reverse of each forward step
4. **Stack for backtracking**: Explicit decision history
5. **Methods for transitions**: Encapsulate state changes
