# Auditing an existing test suite

Use this when asked to review, audit or "check whether these tests are actually testing
anything" — as opposed to proving a single test you just wrote.

The output of an audit is a written report file. The value of the report is that each
verdict carries its evidence, so a reader can disagree with a specific line rather than
having to trust the whole thing.

## 1. Scope and state it

Before touching anything, establish and say out loud:

- how many tests exist, and how many are in scope
- whether you will exhaust the scope or sample it, and by what rule
- whether the suite currently passes (audit a red suite and every result is confounded)

A suite of 40 tests can be exhausted. A suite of 2000 cannot, and pretending otherwise
produces a report that is mostly fiction. Sampling is fine; unstated sampling is not.

## 2. Confirm the suite runs and everything is collected

```bash
<test command>            # note the pass/fail/skip counts
```

Compare the number of tests *collected* against the number of test functions in the
files. A gap means tests are being filtered, skipped, or not collected at all — those
are findings before you mutate anything, because a test that never runs is the purest
possible false negative.

Count the skips explicitly. Skipped tests read as green in a summary line.

## 3. Triage by pattern

Grep for the shapes in `references/vacuous-patterns.md` to build a candidate list. This
is cheap and narrows where mutations get spent. Useful starting greps:

```bash
# tests with no assertion at all (approximate; review the hits)
grep -rLn "assert\|expect(" tests/ --include="*test*"

# truthiness assertions
grep -rn "assert [a-z_]*$\|toBeTruthy\|toBeDefined\|is not None" tests/

# over-broad exception expectations
grep -rn "raises(Exception)\|toThrow()\|assertThrows(Exception" tests/

# async without await
grep -rn "it(.*async\|test(.*async" -A3 tests/ | grep -n "expect(" | grep -v await

# skipped / disabled
grep -rn "@skip\|xfail\|it.skip\|describe.skip\|@Disabled\|#\[ignore\]" tests/
```

Grep produces suspects, never verdicts. Reading a test is not proof; the mutation is.

## 4. Prove, in priority order

Apply the four-step red proof from SKILL.md to each selected test. Order:

1. tests guarding money, auth, data loss, migrations, concurrency
2. grep suspects from step 3
3. a random sample of the rest, so the report says something about the suite as a whole
   and not only about its worst-looking parts

The random sample matters. If you only mutate suspicious tests, the report describes
the suspects, not the suite — and the reassuring finding ("the sampled ordinary tests
all discriminated") is exactly what the user needs to know.

`scripts/mutate.py` classifies each mutation as caught, survived, or "broke the
plumbing" (errors and tests that vanished from the report). Only the first is
evidence. Survived needs the equivalent-mutant check before it becomes a finding;
plumbing means shrink the mutation and rerun.

Batch efficiently: one mutation can prove several tests at once when they cover the
same behaviour. Note which tests went red and which stayed green under that mutation —
a test that stays green while its siblings go red is the interesting one.

## 5. Assign a verdict

Every test examined gets exactly one:

| Verdict | Meaning |
|---|---|
| **Verified** | Went red under a targeted mutation, on the assertion, for the right reason. Restored green. |
| **Vacuous** | Stayed green under a mutation that violates its stated claim *and* that demonstrably changes the output for the test's input (i.e. not an equivalent mutant — see `mutations.md`). It cannot detect what its name says it detects. |
| **Weak** | Went red, but only under a blunt mutation; survives the targeted one. Detects catastrophe, not regression. |
| **Flaky** | Result changed between identical runs, or between alone and in-suite. |
| **Unverifiable** | No mutation could isolate it — subject not editable, test does not reach the code, environment cannot run it. Explain which. |
| **Not run** | Skipped, filtered, or never collected. |

"Weak" is worth keeping separate from "vacuous". A test that only fails when you delete
the whole function is not useless, but it will not catch the off-by-one that actually
ships.

## 6. Report

Write to `test-audit-<YYYY-MM-DD>.md` in the repo root, or wherever the user keeps
reports. Template:

```markdown
# Test audit — <project> — <date>

## Scope
- Tests in suite: N (M collected, K skipped)
- Examined: X (selection: <exhaustive | critical paths + grep suspects + random sample of R>)
- Suite state at audit time: <green | red — which tests>

## Summary
| Verdict | Count |
|---|---|
| Verified | |
| Weak | |
| Vacuous | |
| Flaky | |
| Unverifiable | |
| Not run | |

## Findings

### Vacuous
| Test | Claim | Mutation applied | Result |
|---|---|---|---|
| `tests/test_orders.py::test_applies_discount` | discount reduces the total | `apply_discount` returns subtotal unchanged | still passed — asserts only `result is not None` |

### Weak
<same shape: which mutation it survived>

### Flaky
<test, what varied, evidence: alone vs suite, run 1 vs run 2>

### Unverifiable / Not run
<test, why>

### Verified
<list; one line each with the mutation used>

## Recommended fixes
Ordered by risk. For each vacuous test, the specific assertion change needed —
not "improve the test".

## Coverage gaps noticed
Behaviours with no test at all, spotted while reading. Separate from the audit
proper, because absence of a test is a different problem from a test that lies.
```

## 7. Offer the fixes, do not assume them

An audit finds problems; fixing them is a separate decision the user makes. Present the
report first. If the user wants the fixes applied, each repaired test then needs its own
red proof — a fixed test is a new test and inherits no credibility from the old one.

## Honesty constraints

- Never list a test as Verified without having run the mutation and seen the red.
- If time or budget ran out, say how far you got and which tests were never examined.
  A partial audit clearly labelled is useful; a partial audit presented as complete is
  actively harmful, because it retires suspicion from tests nobody checked.
- If the suite was red when you started, say so — every verdict below it is provisional.
