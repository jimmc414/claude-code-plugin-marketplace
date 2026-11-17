# PHP — PHPUnit and Pest

## Running exactly one test

```bash
# PHPUnit
vendor/bin/phpunit --filter testRejectsExpiredToken tests/AuthTest.php
vendor/bin/phpunit --filter 'AuthTest::testRejectsExpiredToken'
vendor/bin/phpunit --filter '/::testRejects.*Token$/'        # regex
vendor/bin/phpunit --testdox                                  # names as sentences

# Pest
vendor/bin/pest --filter="rejects expired tokens"
```

For the bundled harness, PHPUnit writes the JUnit XML it needs:

```bash
vendor/bin/phpunit --log-junit report.xml
```

**Confirm the test ran.** PHPUnit ends with `OK (1 test, 3 assertions)`. Read both
numbers. `OK (1 test, 0 assertions)` means the method executed and asserted nothing —
a passing test that cannot fail. If the run says `No tests executed!`, your filter
matched nothing and any conclusion you draw from it is void.

## Reading the failure correctly

A real red:

```
1) AuthTest::testRejectsExpiredToken
Failed asserting that true is false.
```

Not a proof:

```
Error: Call to a member function getTotal() on null
PHP Fatal error: Uncaught TypeError: ...
Cannot open file "src/Auth.php"
```

Those say the mutation broke the plumbing, not that the assertion discriminated.
Shrink the mutation until the failure line reads `Failed asserting that ...`.

## The assertion-count guard

PHP's most valuable vacuity check is built in. In `phpunit.xml`:

```xml
<phpunit beStrictAboutTestsThatDoNotTestAnything="true">
```

With it on, a test that performs no assertions is reported as **risky** rather than
passing. Check whether the project has it; if the suite is full of green tests and this
is off, turning it on is the cheapest audit you will ever run. Note that a test whose
only "assertion" is a mock expectation still counts as testing something, so this
catches the empty ones, not the weak ones.

## PHP-specific mutations

- `return null;` from the subject — the highest-yield mutation, because `assertNotNull`
  and truthy checks are everywhere.
- `return [];` / `return '';` / `return 0;` — catches `assertNotEmpty` and count checks
  with no content assertion.
- Return the argument unchanged — for formatters, sanitisers, normalisers.
- `===` → `==` (or the reverse). PHP's loose comparison is a genuine source of shipped
  bugs, so a test that cannot tell them apart is worth knowing about.
- `isset()` → `array_key_exists()` — they differ on a key that exists holding `null`.
- Delete a `throw` inside a validator — the mutation for every `expectException` test.
- Comment out a `->save()`, `->flush()`, `->dispatch()` — the side-effect mutation for
  Eloquent/Doctrine tests that assert on the return value.
- Off-by-one on a boundary: `>=` → `>`.

## PHPUnit traps worth knowing

**`assertEquals` is loose; `assertSame` is strict.** `assertEquals` compares with `==`,
so it ignores type and, for objects, compares attributes rather than identity. A
mutation that changes `'5'` to `5`, or returns a different instance with the same
fields, sails straight through it. When the test's point is the exact value, use
`assertSame`.

**`expectException(Exception::class)` is too broad.** It passes on a `TypeError` from a
typo in a line the test never meant to reach — the same trap as a bare `catch`. Name the
specific exception class, and add `expectExceptionMessage()` when the message carries
meaning.

Related: `expectException` applies to the whole test method, not to one line. If the
method does setup work that can throw, the test can pass without ever reaching the call
it claims to check. Keep the throwing call last, or better, isolate it.

**Method naming and attributes.** PHPUnit runs methods prefixed `test`, or marked
`#[Test]` (PHPUnit 10+) or `@test` (removed in PHPUnit 11). A renamed method — or an
upgrade that drops `@test` support — makes a test disappear silently, reported as
nothing at all rather than as a failure. After any PHPUnit major upgrade, compare the
test count against the number of test methods in the files.

**Empty data providers.** A `#[DataProvider]` that returns an empty array means the test
executes zero times. Depending on version and config this is an error or a silent
non-event; do not assume it failed loudly.

**Mocks that replace the subject.** A `createMock()` of the class under test, or a
partial mock whose method you are supposedly testing, means the real implementation
never runs. Diagnostic: `throw new \RuntimeException('reached');` at the top of the real
method. If the test still passes, it never got there.

`$this->createMock(Repo::class)` with `->willReturn($x)` followed by asserting on `$x`
is the PHP form of asserting on the mock's own data. Assert the outcome, not the stub.

**Skipped and incomplete.** `markTestSkipped()` and `markTestIncomplete()` are not
failures and read as green in a summary line. Count them explicitly.

## Pest specifics

Pest wraps PHPUnit, so everything above applies. Two extras:

- `it('...')->todo()` and `->skip()` report as non-failures.
- Higher-order expectations (`expect($x)->toBe(...)->not->toBeNull()`) chain fluently,
  which makes it easy to write a long chain where every link is trivially true. Read
  chains for what they actually pin, not for their length.

## Checking for flakiness

```bash
vendor/bin/phpunit --filter testName          # alone
vendor/bin/phpunit                            # whole suite
vendor/bin/phpunit --order-by=random          # order dependence
vendor/bin/phpunit --order-by=defects         # reruns previous failures first
```

Usual PHP culprits: static properties surviving between tests, a database transaction
not rolled back, `$_SERVER`/`$_ENV` mutated by an earlier test, singletons and service
containers not reset, and filesystem fixtures in a shared temp path.

## Mutation testing tools

[Infection](https://infection.github.io/) is the PHP mutation-testing framework. If the
project already has it, use it for breadth:

```bash
vendor/bin/infection --threads=4 --min-msi=0 --only-covered
```

It answers "does any test notice this change?". The targeted proof answers "does *this*
test notice the thing it claims to check?". Use both; do not install Infection purely to
satisfy this skill.

## Restoring after a mutation

```bash
git diff --stat
git checkout -- src/Auth.php
git diff --quiet && echo "tree clean"
```

Watch for compiled or cached artefacts: framework caches (`bootstrap/cache`,
`var/cache`), opcache in long-running processes, and autoloader maps can all keep
serving the mutant after you restore the file. When a result contradicts the file in
front of you, clear the cache before believing it.
