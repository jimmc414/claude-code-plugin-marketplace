# JavaScript / TypeScript — Vitest, Jest, node:test

## Running exactly one test

```bash
# Vitest
npx vitest run path/to/file.test.ts -t "rejects expired tokens"
npx vitest run path/to/file.test.ts --reporter=verbose

# Jest
npx jest path/to/file.test.ts -t "rejects expired tokens"
npx jest --listTests                      # confirm the file is collected

# node:test
node --test --test-name-pattern="rejects expired" test/file.test.js
```

`-t` matches against the full concatenated name (`describe` + `it`), so include enough
of the outer block to be unambiguous.

**Confirm the test ran.** Both runners happily report success when zero tests matched
the filter. Check the `Tests  1 passed` line, not just the exit code.

## Reading the failure correctly

A real red:

```
AssertionError: expected 120 to be 108
- Expected  + Received
- 108
+ 120
```

Not a proof:

```
Error: Cannot find module '../src/discount'
TypeError: Cannot read properties of undefined (reading 'total')
ReferenceError: applyDiscount is not defined
```

Those mean the mutation broke resolution or crashed the subject, not that the
assertion discriminated. Shrink the mutation.

## The async trap — check this first

This is the highest-frequency false negative in JS test suites:

```javascript
it("rejects bad tokens", () => {
  expect(verify(bad)).rejects.toThrow();      // ← no await, no return
});
```

The test function returns before the promise settles. The runner sees no failure and
reports green forever. Correct forms:

```javascript
it("rejects bad tokens", async () => {
  await expect(verify(bad)).rejects.toThrow(TokenExpiredError);
});
```

Same class of bug: an assertion inside a `.then()` with no return, an assertion inside
a callback the test never waits for, a `setTimeout` the test outruns.

**Diagnostic that settles it:** put `expect(1).toBe(2)` where the real assertion is. If
the test still passes, no assertion in that position can ever fail — the whole block
is unreachable from the runner's perspective.

Vitest and Jest also support `expect.assertions(n)` / `expect.hasAssertions()`, which
turn "the assertion never ran" into an explicit failure. Worth adding to any async
test you cannot otherwise prove.

## JS-specific mutations

- `return undefined` / delete the return — catches `toBeTruthy`, `toBeDefined`.
- `return null` — separately, because `toBeDefined()` passes on `null`.
- `return {}` or `return []` — catches `expect(x).toBeInstanceOf(Object)` and length
  checks with no content assertion.
- Change `===` to `==`, `>` to `>=` — boundary and coercion tests.
- Remove an `await` inside the subject — exposes tests that resolve before the work.
- Comment out the `dispatch` / `emit` / `setState` / `fetch` call — the side-effect
  mutation.
- Change a returned string's casing or whitespace — catches over-loose matchers like
  `toContain`.

## Matcher traps

- `toBeTruthy()` / `toBeFalsy()` — passes on `[0]`, `"error"`, `{}`. Truthiness is not
  an assertion.
- `toBeDefined()` — passes on `null`, `0`, `""`, `false`.
- `toContain()` on a long string — passes on almost anything containing the substring.
- `toThrow()` with no argument — passes on a `TypeError` from a typo in the subject.
  Pass the error class or a message pattern.
- `toEqual` vs `toStrictEqual` — `toEqual` ignores `undefined` properties and class
  identity, so a mutation that drops a field can survive it.
- `expect(mockFn).toHaveBeenCalled()` — asserts the mock was called, not that anything
  correct happened. Assert the arguments, and separately assert the outcome.

## Over-mocking

`vi.mock()` / `jest.mock()` applied to the module under test (rather than its
dependencies) removes the subject entirely. Diagnostic: throw at the top of the real
implementation; if the test still passes, it never ran.

Auto-mocked modules return `undefined` from every function, which combines with
`toBeFalsy()`-style assertions to produce tests that pass no matter what.

## Snapshots

```bash
npx vitest run --update=false
CI=true npx jest --ci                  # fails instead of writing new snapshots
```

If snapshots are written on mismatch during normal runs, they cannot fail by
construction. Confirm they are committed and that CI runs with updates disabled — then
mutate the subject and check the snapshot test goes red.

## Flakiness checks

```bash
npx vitest run path/file.test.ts                 # alone
npx vitest run                                   # whole suite
npx vitest run --sequence.shuffle                # order dependence
npx jest --runInBand                             # serialise; compare with parallel
npx jest --detectOpenHandles                     # leaked timers/sockets
```

Usual culprits: module-level state surviving between files, fake timers not restored,
`vi.restoreAllMocks()` missing, a shared temp directory, real network calls.

## Restoring after a mutation

```bash
git diff --stat
git checkout -- src/discount.ts
git diff --quiet && echo "tree clean"
```

Watch for build artefacts: if the project compiles to `dist/`, a stale build can make
the restored code still behave like the mutation. Re-run the build, or run tests
against source.
