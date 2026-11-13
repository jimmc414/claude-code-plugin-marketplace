#!/usr/bin/env python3
"""Batch red proof: apply mutations one at a time and record which tests notice.

Use this when auditing a suite, where proving tests one by one by hand is too slow.
For a single test you just wrote, the four-step proof in SKILL.md is faster than
setting this up.

The output is a matrix of test x mutation. What you are looking for is survivors:

  - a test that stays green under every mutation touching the behaviour it names
    is vacuous with respect to that behaviour
  - a mutation that no test notices is either a coverage gap (that defect could
    ship) or an equivalent mutant (the change has no observable effect for the
    inputs the tests use). Decide which by reading, not by trusting this report.

Language-agnostic. It only needs a shell command that runs your suite, and
optionally a JUnit XML report for per-test resolution (pytest --junit-xml=,
vitest/jest --reporters=junit, go-junit-report, gradle, and most others emit it).
Without JUnit XML it falls back to whole-suite pass/fail, which still finds
mutations nothing catches but cannot tell you which test did the catching.

USAGE

    python3 mutate.py --project . --spec mutations.json \
        --test-cmd "python3 -m pytest -q --junit-xml=report.xml" \
        --junit report.xml

    # whole-suite resolution only
    python3 mutate.py --project . --spec mutations.json --test-cmd "go test -count=1 ./..."

SPEC FORMAT (mutations.json)

    [
      {
        "name": "apply_coupon ignores the discount",
        "file": "orders.py",
        "find": "return round(subtotal * (1 - COUPONS[code]), 2)",
        "replace": "return round(subtotal, 2)"
      }
    ]

`find` must appear exactly once in the file, so a mutation cannot land somewhere
you did not intend. Keep mutations small and survivable — a mutation that stops
the code importing tests only that the file is loaded, not that any assertion
discriminates.

WHAT COUNTS AS CAUGHT

A mutation is caught only when a test fails on an assertion (a JUnit <failure>).
A test that errors (<error>: import failure, fixture crash, collection error) or
that vanishes from the report altogether is reported as "broke the plumbing",
not as caught — the skill's rule is that a red for the wrong reason is not a
proof. Likewise, a test that was absent or errored under a mutation is never
counted as having stayed green under it.

TIMEOUTS

Pass --timeout SECONDS to bound each suite run. A mutation that turns a bounded
loop into an unbounded one (a "retry until valid" whose valid path you just
removed) would otherwise hang the audit forever. A timed-out run is reported in
its own list: it is neither a catch nor a survival.

SAFETY

Every targeted file is copied before the first mutation and restored after each
run, including on Ctrl-C, SIGTERM, or an unhandled error. After the last mutation the
suite is run once more against the restored tree, and every touched file is
hash-checked; if any file does not match its original, the script says so
loudly and tells you where the backup is. Never leave a mutation in the tree.

PYTHONDONTWRITEBYTECODE=1 is set for every test run so a size-preserving
mutation cannot leave a stale .pyc behind (see references/pytest.md).
"""

import argparse
import hashlib
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path

# Per-test outcomes. ABSENT is used for a test seen in the baseline that produced no
# <testcase> in a later run — usually because its whole module failed to collect.
PASS, FAIL, ERROR, SKIP, ABSENT = "pass", "fail", "error", "skip", "absent"

OUTPUT_TAIL_LINES = 25

# The suite run currently in flight, so a SIGTERM to the harness can take it down too.
_current_run: subprocess.Popen | None = None


def _kill_current_run() -> None:
    if _current_run is not None and _current_run.poll() is None:
        try:
            os.killpg(_current_run.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Workspace:
    """Backs up every file a mutation touches and guarantees restoration."""

    def __init__(self, project: Path):
        self.project = project
        self.backup_dir = Path(tempfile.mkdtemp(prefix="mutate-backup-"))
        self.originals: dict[Path, str] = {}

    def _backup_path(self, target: Path) -> Path:
        rel = target.relative_to(self.project).as_posix()
        return self.backup_dir / rel.replace("/", "__")

    def protect(self, rel_path: str) -> Path:
        target = self.project / rel_path
        if not target.is_file():
            raise SystemExit(f"No such file to mutate: {target}")
        if target not in self.originals:
            shutil.copy2(target, self._backup_path(target))
            self.originals[target] = sha256(target)
        return target

    def restore_all(self) -> None:
        for target in self.originals:
            shutil.copy2(self._backup_path(target), target)

    def verify_clean(self) -> list[str]:
        """Return the files that do not match their original content."""
        return [
            str(target)
            for target, digest in self.originals.items()
            if sha256(target) != digest
        ]


@dataclass
class RunResult:
    returncode: int
    output: str
    junit_present: bool
    junit_expected: bool = False
    timed_out: bool = False
    per_test: dict[str, str] = field(default_factory=dict)

    @property
    def suite_passed(self) -> bool:
        return self.returncode == 0

    @property
    def command_ran(self) -> bool:
        """False when the command itself could not execute (shell 127/126)
        or when a JUnit file was expected and none appeared. Neither is a red
        suite; both mean nothing was measured."""
        if self.returncode in (126, 127):
            return False
        return self.junit_present or not self.junit_expected

    def tail(self) -> str:
        lines = self.output.strip().splitlines()[-OUTPUT_TAIL_LINES:]
        return "\n".join("    | " + line for line in lines) if lines else "    | (no output)"


def parse_junit(junit: Path) -> dict[str, str]:
    try:
        root = ET.parse(junit).getroot()
    except ET.ParseError:
        return {}
    per_test: dict[str, str] = {}
    for case in root.iter("testcase"):
        name = case.get("name") or "?"
        classname = case.get("classname") or ""
        key = f"{classname}::{name}" if classname else name
        tags = {child.tag for child in case}
        if "skipped" in tags:
            per_test[key] = SKIP
        elif "error" in tags:
            per_test[key] = ERROR
        elif "failure" in tags:
            per_test[key] = FAIL
        else:
            per_test[key] = PASS
    return per_test


def run_suite(
    test_cmd: str, project: Path, junit: Path | None, timeout: float | None = None
) -> RunResult:
    if junit and junit.exists():
        junit.unlink()

    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
    # A mutation can turn a bounded loop into an unbounded one ("retry until the
    # answer is valid" with the answer path broken), and a suite that never returns
    # would stall the whole audit. Run in its own process group so a timeout can
    # kill the test runner and everything it spawned.
    proc = subprocess.Popen(
        test_cmd, shell=True, cwd=project, env=env,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
        start_new_session=True,
    )
    global _current_run
    _current_run = proc
    timed_out = False
    try:
        output, _ = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        output, _ = proc.communicate()
    finally:
        _current_run = None
    junit_present = bool(junit and junit.exists())
    run = RunResult(
        returncode=proc.returncode,
        output=output or "",
        junit_present=junit_present,
        junit_expected=junit is not None,
        timed_out=timed_out,
    )
    if junit_present:
        run.per_test = parse_junit(junit)
    return run


def validate_spec(mutations: list, project: Path) -> None:
    """Check every mutation lands before running any of them.

    Failing halfway through leaves you with a partial audit and a spec you have to
    debug anyway, so it is worth paying for the whole check up front. Escaping is
    the usual culprit: a `find` string written in JSON needs its backslashes
    doubled, and a mismatch here means the mutation would have silently done nothing.
    """
    problems = []
    for mutation in mutations:
        missing = [k for k in ("name", "file", "find", "replace") if k not in mutation]
        if missing:
            problems.append(f"{mutation.get('name', '<unnamed>')}: missing {missing}")
            continue
        target = project / mutation["file"]
        if not target.is_file():
            problems.append(f"{mutation['name']}: no such file {target}")
            continue
        count = target.read_text(encoding="utf-8").count(mutation["find"])
        if count == 0:
            problems.append(
                f"{mutation['name']}: `find` text not present in {mutation['file']}. "
                f"Check escaping — in JSON a literal backslash must be written \\\\."
            )
        elif count > 1:
            problems.append(
                f"{mutation['name']}: `find` text appears {count} times in "
                f"{mutation['file']}; make it unique so the mutation lands where you meant."
            )
    if problems:
        print("Spec problems — nothing was mutated:")
        for problem in problems:
            print("  " + problem)
        raise SystemExit(1)


def apply_mutation(target: Path, find: str, replace: str) -> None:
    text = target.read_text(encoding="utf-8")
    target.write_text(text.replace(find, replace, 1), encoding="utf-8")


def describe(run: RunResult, baseline: dict[str, str]) -> tuple[str, str]:
    """Classify one mutated run. Returns (status_key, human line).

    status_key is one of: survived, caught, plumbing, red, not_run.
    """
    if run.timed_out:
        return "timeout", ("TIMED OUT - the mutated suite never finished; probably an "
                           "unbounded loop. Not a catch; pick a survivable mutation.")
    if not run.command_ran:
        return "not_run", "TEST COMMAND DID NOT RUN - nothing measured"
    if run.suite_passed:
        return "survived", "SURVIVED - no test noticed (defect could ship, or equivalent mutant)"
    if not baseline:
        return "red", "suite red (whole-suite resolution; cannot say which test)"

    failed = sum(1 for v in run.per_test.values() if v == FAIL)
    errored = sum(1 for v in run.per_test.values() if v == ERROR)
    absent = sum(1 for t in baseline if t not in run.per_test)
    if failed:
        line = f"caught by {failed}"
        if errored or absent:
            line += f" (also {errored} errored, {absent} absent - check those are not this mutation's real effect)"
        return "caught", line
    return "plumbing", (
        f"BROKE THE PLUMBING - {errored} errored, {absent} absent, 0 assertion failures. "
        "Not a proof; shrink the mutation."
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--spec", required=True, type=Path)
    parser.add_argument("--test-cmd", required=True)
    parser.add_argument("--junit", type=Path, default=None,
                        help="JUnit XML the test command writes; enables per-test resolution")
    parser.add_argument("--json-out", type=Path, default=None,
                        help="Write the full result matrix here")
    parser.add_argument("--timeout", type=float, default=None, metavar="SECONDS",
                        help="Kill a suite run that exceeds this; the mutation is reported "
                             "as timed out and the audit continues (default: no limit)")
    parser.add_argument("--skip-final-run", action="store_true",
                        help="Do not re-run the suite after the last restore (saves one run; "
                             "the hash check still runs)")
    args = parser.parse_args()

    project = args.project.resolve()
    junit = (project / args.junit) if args.junit and not args.junit.is_absolute() else args.junit
    mutations = json.loads(args.spec.read_text(encoding="utf-8"))

    print("Baseline run (the suite must be green before mutating)...")
    baseline = run_suite(args.test_cmd, project, junit, args.timeout)
    if baseline.timed_out:
        print(f"  BASELINE TIMED OUT after {args.timeout:g}s. Raise --timeout or scope the test command.")
        print(baseline.tail())
        return 1
    if not baseline.command_ran:
        print(f"  TEST COMMAND DID NOT RUN (exit {baseline.returncode}"
              f"{', no JUnit file written' if baseline.junit_expected else ''}).")
        print("  This is not a red suite — nothing was measured. Output:")
        print(baseline.tail())
        return 1
    if not baseline.suite_passed:
        print(f"  Suite is RED before any mutation (exit {baseline.returncode}). Fix that first —")
        print("  every verdict below would be confounded by a failure you did not introduce.")
        print(baseline.tail())
        return 1
    baseline_tests = {t: v for t, v in baseline.per_test.items() if v != SKIP}
    skipped = sum(1 for v in baseline.per_test.values() if v == SKIP)
    resolution = "per-test" if baseline_tests else "whole-suite"
    print(f"  green, {len(baseline_tests) or '?'} tests"
          f"{f', {skipped} skipped' if skipped else ''}, {resolution} resolution\n")

    validate_spec(mutations, project)

    ws = Workspace(project)
    matrix: dict[str, dict[str, str]] = {}
    statuses: dict[str, str] = {}

    # Ctrl-C raises KeyboardInterrupt and reaches the finally below; a plain
    # SIGTERM (kill, timeout(1), a CI runner cancelling) does not — it ends the
    # interpreter without unwinding, and would leave the mutation in the tree.
    def _terminate(signum, frame):
        _kill_current_run()
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGTERM, _terminate)

    try:
        for mutation in mutations:
            name = mutation["name"]
            target = ws.protect(mutation["file"])
            try:
                apply_mutation(target, mutation["find"], mutation["replace"])
                run = run_suite(args.test_cmd, project, junit, args.timeout)
            finally:
                ws.restore_all()

            outcomes = {t: run.per_test.get(t, ABSENT) for t in baseline_tests}
            matrix[name] = outcomes
            status, line = describe(run, baseline_tests)
            statuses[name] = status
            print(f"  {name:<50} {line}")
            if status in ("not_run", "timeout"):
                print(run.tail())
    finally:
        ws.restore_all()
        dirty = ws.verify_clean()
        if dirty:
            print("\n!! RESTORATION FAILED for:")
            for path in dirty:
                print("   " + path)
            print(f"   Originals are in {ws.backup_dir} — restore them before doing anything else.")
            return 2

    print("\n" + "=" * 72)

    if baseline_tests:
        never_failed = [
            t for t in baseline_tests
            if not any(matrix[m][t] == FAIL for m in matrix)
        ]
        print(f"\nTests that never failed on an assertion under any of the "
              f"{len(mutations)} mutations ({len(never_failed)}/{len(baseline_tests)}):")
        for t in sorted(never_failed):
            disturbed = sum(1 for m in matrix if matrix[m][t] in (ERROR, ABSENT))
            note = f"   (errored/absent under {disturbed} - those runs say nothing)" if disturbed else ""
            print(f"  {t}{note}")
        print("\n  These are candidates, not verdicts. A test is only vacuous if it")
        print("  survives a mutation that violates the behaviour IT claims to check:")
        print("  read each one and decide whether any mutation above was aimed at it.")

    survived = [m for m, s in statuses.items() if s == "survived"]
    if survived:
        print(f"\nMutations no test noticed ({len(survived)}):")
        for m in survived:
            print("  " + m)
        print("\n  Each is either a defect that could ship, or an equivalent mutant (the")
        print("  change has no observable effect on the tested inputs). Check by hand")
        print("  before reporting a coverage gap.")

    plumbing = [m for m, s in statuses.items() if s == "plumbing"]
    if plumbing:
        print(f"\nMutations that broke the plumbing ({len(plumbing)}) - not proofs of anything:")
        for m in plumbing:
            print("  " + m)

    timed_out = [m for m, s in statuses.items() if s == "timeout"]
    if timed_out:
        print(f"\nMutations that timed out ({len(timed_out)}) - not caught, not survived; "
              "choose a survivable mutation:")
        for m in timed_out:
            print("  " + m)

    not_run = [m for m, s in statuses.items() if s == "not_run"]
    if not_run:
        print(f"\nMutations where the test command did not run ({len(not_run)}):")
        for m in not_run:
            print("  " + m)

    final_ok = True
    if not args.skip_final_run:
        print("\nFinal run against the restored tree...")
        final = run_suite(args.test_cmd, project, junit, args.timeout)
        final_ok = final.command_ran and final.suite_passed and not final.timed_out
        if final_ok:
            print("  green.")
        else:
            print("  NOT GREEN. Files are byte-identical to the originals, so suspect a")
            print("  stale build or cache (see the stack reference for your framework).")
            print(final.tail())

    if args.json_out:
        args.json_out.write_text(
            json.dumps({"baseline_tests": baseline_tests, "matrix": matrix,
                        "statuses": statuses,
                        "survived_mutations": survived,
                        "plumbing_mutations": plumbing,
                        "not_run_mutations": not_run,
                        "timed_out_mutations": timed_out,
                        "final_run_green": final_ok if not args.skip_final_run else None},
                       indent=2),
            encoding="utf-8",
        )
        print(f"\nMatrix written to {args.json_out}")

    print("\nAll mutated files restored and verified byte-identical.")
    return 0 if final_ok else 3


if __name__ == "__main__":
    sys.exit(main())
