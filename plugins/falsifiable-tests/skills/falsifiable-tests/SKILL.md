---
name: falsifiable-tests
description: Empirically prove a test can fail before trusting it — break the code under test, confirm the test turns red for the right reason, then restore. Use this whenever you write, modify, or review tests; whenever a suite goes green and you are about to tell the user something "works"; and whenever the user asks to audit tests, check test quality, or hunt for false negatives, flaky tests, vacuous assertions, or tests that pass no matter what. Trigger it even when the user only says "add a test" or "make the tests pass" — a test never observed failing is unverified, and this is what verifies it.
---

# Falsifiable Tests

A test that has never been seen to fail is not evidence. It is a claim about the code
that has itself never been tested.

Green means one of two things, and from the outside they look identical:

- the behaviour is correct, or
- the test cannot detect the behaviour being wrong.

The job of this skill is to tell those two apart empirically, by observation rather
than by reading the test and finding it convincing. Reading is how false negatives
survive — a vacuous test looks exactly like a real one, which is why it got written
in the first place.

## The core rule

**A test counts as verification only once it has been observed red for the right reason.**

Two failure modes matter, and they are not symmetric:

- **False negative** — the test passes while the behaviour is broken. This is the
  dangerous one. It converts "we have tests" into false confidence, and it is silent.
  Most of what follows is aimed here.
- **False positive** — the test fails while the behaviour is fine (flaky, environment-
  dependent, order-dependent). Loud and annoying, and it trains people to ignore red,
  which manufactures false negatives downstream.

## The red proof

Four steps, applied to the specific test you just wrote or are auditing — not to the
whole suite.

**1. Green.** Run the test against correct code. It passes — and the runner's count
line says it ran: `1 passed`, not `1 skipped`, `no tests ran` or `Tests run: 0`. A
filter that matches nothing reports success in every framework. This proves nothing
on its own; it is the baseline you will restore to.

**2. Break the subject.** Edit the defect into *the file the tests actually import* —
never into the test, and never into a copy. It must violate exactly the behaviour this
test claims to check: if the test says "returns `Y` for input `A`", make it return
something that is not `Y`. Keep the mutation small and targeted;
`references/mutations.md` catalogues mutations and how to choose one.

**3. Run it and read the failure.** The test must fail, and it must fail *because the
assertion about the behaviour did not hold*. This is where naive verification goes
wrong: a test that "fails" with an ImportError, a syntax error, a collection error or
a fixture crash proves nothing about the assertion — only that the file still gets
executed. Read the actual failure output and confirm it names the assertion and shows
the expected-vs-actual you care about.

**4. Restore and re-confirm green.** Undo the mutation — from `git checkout` or a
copy taken beforehand, never by retyping the line from memory — run again, confirm it
passes. This closes the loop and guarantees no broken code is left behind. Never skip
it, and never leave a mutation in the working tree — if you are interrupted mid-proof,
restoring is the first thing to do on resuming. When chaining several mutations, one
green run after the final restore is enough, provided every intermediate restore was
from a known-good copy.

If step 3 does not produce a red, one of two things is true, and you have to decide
which by reading: either the test is vacuous with respect to that behaviour, or the
mutation is an **equivalent mutant** — a change that has no observable effect for the
inputs the test uses (`<` → `<=` when the test never hits the boundary; reversing a
sort of one element). Check that the mutated code really does return something
different for the test's input before blaming the test. If it does, the test is
vacuous: fix it, then redo the proof from step 1. If it does not, pick a mutation that
actually changes the output.

### The shortcut that is not a proof

There is a tempting move that feels like the four steps and is not: writing a broken
*copy* of the function — in the shell, in a scratch file, inline in a `python -c` —
and checking that it returns something different from what you expected.

That establishes only that a different function computes different numbers. It cannot
establish anything about your tests, because **your tests never ran against it**. The
suite imported the real module, as it always does, and stayed green throughout. A
mutation the test suite cannot see is not a mutation; it is a thought experiment with
extra steps.

The same applies to reasoning it through in your head, however obvious the conclusion
looks. If the assertion would obviously fail, running it costs seconds and turns an
opinion into evidence. Every proof claimed in your reply must correspond to a suite
run that actually happened.

**Arithmetic that settles it:** proving N mutations requires at least N+2 runs of the
suite — one baseline, one per mutation, one green after the last restore. Before
writing "I verified these tests can fail", count the runs you actually performed. If
the count does not reach N+2, you did not verify N mutations, and saying so would be
the exact false confidence this skill exists to prevent. Report what you really ran,
or run the rest.

### Doing it mechanically

Past one or two mutations, drive the whole thing with the bundled harness instead of
by hand. It cannot take the shortcut above, because it edits the real file, runs your
real command, and restores from a hash-checked backup:

```bash
python3 <skill dir>/scripts/mutate.py --project . --spec mutations.json \
    --test-cmd "python3 -m pytest -q --junit-xml=report.xml" --junit report.xml
```

Add `--timeout SECONDS` when a mutation could turn a bounded loop into an unbounded one
(anything of the shape "retry until valid" whose valid path you are breaking) — a timed-out
run is reported separately, as neither caught nor survived, and the audit continues.

`<skill dir>` is the directory this SKILL.md lives in — as a Claude Code plugin that is
`${CLAUDE_PLUGIN_ROOT}/skills/falsifiable-tests`. The harness runs from any cwd; only
`--project` has to point at the code under test.

It reports which tests noticed each mutation, which tests noticed nothing (vacuity
candidates), which mutations nothing caught (defects that could ship, or equivalent
mutants — it cannot tell, you read), and which mutations only broke the plumbing
(errors and vanished tests, which it refuses to count as catches). It finishes with a
green run against the restored tree. Read the file's docstring for the spec format. Doing it by hand stays fine for a single
targeted proof — the harness is for when the count grows and bookkeeping starts to
slip.

### The three degenerate returns

Many false negatives come from assertions that are weaker than they look. Before
running the proof, check that the assertion pins the value rather than merely touching
it. All three of these must make the test fail:

- the subject returns **nothing** (`None`, `undefined`, `nil`, empty)
- the subject returns something of a **completely different shape** (a string where a
  number is expected, an empty list, an error object)
- the subject returns a **plausible but wrong** value (off by one, wrong sign, stale
  cached value)

`assert result` passes for `[0]`, `"error"`, `-1` and NaN. Truthiness is not an
assertion, it is a rumour. Assert the value.

When a test's whole point is the failure path — "given bad input, this must raise" —
the same discipline applies inverted: prove the test goes red when the subject *stops*
raising, and confirm it asserts on the specific error rather than merely that
*something* went wrong. A `raises`/`throws` block that swallows any exception will
happily pass on a typo in a code path it never reached.

## Cheapest proof first: write it red

When writing a new test, you get the red proof for free by writing the test *before*
the implementation or the fix, and watching it fail. That initial red **is** step 3 —
no mutation needed, and it is stronger evidence because nothing was tuned to it yet.

The same rule about *reasons* applies, though. If the subject does not exist yet, the
first red is an `ImportError` or `NameError`, and step 3 has already said what that is
worth: nothing. Put a stub in place — the function exists and returns `None` — so that
the red you observe is the assertion rejecting `None`. Only then is it a proof.

Retrofitting tests onto code that already works is where the mutation step becomes
mandatory, because there is no natural red anywhere in the process.

For a bug fix: write the test that reproduces the bug, watch it fail on the unfixed
code, then fix. If it does not fail on the unfixed code, the bug has not been
reproduced and the fix is aimed at a guess.

## When you were asked to make a red test pass

"Make the tests pass" is the trigger for the most common way vacuous tests get
manufactured, and it is not a mutation — it is editing the test until it stops
complaining. The rule:

- **The fix goes in the subject.** If the test is red because the behaviour is wrong,
  change the behaviour. Do not loosen the assertion, widen a `raises` to `Exception`,
  swap `==` for `is not None`, add a skip marker, or wrap the assertion in a `try`.
- **If the test itself is wrong, say so and fix it as a new test.** Sometimes the
  assertion really is mistaken. Changing it is legitimate, but the result is a new
  test with no track record — it needs its own red proof before it counts, exactly as
  if you had just written it.
- **Never special-case the test in the subject.** A branch that detects the test's
  input and returns the expected value makes the test green and the behaviour
  untested. This is a mutation in reverse, and the same four-step proof exposes it:
  break the general case and watch the test stay green.

Before reporting "the tests pass", check which file your diff touched. If it is the
test file and the user asked for the code to be fixed, you have not done what they
asked.

## What to say afterwards

Report the proof in a line or two, not a ceremony. State what you broke and what the
test did:

> Verified `test_discount_applies_to_subtotal`: made `apply_discount` return the
> subtotal unchanged → test failed on the amount assertion (`120.0 != 108.0`).
> Restored, green again.

Naming the mutation lets the user judge whether it was a real test of the behaviour or
a soft one. Hiding it hides the weakness.

**Never claim a proof you did not run.** If a test could not be made to fail — the code
is unreachable from the test, the environment cannot execute it, the mutation would
break unrelated tests — say so plainly and mark the test unverified. An honest
"unverified" is useful information; a fabricated verification is worse than none,
because it is exactly the false confidence this skill exists to prevent.

**If you cannot edit the subject, stop and report it.** Read-only checkouts, sandboxed
tools, restricted permissions — all are ordinary, and the answer is always the same:
mark the test unverified, say which mutation you would have applied, and let the user
decide. Never ask for broader write access in order to complete a proof. Verification
is not worth trading a known limitation for an unknown risk, and a permissions change
is the user's decision to make deliberately, not a step in your procedure. Where the
subject is genuinely off-limits, `references/mutations.md` covers mutating the input
instead, which often needs no extra access at all.

## Budget and prioritisation

Proving every test in a large suite is not free, and blanket mutation of a 2000-test
suite is rarely the right call. Spend the effort where a false negative would hurt:

1. Tests you just wrote or modified — always. This is the non-negotiable case.
2. Tests guarding money, auth, data loss, migrations, concurrency, or anything the
   user called critical.
3. Tests matching the patterns in `references/vacuous-patterns.md` — suspicious on
   sight and cheap to disprove.
4. Everything else — only when auditing, and say up front how much was sampled.

When sampling rather than exhausting, state the sample size and the selection rule so
the result is not mistaken for a full sweep.

## Flakiness: the other half

A test that fails sometimes is not a stricter test, it is a broken instrument. After
the red proof, for anything touching time, randomness, network, filesystem order,
concurrency or shared state:

- run it twice in a row — same result both times?
- run it **alone**, then inside the full suite — same result both ways? A test that
  only passes in suite order depends on another test's leftovers; one that only passes
  alone is leaking state.

Both directions are bugs in the test. Fix by pinning the source of variance (seed the
RNG, freeze the clock, isolate the fixture) rather than by adding retries or sleeps —
retries convert a visible flake into an invisible false negative.

## Auditing an existing suite

When asked to review tests rather than write them, follow `references/audit.md`. It
covers triage, sampling, and the report format: a table of verified / vacuous / flaky /
unverifiable, with the mutation used as evidence for each verdict.

An audit is the case `scripts/mutate.py` was built for — many mutations, many tests,
and bookkeeping that goes wrong by hand. Drive the whole sweep through it.

Audits produce a written report file. Single-test proofs during ordinary coding do not
— a line in the conversation is enough there.

## Stack-specific recipes

The method is language-agnostic. Read the file matching the project's stack for
concrete mutations, how to run exactly one test, and the vacuity traps particular to
that framework. Read only the one you need.

- `references/php.md` — PHPUnit and Pest
- `references/java.md` — JUnit 4/5 with Maven or Gradle
- `references/javascript.md` — Vitest, Jest, Node test runner
- `references/pytest.md` — Python / pytest
- `references/other-stacks.md` — Go, Rust, Ruby/RSpec, shell/Bats, HTTP and data tests
- `references/mutations.md` — mutation catalogue and how to choose one (any language)
- `references/vacuous-patterns.md` — the false-negative field guide
- `references/audit.md` — whole-suite audit procedure and report template
- `scripts/mutate.py` — batch harness: many mutations, which tests noticed, guaranteed restore

If the stack is not listed, the method still applies unchanged: all it needs from a
framework is "run exactly one test" and "show me the failure message".

## Working with dedicated mutation-testing tools

If the project already has `mutmut`, `cosmic-ray`, `Stryker`, `PIT` or similar wired
up, use it for breadth — it will mutate far more than you can by hand. It does not
replace the targeted proof: those tools answer "does any test notice this change?",
while you are answering "does *this* test notice the thing it claims to check?". Use
the tool for coverage, the manual proof for the test in front of you.

Do not install a mutation-testing framework just to satisfy this skill. The four-step
proof needs nothing beyond editing a file and running a test.
