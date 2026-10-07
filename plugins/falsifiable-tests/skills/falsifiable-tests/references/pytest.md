# Python / pytest

## Running exactly one test

```bash
pytest path/to/test_file.py::test_name -q                 # one test
pytest path/to/test_file.py::TestClass::test_name -q      # one method
pytest "path/to/test.py::test_name[param-id]" -q          # one parametrised case
pytest -k "expired and not refresh" -q                    # by expression
```

Useful flags during a red proof:

- `-x` stop at first failure (you only care about this one)
- `-q` quiet; you want the assertion diff, not the banner
- `--no-header -p no:randomly` when a shuffle plugin makes runs non-comparable
- `-rA` shows the reason for skipped/xfailed tests — use it to catch tests that are
  not actually running
- `--collect-only` confirms the test is even seen by the collector

**Confirm the test ran.** `pytest` prints `1 passed` — if it prints `no tests ran` or
`1 skipped`, your proof is meaningless. Check the count line every time.

## Reading the failure correctly

A real red for a value assertion looks like this:

```
E       assert 120.0 == 108.0
E        +  where 120.0 = apply_discount(...)
```

That is the assertion discriminating. These are **not** valid proofs:

```
E       ImportError: cannot import name 'apply_discount'
E       AttributeError: 'NoneType' object has no attribute 'total'
E       fixture 'db' not found
ERROR collecting tests/test_orders.py
```

They mean the mutation broke the plumbing, not that the assertion noticed a behaviour
change. Reduce the mutation until the test fails on the assertion line.

## Python-specific mutations

- `return None` from the subject — the highest-yield mutation in Python, because
  `assert result` and `assert result is not None` are so common.
- Return `{}` / `[]` / `""` — catches `assert len(x) > 0` style assertions.
- Delete a `raise` inside a validator — the mutation for every `pytest.raises` test.
- Change `is` to `==` (or the reverse) where identity matters.
- Swap `dict.get(k)` for `dict.get(k, default)` — hides KeyErrors.
- Remove an `await`, or drop the `async` and return a coroutine — exposes async tests
  that never await the subject.
- Comment out a `session.add(...)` / `.commit()` / file write — the side-effect
  mutation for ORM and IO tests.

## pytest traps worth knowing

**`pytest.raises` scope.** Only one statement belongs inside the block, and the type
should be specific:

```python
with pytest.raises(ValidationError, match="expired"):
    verify(token)
```

`pytest.raises(Exception)` passes on a `NameError` from a typo. If the test uses it,
that is a finding on its own — the fix is narrowing the type, and then the mutation
(delete the `raise`) must still turn it red.

**Fixtures that silently do nothing.** A fixture whose name is misspelled in the test
signature is just an unused argument in some configs, or an error in others. If a
mutation to the fixture's data does not change the outcome, the fixture is not wired in.

**Stale bytecode after a size-preserving mutation.** Python decides a `.pyc` is fresh
by comparing the source's mtime **in whole seconds** and its size in bytes. A mutation
that changes neither — `100` → `101`, `>` → `<`, `and` → `or` — applied and reverted
within the same second can leave the interpreter running the cached mutant. The test
then "fails" after you restored, or worse, passes while mutated, and both readings are
lies. If a result contradicts the file you are looking at, clear the cache before
believing it:

```bash
find . -name __pycache__ -type d -exec rm -rf {} +   # or: python -B -m pytest
```

`-B` (or `PYTHONDONTWRITEBYTECODE=1`) sidesteps it entirely and is worth setting for
the duration of a mutation session.

**`assert` stripped under `-O`.** If tests ever run with `python -O`, every bare
`assert` vanishes. Rare, but it makes an entire suite vacuous at once.

**`unittest.TestCase` subclasses.** Methods not prefixed `test_` never run. A renamed
method (or a typo like `tets_`) disappears silently.

**Parametrised cases.** Prove the mutation against a case that should discriminate.
Many parametrise sets contain a case where the expected value coincides with the
mutated output — verify the whole set goes red, or pick your case deliberately.

**Mocks that replace the subject.** `monkeypatch.setattr` or `unittest.mock.patch`
pointed at the module under test rather than its dependency means the real code never
runs. Diagnostic: `raise AssertionError("reached")` at the top of the subject; if the
test still passes, it never got there.

## Checking for flakiness

```bash
pytest path::test_name -q                    # alone
pytest -q                                    # whole suite
pytest path::test_name -q --count=2          # needs pytest-repeat
pytest -p no:randomly -q                     # fixed order
pytest -q --randomly-seed=12345              # reproduce a shuffle
```

If a test passes alone and fails in the suite (or the reverse), find the shared state:
module-level globals, `tmp_path` reused, a session-scoped fixture mutated by another
test, an unclosed DB transaction, `os.environ` not restored.

## Restoring after a mutation

```bash
git diff --stat            # confirm exactly one file, few lines
git checkout -- path/to/subject.py
git diff --quiet && echo "tree clean"
```

Without git: copy the file to the scratch directory before mutating and restore from
the copy. Never retype the original line from memory.
