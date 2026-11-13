# Java — JUnit 4/5, Maven and Gradle

## Running exactly one test

```bash
# Maven (Surefire)
mvn test -Dtest=OrderServiceTest#appliesDiscount
mvn test -Dtest='OrderServiceTest#applies*'
mvn -q test -Dsurefire.failIfNoSpecifiedTests=false -Dtest=...

# Gradle
gradle test --tests "com.example.OrderServiceTest.appliesDiscount"
gradle test --tests "*OrderServiceTest*" --rerun-tasks
```

**Beware the build cache.** Gradle marks `test` UP-TO-DATE and skips it entirely when
nothing it tracks has changed, so a mutation-and-rerun can report the previous result.
Use `--rerun-tasks` (or `cleanTest test`) during a proof. Maven re-runs by default but
will happily report success when your `-Dtest` filter matched nothing — set
`failIfNoSpecifiedTests` or read the test count.

**Confirm the test ran.** `Tests run: 1, Failures: 0, Errors: 0, Skipped: 0`. A run of
`Tests run: 0` is not a pass.

JUnit XML for the bundled harness is produced automatically at
`target/surefire-reports/*.xml` (Maven) or `build/test-results/test/*.xml` (Gradle);
point `--junit` at the file for the test you are proving.

## Reading the failure correctly

A real red:

```
org.opentest4j.AssertionFailedError: expected: <108.0> but was: <120.0>
```

Not a proof:

```
java.lang.NullPointerException
java.lang.NoSuchMethodError
Compilation failure: cannot find symbol
```

A mutation that stops the module compiling proves only that the compiler works. Keep the
mutation small enough that the code still builds and still runs.

## Java-specific mutations

- `return null;` — the highest-yield mutation, and the one that exposes
  `assertNotNull`-only tests.
- Return an empty collection — `Collections.emptyList()` — catches size-free assertions.
- Flip a comparison: `>=` → `>`, `equals` → `==` (reference identity), `&&` → `||`.
- Remove a `throw` from a validator — the mutation for every `assertThrows` test.
- Delete a `repository.save(...)` / `publisher.publish(...)` — the side-effect mutation.
- Swap two arguments of the same type in a call — catches tests that assert only on
  shape, and it is a real bug class.
- Return a stale field instead of the computed value.

## JUnit traps worth knowing

**Missing `@Test`.** A method without the annotation simply never runs, and nothing
reports its absence. This is the quietest way for a test to disappear — especially when
migrating JUnit 4 → 5, where `org.junit.Test` and `org.junit.jupiter.api.Test` look
identical at the call site but only the matching runner picks them up. After a
migration, compare the executed test count against the number of annotated methods.

**`assertTrue(x != null)` and friends.** The Java dialect of truthiness. Prefer
`assertEquals`/`assertNotNull` with the value pinned, and remember `assertEquals` on
doubles needs a delta or it compares exactly.

**`assertThrows(Exception.class, ...)`** passes on a `NullPointerException` thrown by
unrelated breakage on the way. Name the specific exception, and assert on the message
when it carries meaning:

```java
var ex = assertThrows(ValidationException.class, () -> verify(token));
assertTrue(ex.getMessage().contains("expired"));
```

**Mockito `verify()` without an outcome assertion.** `verify(repo).save(any())` proves a
call happened with *some* argument. Capture and assert the argument, and separately
assert the observable result. `any()` in particular makes the check nearly vacuous.

Over-mocking: `@InjectMocks` on the class under test with every collaborator mocked can
leave the real logic untouched. Diagnostic: `throw new AssertionError("reached")` at the
top of the real method; if the test still passes, it never ran.

**`@Disabled` / `@Ignore`** are not failures and read as green in a summary. Count them.

**Assertions disabled at runtime.** Plain `assert` statements (the language keyword, not
JUnit) are stripped unless the JVM runs with `-ea`. Production-style assertions inside
the subject may therefore never fire under test.

**Flaky by construction.** `@RepeatedTest`, parallel execution
(`junit.jupiter.execution.parallel.enabled`), and shared `static` state interact badly.
A test that only passes in suite order is depending on another test's leftovers.

## Checking for flakiness

```bash
mvn test -Dtest=OrderServiceTest#appliesDiscount     # alone
mvn test                                             # whole suite
gradle test --rerun-tasks                            # defeat the cache
```

Usual culprits: static fields and singletons, a Spring context reused across classes
with mutated beans, `@DirtiesContext` missing, database state not rolled back, system
clock and default locale/timezone, and `HashMap` iteration order assumptions.

## Mutation testing tools

[PIT](https://pitest.org/) is the mature Java mutation-testing framework:

```bash
mvn org.pitest:pitest-maven:mutationCoverage
```

It reports surviving mutants across the whole project — excellent for breadth. It does
not replace the targeted proof for the test in front of you, which asks a narrower
question: does *this* test notice the thing its name claims to check?

## Restoring after a mutation

```bash
git diff --stat
git checkout -- src/main/java/com/example/OrderService.java
git diff --quiet && echo "tree clean"
```

Then rebuild before trusting the result — a stale `target/` or `build/` directory can
keep running the mutant after the source is restored.
