---
description: "For two-sided matching: hospital-resident, stable marriage, college admissions. Gale-Shapley algorithm for stable matching with preferences."
---

# match-stable-pairs

## When to Use
- Hospital-resident matching
- Stable marriage problem
- College admissions
- Job candidate matching
- Any two-sided market with preferences
- When you need a "stable" matching (no pair wants to switch)

## When NOT to Use
- One-sided assignment (use Hungarian algorithm)
- Weighted matching optimization (different problem)
- When preferences aren't strict orderings

## The Pattern

**Gale-Shapley Algorithm**: Proposers propose in preference order; acceptors tentatively accept best offer so far.

```python
def stable_matching(proposer_prefs, acceptor_prefs):
    """Find stable matching using Gale-Shapley algorithm.

    Returns dict mapping proposers to matched acceptors.
    Proposer-optimal: proposers get best partner possible.
    """
    n = len(proposer_prefs)

    # Track state
    unmatched = set(range(n))      # Unmatched proposers
    matched = {}                    # acceptor -> proposer
    proposals = [list(prefs) for prefs in proposer_prefs]  # Remaining preferences

    while unmatched:
        proposer = unmatched.pop()

        if not proposals[proposer]:
            continue  # Proposer exhausted all options

        acceptor = proposals[proposer].pop(0)  # Best remaining choice

        if acceptor not in matched:
            # Acceptor is free, tentatively accept
            matched[acceptor] = proposer
        elif acceptor_prefs[acceptor].index(proposer) < \
             acceptor_prefs[acceptor].index(matched[acceptor]):
            # Acceptor prefers new proposer
            unmatched.add(matched[acceptor])  # Old match becomes unmatched
            matched[acceptor] = proposer
        else:
            # Acceptor rejects, proposer tries again
            unmatched.add(proposer)

    return {p: a for a, p in matched.items()}
```

## Example (from pytudes StableMatching.ipynb)

```python
def stable_matching(P, A):
    """Stable matching with preference arrays.

    P[i][j] = proposer i's preference for acceptor j (lower = better)
    A[i][j] = acceptor i's preference for proposer j (lower = better)
    """
    n = len(P)
    ids = range(n)

    unmatched = set(ids)
    matched = {}  # acceptor -> proposer

    # Pre-sort: for each proposer, list acceptors by preference
    proposals = [sorted(ids, key=lambda a: P[p][a]) for p in ids]

    while unmatched:
        p = unmatched.pop()
        a = proposals[p].pop()  # Best remaining acceptor

        if a not in matched:
            matched[a] = p
        elif A[a][p] < A[a][matched[a]]:  # a prefers p to current
            unmatched.add(matched[a])
            matched[a] = p
        else:
            unmatched.add(p)  # Rejected, try again

    return {(p, a) for a, p in matched.items()}
```

## Key Principles
1. **Proposer advantage**: Algorithm is optimal for proposing side
2. **Tentative matching**: Acceptors can "trade up"
3. **Guaranteed stable**: No blocking pairs in result
4. **O(n^2) time**: Each proposer proposes to each acceptor at most once
5. **Pre-sort preferences**: Makes lookup O(1) during matching
