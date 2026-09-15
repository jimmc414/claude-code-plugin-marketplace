# Other stacks

Short recipes. The method is unchanged — this file only supplies "run one test", "read
the failure", and the traps peculiar to each framework.

---

## Go

```bash
go test ./pkg/orders -run '^TestApplyDiscount$' -v
go test ./... -run TestName -count=1        # -count=1 defeats the test cache
```

**The cache trap.** Go caches successful test results. A test that "passes" may not
have run at all. Always pass `-count=1` during a red proof, or you may see a cached
green after mutating the subject.

**Traps**

- A test with no `t.Error`/`t.Fatal` on any path always passes.
- `t.Run` subtests that return early skip their assertions silently.
- `err != nil` checked but the value never asserted — the classic Go vacuous test.
- Goroutines asserting after the test returns: the failure is reported against a
  different test or lost entirely. `t.Parallel` plus shared fixtures amplifies this.

**Mutations:** return the zero value, return `nil` error where an error was expected,
drop a `defer`, swap `>=` for `>`, comment out the struct field assignment.

---

## Rust

```bash
cargo test path::to::test_name -- --exact --nocapture
cargo test -- --test-threads=1        # serialise to expose shared state
```

**Traps**

- `#[ignore]` tests report as ignored, which reads as green in a summary.
- `assert!(result.is_ok())` without inspecting the value — passes on any `Ok`.
- `unwrap()` in a test turns a wrong value into a panic, which does fail, but the
  message tells you nothing about the assertion. Prefer `assert_eq!`.
- `#[should_panic]` without `expected = "..."` passes on any panic, including one from
  a typo in the test setup.

**Mutations:** return `Default::default()`, return `Ok(())` where work should happen,
flip a comparison, remove a `?` propagation.

---

## Java / JUnit

Moved to `references/java.md` — Maven and Gradle invocations, the missing-`@Test`
trap, Mockito verification without an outcome assertion, and the build caches that make
a mutation appear not to have landed.

---

## Ruby / RSpec

```bash
bundle exec rspec spec/models/order_spec.rb:42        # by line
bundle exec rspec -e "applies the discount"
```

**Traps**

- `expect(result).to be_truthy` — passes on `0`, `""`, `[]` (all truthy in Ruby).
- `expect { ... }.not_to raise_error` — cannot distinguish working from doing nothing.
- `allow(...).to receive(...)` stubbing the subject itself.
- `pending` / `skip` blocks reported as non-failures.
- Shared `let!` state and database transactions leaking between examples.

**Mutations:** return `nil`, return the receiver unchanged, remove a `save!`, invert a
guard clause.

---

## Shell / Bats

```bash
bats test/cli.bats -f "rejects missing argument"
```

**Traps**

- Without `set -e` (or with it in the wrong place), a failing command mid-test does not
  fail the test.
- Asserting only on exit code 0 — many tools exit 0 on partial success.
- `run cmd` captures status into `$status`; forgetting to assert on `$status` *and*
  `$output` leaves the test asserting nothing.
- Pipelines mask failures: `cmd | grep x` returns grep's status, not `cmd`'s.

**Mutations:** make the script exit 0 unconditionally, remove the validation branch,
write nothing to the output file.

---

## Databases, migrations, data contracts

When the "code under test" is data rather than a function, mutate the input:

- Remove a required column/field from the fixture — the schema test must go red.
- Insert a row violating a constraint — the constraint test must go red.
- Run the migration against a snapshot that lacks the prior migration — the ordering
  test must go red.

If a schema test stays green when a required field is deleted, it is validating
something other than what its name claims.

---

## HTTP / API tests

- Assert the status code **and** the body. Status-only tests survive a handler that
  returns 200 with an error payload.
- Mutation: return `200 {}` from the handler. Any test that stays green was only
  checking the status.
- Mutation: return the right shape with wrong values. Any test that stays green was
  only checking the schema.
- Beware recorded fixtures (VCR/cassettes): if the recording is replayed, the real
  handler may never run. Delete the cassette and see whether the test still passes —
  if it does, it never touched the network path it claims to test.

---

## Anything not listed

The method needs only two capabilities from a test framework:

1. run exactly one test
2. show the failure message

Find those two in the framework's docs and apply the four-step proof unchanged. When
the framework caches results (Go, Gradle, Bazel, Nx, Turborepo), find the flag that
disables the cache first — a cached green after a mutation is the easiest way to
fabricate a proof by accident.
