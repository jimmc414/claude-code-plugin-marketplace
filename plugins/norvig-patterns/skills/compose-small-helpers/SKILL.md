---
name: compose-small-helpers
description: "For complex behavior: build from tiny functions, chain transformations, make code read like a pipeline of operations."
---

# compose-small-helpers

## When to Use
- Complex transformation with multiple steps
- Want code to read like a sentence
- Each step is useful independently
- Testing individual operations
- Functional programming style

## When NOT to Use
- Single simple operation
- Helpers would obscure rather than clarify
- Performance-critical inner loops (function call overhead)

## The Pattern

Build complex operations from tiny, single-purpose functions.

```python
# Instead of one complex function:
def process(text):
    words = text.lower().split()
    words = [w for w in words if len(w) > 2]
    words = [w for w in words if w not in stopwords]
    counts = {}
    for w in words:
        counts[w] = counts.get(w, 0) + 1
    return sorted(counts.items(), key=lambda x: -x[1])[:10]

# Compose small helpers:
def process(text):
    return top_n(10, count(remove_stopwords(filter_short(tokenize(text)))))

def tokenize(text):
    return text.lower().split()

def filter_short(words, min_len=3):
    return [w for w in words if len(w) >= min_len]

def remove_stopwords(words):
    return [w for w in words if w not in STOPWORDS]

def count(items):
    from collections import Counter
    return Counter(items)

def top_n(n, counter):
    return counter.most_common(n)
```

## Example (from pytudes)

```python
# Spell correction (spell.py)
def correction(word):
    return max(candidates(word), key=P)

def candidates(word):
    return known([word]) or known(edits1(word)) or known(edits2(word)) or [word]

def known(words):
    return set(w for w in words if w in WORDS)

def P(word, N=sum(WORDS.values())):
    return WORDS[word] / N

# Each function is tiny but composable!

# Rainfall problem (DocstringFixpoint.ipynb)
def rainfall(numbers):
    return mean(non_negative(upto(-999, numbers)))

# Sudoku (sudoku.py)
def solve(grid):
    return search(parse_grid(grid))

# Lisp interpreter (lis.py)
def repl():
    while True:
        print(lispstr(eval(parse(input('> ')))))

# Each layer does one thing, composes naturally
```

## Key Principles
1. **Tiny functions**: 1-3 lines each
2. **Noun or verb names**: `tokenize`, `count`, `filter_short`
3. **Pure when possible**: Input -> output, no side effects
4. **Chain naturally**: Output of one fits input of next
5. **Read left-to-right or inside-out**: Like a pipeline
