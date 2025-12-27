---
name: stack-based-backtrack
description: "For search with undo: explicit decision stack, backtracking when paths fail, depth-first exploration with state restoration."
---

# stack-based-backtrack

## When to Use
- DFS with backtracking
- Puzzle solving
- Game tree search
- Undo/redo functionality
- When recursion depth is too deep

## When NOT to Use
- Simple recursion works
- BFS needed (use queue)
- No backtracking required

## The Pattern

Maintain explicit stack of decisions; pop and undo on failure.

```python
def search_with_backtrack(initial_state):
    """DFS with explicit stack for backtracking."""
    stack = [(initial_state, get_choices(initial_state))]

    while stack:
        state, choices = stack[-1]

        if is_goal(state):
            return state

        if not choices:
            # Backtrack: no more choices at this level
            stack.pop()
            if stack:
                undo_last_choice(stack[-1][0])
            continue

        # Try next choice
        choice = choices.pop()
        new_state = apply_choice(state, choice)

        if is_valid(new_state):
            stack.append((new_state, get_choices(new_state)))

    return None  # No solution
```

## Example (from pytudes)

```python
# pal2.py - Panama palindrome search
class Panama:
    def search(self, steps=50000000):
        """Depth-first search with explicit backtrack stack."""
        for _ in range(steps):
            if not self.stack:
                return 'done'

            action, direction, substr, arg = self.stack[-1]

            if action == 'added':
                # Undo the addition
                self.remove(direction, arg)

            elif action == 'trying':
                if arg:  # More candidates to try
                    word = arg.pop()
                    self.add(direction, word)
                    self.consider_candidates()
                else:  # Exhausted candidates
                    self.stack.pop()

        return 'incomplete'

    def consider_candidates(self):
        """Push new choice points onto stack."""
        substr = self.get_target_substring()
        direction = 'left' if self.diff < 0 else 'right'

        candidates = self.find_candidates(substr, direction)
        if candidates:
            self.stack.append(('trying', direction, substr, candidates))

# Conceptual example: N-Queens
def solve_queens(n):
    """Place N queens with backtracking."""
    stack = [([], list(range(n)))]  # (placed, available_rows)

    while stack:
        placed, available = stack[-1]

        if len(placed) == n:
            return placed  # Solution found

        if not available:
            stack.pop()  # Backtrack
            continue

        row = available.pop()
        col = len(placed)

        if is_safe(placed, row, col):
            new_placed = placed + [row]
            new_available = [r for r in range(n)
                            if r not in new_placed and is_safe(new_placed, r, col+1)]
            stack.append((new_placed, new_available))

    return None
```

## Key Principles
1. **Stack = decision history**: Each entry is a choice point
2. **Pop to backtrack**: Remove failed branch
3. **Undo state changes**: Restore before backtracking
4. **Track remaining choices**: Know what's left to try
5. **Iterative, not recursive**: Avoids stack overflow
