# falsifiable-tests

A test that has never been seen to fail is not evidence. It is a claim about the code
that has itself never been tested.

This skill makes Claude prove a test can fail before treating it as verification:
break the code under test, confirm the test turns red *for the right reason*, restore.
It fires whenever tests are written, modified or reviewed, and whenever a suite goes
green and Claude is about to say something "works".

Canonical source and issue tracker: https://github.com/ArnauFerma/falsifiable-tests

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install falsifiable-tests@community-claude-plugins
```

## What it does

**The red proof**, applied to the specific test just written or under audit:

1. **Green** — run against correct code; confirm the test actually ran (`1 passed`, not
   `1 skipped` or `no tests ran`).
2. **Break the subject** — edit a small, survivable defect into the file the tests
   import, never into the test and never into a copy.
3. **Read the failure** — it must fail on the assertion, with the expected-vs-actual
   you care about. An `ImportError` or fixture crash proves nothing.
4. **Restore and re-confirm green.**

Around that core it covers:

- the three degenerate returns every assertion must reject (nothing, wrong shape,
  plausible-but-wrong)
- the shortcut that is not a proof (reimplementing a broken copy the tests never import)
- a countable rule — N mutations need at least N+2 suite runs — so a claimed
  verification can be checked against runs that actually happened
- equivalent mutants, and why a survived mutation is not automatically a vacuous test
- what to do when asked to "make the tests pass": the fix goes in the subject, and a
  changed assertion is a new test that needs its own proof
- flakiness: run alone vs in suite, twice in a row; fix the variance, never add retries
- honesty rules: never claim a proof that was not run; mark unverified tests as such

## Usage

It triggers automatically. To invoke it directly:

```
/falsifiable-tests:falsifiable-tests
```

Typical prompts it responds to:

- "add a test for the discount calculation" — writes the test, proves it can fail, and
  reports the mutation used
- "audit the tests in `tests/`" — follows the audit procedure and writes
  `test-audit-<date>.md` with a verdict and evidence per test
- "make the tests pass" — fixes the subject, not the assertion

For many mutations at once, the bundled harness drives the whole loop mechanically:

```bash
python3 scripts/mutate.py --project . --spec mutations.json \
    --test-cmd "python3 -m pytest -q --junit-xml=report.xml" --junit report.xml
```

It edits the real file, runs the real command, restores from a hash-checked backup,
re-runs the suite on the restored tree, bounds each run with `--timeout`, and reports which tests noticed each mutation,
which mutations nothing caught, and which mutations only broke the plumbing (not
counted as catches). Any suite that emits JUnit XML gets per-test resolution.

## Components

| Path | Purpose |
|---|---|
| `skills/falsifiable-tests/SKILL.md` | the method: red proof, degenerate returns, honesty rules |
| `.../references/pytest.md` | Python / pytest |
| `.../references/javascript.md` | Vitest, Jest, node:test |
| `.../references/java.md` | JUnit 4/5 with Maven or Gradle |
| `.../references/php.md` | PHPUnit and Pest |
| `.../references/other-stacks.md` | Go, Rust, Ruby/RSpec, Bats, HTTP and data tests |
| `.../references/mutations.md` | mutation catalogue, equivalent mutants, choosing one |
| `.../references/vacuous-patterns.md` | field guide to tests that cannot fail |
| `.../references/audit.md` | whole-suite audit procedure and report template |
| `.../scripts/mutate.py` | batch harness (language-agnostic, needs only a test command) |
| `.../scripts/test_mutate.py` | the harness's own tests (`python3 -m pytest scripts/ -q`) |
| `.../scripts/self-mutations.json` | defects planted in the harness by the upstream CI; every one must be caught |

No commands, agents, hooks or MCP servers. Nothing runs without being invoked.

## Where it comes from

The method predates the skill: it is how the several hundred tests in
[MCP-Bifrost](https://github.com/ArnauFerma/MCP-Bifrost) are written, each one observed
red under a deliberate break before being trusted. The skill packages that practice so
it can be installed instead of re-explained every session.

## Case studies

The method run against tenacity, tomlkit and click with the harness, findings offered
upstream: https://github.com/ArnauFerma/falsifiable-tests/tree/main/case-studies

## What was measured

The with-skill versus without-skill comparison asks whether the skill *text* changes
what a model does, not whether the method works. Developed against small Python fixtures with deliberately vacuous tests planted in them.
Opus-class models perform the red proof unprompted, with or without the skill; for
Haiku 4.5 the skill raised the pass rate from 11/17 to 16/17 assertions and eliminated
a fabricated-verification failure. One run per cell, no repeats, graded by the same
agent that wrote the skill — details and limitations in the canonical README.

## Licence

MIT — use it, fold it into another skill, keep the attribution line.
