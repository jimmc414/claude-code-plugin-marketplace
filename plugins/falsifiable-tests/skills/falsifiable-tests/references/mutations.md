# Mutation catalogue

A mutation is a deliberate, minimal defect introduced into the code under test so you
can observe whether the test notices. This file is about choosing a good one.

## How to choose

The mutation must violate **the specific claim the test makes**, not just any claim.
A test named `test_rejects_expired_token` that goes red when you delete the whole
function has proved almost nothing — deleting the function breaks everything. The
interesting question is whether it goes red when expiry checking specifically stops
working.

Work backwards from the assertion:

1. Read what the test asserts. Write down the claim in one sentence.
2. Ask: what is the smallest change to the subject that makes that sentence false
   while leaving the rest of the code working?
3. That change is your mutation.

### When the test's name is itself the weak part

Sometimes the name promises so little that any mutation "respects" it. A test called
`test_apply_coupon_returns_a_value` really does only claim that something comes back,
so judged against its own name it passes honestly — and you can talk yourself into
calling it sound.

Don't stop there. Take the claim from the behaviour a reader would expect the test to
protect, which for a function named `apply_coupon` is that a discount gets applied.
Mutate that. If the test survives, the useful sentence for the user is not a taxonomy
label but the consequence: *the coupon discount can be deleted entirely and this suite
stays green*. Then note that the name is part of the defect, because it is what let
the gap hide in a suite that looks complete.

Two useful properties of a good mutation:

- **It is survivable.** The code still imports, still runs, still returns a value.
  A mutation that causes a crash tests only that the code path is reached, not that
  the assertion discriminates.
- **It is local.** One function, ideally one line. A broad mutation makes many tests
  red and tells you nothing about this one.

## Catalogue

Ordered roughly by how often they expose a vacuous test.

### Return-value mutations

- **Return a constant** — replace the body with `return 0` / `return ""` / `return []`.
  The blunt instrument; use when a test asserts on a computed value.
- **Return nothing** — `return None` / `return undefined` / delete the return. This is
  the single most valuable mutation, because "assert the function returned something
  vaguely truthy" is the most common weak assertion.
- **Return the input unchanged** — for transformers, formatters, sanitisers,
  normalisers. Catches tests that assert on the wrong end of the pipeline.
- **Return a plausible neighbour** — off by one, wrong unit (ms vs s), wrong sign,
  rounded differently, stale value. Catches tests that only assert on shape or type.

### Logic mutations

- **Invert a condition** — `if x` → `if not x`, `>` → `>=`, `==` → `!=`.
- **Swap a boundary** — `< limit` → `<= limit`. Exposes tests that never probe the edge.
- **Short-circuit a branch** — make an `if` always or never taken.
- **Change an operator** — `+` → `-`, `and` → `or`, `*` → `/`.

### Data and state mutations

- **Skip the write** — comment out the line that saves, persists, appends, emits or
  caches. Exposes tests that assert on the return value while claiming to test a side
  effect.
- **Skip the validation** — remove the guard that raises on bad input. This is the
  mutation for every "rejects invalid X" test.
- **Silently swallow the error** — wrap the raising line in a catch that returns a
  default. Exposes tests that assert "no exception" instead of asserting an outcome.
- **Use the wrong key/field** — read `user.email` where the code should read
  `user.username`. Exposes fixtures where every field happens to hold the same value.

### Ordering and timing mutations

- **Reverse an order** — sort descending instead of ascending, reverse a list.
- **Reorder two statements** — where sequence matters (lock then read, validate then
  write).
- **Drop the await/join** — remove an `await`, do not wait for the goroutine, do not
  flush. Exposes async tests that finish before the assertion is meaningful.

## Fixture-side mutations

Sometimes the honest mutation is not in the subject but in the input: feed the test
deliberately wrong data and confirm the expectation no longer holds. This is the right
move when:

- the subject is third-party or otherwise not editable
- the test is a data/contract/schema test, where the "code under test" *is* the data
- the test drives a pipeline end to end and there is no single line to break

Corrupt one field, remove one required key, change one type. The test must go red. If
it does not, the test is asserting on something other than what its name implies.

Be careful with the inverse trap: mutating the test's own expected value instead of the
input proves only that the comparison operator works. `assert result == 108` changed to
`assert result == 109` will go red on any implementation — that is not a proof of
anything.

## Equivalent mutants

A mutation can survive for a reason that has nothing to do with the test: the change
does not alter what the code returns for the inputs the test uses.

```python
def clamp(x, limit):
    return x if x < limit else limit     # mutate `<` to `<=`
```

For `clamp(5, 5)` both versions return 5. The test survives, and it is not vacuous —
the mutation was empty. This is called an *equivalent mutant*, and it is the main
source of false alarms in an audit, because a survived mutation looks exactly like a
vacuous test in every report, including the one `scripts/mutate.py` prints.

Before recording a test as vacuous, evaluate the mutated subject on the test's own
input, by hand or in a REPL, and confirm the result actually differs from the original.
If it does not, the finding is "this mutation was equivalent — chose a different one",
not "this test cannot fail". Boundary flips (`<` / `<=`) and ordering changes on tiny
inputs are the usual culprits.

## When no mutation works

Some tests genuinely cannot be falsified in place, and that is a finding, not a
failure of the method:

- **The test does not reach the code.** Over-mocking, wrong import path, dead fixture.
  Nothing you break in the real subject can affect it. This test is decorative — say so.
- **The subject is not editable.** Vendored, compiled, remote. Use a fixture-side
  mutation instead, or mark unverifiable and explain why.
- **Every mutation you can think of is equivalent.** The test's inputs never reach
  the behaviour the mutation targets. That is a finding about the test's *inputs* —
  it needs a case that exercises the boundary — rather than about its assertion.
- **The mutation breaks the world.** If the only way to violate the claim also breaks
  compilation or fifty other tests, note it, keep the smallest variant you managed,
  and report what the mutation did and did not isolate.

Record the outcome honestly in either case. "Could not falsify — the test mocks the
entire module under test" is a genuinely valuable line in a report.

## Restoring

Always restore from a known-good state rather than by retyping the original line from
memory. If the working tree is clean, `git diff` before restoring and `git diff` after
(expecting empty) is the cheapest possible check. If the repo is not under version
control, copy the file aside before mutating and restore from that copy.
