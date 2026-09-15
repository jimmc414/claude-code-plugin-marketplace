# Vacuous test patterns — a field guide

These are the shapes that produce tests which cannot fail. Use this list two ways:
to **triage** an existing suite (which tests to spend a mutation on first), and to
**avoid** writing them in the first place.

Every pattern here is a hypothesis, not a verdict. The mutation is what settles it —
a test can match a pattern and still be fine, and a test can look immaculate and still
be vacuous. Never mark a test vacuous on sight; mark it *suspect*, then prove it.

## No assertion at all

The test calls the function and ends. It passes as long as nothing throws.

```python
def test_process_order():
    process_order(order)          # ← asserts nothing
```

Sometimes deliberate ("this must not crash"), but even then it should assert the
outcome. As written, the function could return garbage forever and stay green.

**Related:** the assertion is there but was never executed — inside an `if` that is
false, inside a `for` over an empty list, or after an early `return`. Reading the test
top-to-bottom hides this completely; only running it with a mutation exposes it.

## Truthiness instead of value

```python
assert result
assert len(items) > 0
expect(response).toBeTruthy()
```

Passes for `[0]`, `"error"`, `-1`, `{"error": "denied"}`. Nearly every "returns nothing
or something unexpected" false negative comes from here. Assert the value, the length
*and* the content, or the specific field.

## Tautologies

```python
assert True
assert 1 == 1
expect(x).toBe(x)
assert result == result
```

Also the sneaky version: comparing the subject's output to a value derived from the
subject itself.

```python
expected = transform(data)
assert transform(data) == expected     # ← always true, tests nothing
```

The expected value must be independently known — hand-written, from a spec, from a
fixture file — never computed by the code under test.

## Asserting on the mock

```python
mock_api.fetch.return_value = {"id": 7}
result = get_user(7)
assert result["id"] == 7               # ← this is the mock's own data
```

The test asserts that the mock returned what the mock was told to return. The real
code path may be entirely absent. Diagnostic: delete the body of the function under
test. If the test still passes, it was testing the mock.

Over-mocking generally: when everything the subject touches is mocked, the only thing
left to test is the wiring, and often not even that.

## Exception swallowing

```python
def test_handles_input():
    try:
        parse(payload)
    except Exception:
        pass                            # ← every failure becomes a pass
```

And the softer variant, asserting only that nothing raised — which cannot distinguish
"worked" from "did nothing".

## Over-broad exception expectations

```python
with pytest.raises(Exception):          # ← a typo in the test also passes
    charge(card, -50)
```

`Exception` catches `NameError`, `AttributeError` and `ImportError` too, so the test
passes when the code never reaches the validation it claims to check. Assert the
specific type, and ideally the message.

Same problem when the `raises` block contains several lines: an earlier line raises,
the test passes, and the line you actually meant to test never ran. Keep exactly one
statement inside the block.

## Self-regenerating snapshots

Golden/snapshot tests where the update flag is on by default, or the fixture is
rewritten whenever it does not match. The snapshot always equals the output because
it is *defined* as the output. Check whether snapshots are committed and whether CI
runs with updates disabled.

## Async never awaited

```javascript
it("rejects bad tokens", () => {
  expect(verify(bad)).rejects.toThrow();   // ← no await/return: assertion escapes
});
```

The test function returns before the assertion resolves; the runner sees no failure.
An unhandled rejection may appear in the log and be ignored. Common enough in JS/TS
that it deserves its own check on every async test.

## Skipped, xfail, or filtered out

A test marked skip/xfail/only/focus, excluded by a config pattern, or living in a file
the runner never collects. It reports green — or reports nothing, which reads as green
in a summary line. Verify the test actually ran: check the count, or make it fail
deliberately and confirm you see the failure.

`xfail` without `strict` is especially quiet: it passes whether the code is broken or
fixed.

## Name says one thing, body does another

```python
def test_rejects_expired_token():
    assert verify(valid_token) is True   # ← tests the happy path
```

Copy-paste drift. The suite looks like it covers the failure path; nothing does. Cheap
to spot by reading names against bodies, and it is the reason a mutation should be
chosen from the *name's* claim, not from what the body happens to touch.

## Assertion-free integration tests

"Run the whole pipeline and check it exits 0." Exit codes are coarse — many failures
still exit 0, and some tools exit 0 on partial success. Assert on the artefact
produced, not on the process finishing.

## Environment-dependent pass

The test passes only because of something incidental: a file left by an earlier test, a
timezone, a locale, a network being reachable, a seeded database. This is the false
positive/false negative hybrid — green locally, red in CI, or vice versa. Detect by
running alone vs. in suite, and twice in a row.

---

## Triage order for an audit

When scanning a suite you have not seen before, look for these in order — earlier
items are both more common and cheaper to confirm:

1. Tests with no assertion, or with assertions only inside conditionals
2. Truthiness-only assertions
3. `raises(Exception)` / `toThrow()` with no specific type
4. Async tests missing `await`
5. Heavily mocked tests where the subject may never execute
6. Skipped / xfail / uncollected tests
7. Name-vs-body mismatches
8. Snapshot tests with writable goldens

A quick grep gets you a candidate list for most of these; the mutation is what turns a
candidate into a finding.
