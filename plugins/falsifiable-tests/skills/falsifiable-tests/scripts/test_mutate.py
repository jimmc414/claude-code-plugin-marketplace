"""Tests for mutate.py, run against a throwaway fixture project.

Each test builds a tiny project in tmp_path (a subject module, a test file and a
mutation spec), runs the harness against it as a subprocess, and asserts on the
report. The fixture deliberately contains one real test, one vacuous test and one
test whose only mutation is an equivalent mutant, because those are the three
outcomes the harness has to keep apart.

Run with:  python3 -m pytest scripts/test_mutate.py -q
"""

import hashlib
import json
import subprocess
import sys
from pathlib import Path

import pytest

HARNESS = Path(__file__).with_name("mutate.py")
PYTEST_CMD = f'"{sys.executable}" -m pytest -q -p no:cacheprovider --junit-xml=report.xml'

SUBJECT = '''\
COUPONS = {"TEN": 0.10}

def apply_coupon(subtotal, code):
    return round(subtotal * (1 - COUPONS[code]), 2)

def clamp(x, limit):
    return x if x < limit else limit
'''

TESTS = '''\
from orders import apply_coupon, clamp

def test_real():
    assert apply_coupon(120.0, "TEN") == 108.0

def test_vacuous():
    assert apply_coupon(120.0, "TEN")

def test_clamp_at_limit():
    assert clamp(5, 5) == 5
'''

COUPON_IGNORED = {
    "name": "coupon ignored",
    "file": "orders.py",
    "find": "return round(subtotal * (1 - COUPONS[code]), 2)",
    "replace": "return round(subtotal, 2)",
}
# For clamp(5, 5) both branches return 5: this changes nothing observable.
EQUIVALENT = {
    "name": "clamp boundary (equivalent)",
    "file": "orders.py",
    "find": "x < limit",
    "replace": "x <= limit",
}
# Renames a function the test module imports: the whole file fails to collect.
PLUMBING = {
    "name": "rename clamp (plumbing)",
    "file": "orders.py",
    "find": "def clamp",
    "replace": "def clamp_renamed",
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


@pytest.fixture
def project(tmp_path):
    (tmp_path / "orders.py").write_text(SUBJECT)
    (tmp_path / "test_orders.py").write_text(TESTS)
    return tmp_path


def run_harness(project: Path, mutations, test_cmd=PYTEST_CMD, junit="report.xml", extra=()):
    spec = project / "mutations.json"
    spec.write_text(json.dumps(mutations))
    out = project / "out.json"
    cmd = [sys.executable, str(HARNESS), "--project", str(project), "--spec", str(spec),
           "--test-cmd", test_cmd, "--json-out", str(out), *extra]
    if junit:
        cmd += ["--junit", junit]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    result = json.loads(out.read_text()) if out.exists() else None
    return proc, result


# --- baseline -----------------------------------------------------------------

def test_command_not_found_is_reported_as_not_run_not_red(project):
    proc, result = run_harness(project, [COUPON_IGNORED],
                               test_cmd="definitely-not-a-command --junit-xml=report.xml")
    assert proc.returncode == 1
    assert "DID NOT RUN" in proc.stdout
    assert "Suite is RED" not in proc.stdout
    assert "definitely-not-a-command" in proc.stdout    # the shell's error is shown
    assert result is None


def test_command_not_found_without_junit_is_still_not_run(project):
    # Without --junit the only signal that the command never executed is the
    # shell's 126/127 exit code; it must not be read as a red suite.
    proc, result = run_harness(project, [COUPON_IGNORED],
                               test_cmd="definitely-not-a-command", junit=None)
    assert proc.returncode == 1
    assert "DID NOT RUN" in proc.stdout
    assert "Suite is RED" not in proc.stdout
    assert result is None


def test_red_baseline_stops_and_shows_output(project):
    (project / "test_orders.py").write_text(TESTS + "\ndef test_broken():\n    assert 1 == 2\n")
    proc, result = run_harness(project, [COUPON_IGNORED])
    assert proc.returncode == 1
    assert "Suite is RED" in proc.stdout
    assert "test_broken" in proc.stdout                  # tail of pytest output is shown
    assert result is None
    assert "return round(subtotal, 2)" not in (project / "orders.py").read_text()


def test_baseline_skips_are_counted_and_excluded(project):
    (project / "test_orders.py").write_text(
        "import pytest\n" + TESTS + "\n@pytest.mark.skip\ndef test_skipped():\n    assert 0\n")
    proc, result = run_harness(project, [COUPON_IGNORED])
    assert proc.returncode == 0
    assert "3 tests, 1 skipped" in proc.stdout
    assert "test_orders::test_skipped" not in result["baseline_tests"]


# --- classification -----------------------------------------------------------

def test_real_test_catches_and_vacuous_test_survives(project):
    proc, result = run_harness(project, [COUPON_IGNORED])
    assert proc.returncode == 0
    assert result["statuses"]["coupon ignored"] == "caught"
    row = result["matrix"]["coupon ignored"]
    assert row["test_orders::test_real"] == "fail"
    assert row["test_orders::test_vacuous"] == "pass"
    assert "coupon ignored" in proc.stdout and "caught by 1" in proc.stdout
    assert "test_orders::test_vacuous" in proc.stdout.split("never failed")[1]


def test_equivalent_mutant_is_reported_as_survived_with_caveat(project):
    proc, result = run_harness(project, [EQUIVALENT])
    assert result["statuses"]["clamp boundary (equivalent)"] == "survived"
    assert result["survived_mutations"] == ["clamp boundary (equivalent)"]
    assert "equivalent mutant" in proc.stdout


def test_collection_error_is_plumbing_not_caught(project):
    proc, result = run_harness(project, [PLUMBING])
    assert proc.returncode == 0
    assert result["statuses"]["rename clamp (plumbing)"] == "plumbing"
    assert result["plumbing_mutations"] == ["rename clamp (plumbing)"]
    assert "BROKE THE PLUMBING" in proc.stdout
    assert "caught by" not in proc.stdout


def test_tests_absent_from_a_run_are_not_treated_as_green(project):
    proc, result = run_harness(project, [PLUMBING])
    row = result["matrix"]["rename clamp (plumbing)"]
    assert set(row.values()) == {"absent"}
    # test_real never failed on an assertion, but the report must say its one
    # run was uninformative rather than silently listing it as a survivor.
    assert "test_orders::test_real   (errored/absent under 1" in proc.stdout


def test_fixture_error_is_error_not_fail(project):
    (project / "test_orders.py").write_text(
        "import pytest\nfrom orders import apply_coupon\n"
        "@pytest.fixture\ndef fx():\n    return apply_coupon(120.0, 'TEN')\n"
        "def test_via_fixture(fx):\n    assert fx == 108.0\n")
    # Make the subject raise inside the fixture: pytest reports <error>, not <failure>.
    raising = {"name": "raise in subject", "file": "orders.py",
               "find": "return round(subtotal * (1 - COUPONS[code]), 2)",
               "replace": "raise RuntimeError('boom')"}
    proc, result = run_harness(project, [raising])
    assert result["matrix"]["raise in subject"]["test_orders::test_via_fixture"] == "error"
    assert result["statuses"]["raise in subject"] == "plumbing"


def test_whole_suite_resolution_without_junit(project):
    proc, result = run_harness(project, [COUPON_IGNORED, EQUIVALENT],
                               test_cmd=f'"{sys.executable}" -m pytest -q -p no:cacheprovider',
                               junit=None)
    assert proc.returncode == 0
    assert "whole-suite resolution" in proc.stdout
    assert result["baseline_tests"] == {}
    assert result["statuses"] == {"coupon ignored": "red",
                                  "clamp boundary (equivalent)": "survived"}


# --- spec validation ----------------------------------------------------------

def test_spec_with_absent_find_text_mutates_nothing(project):
    bad = dict(COUPON_IGNORED, find="this text is not in the file")
    proc, result = run_harness(project, [COUPON_IGNORED, bad])
    assert proc.returncode == 1
    assert "nothing was mutated" in proc.stdout
    assert "not present" in proc.stdout
    assert result is None


def test_spec_with_ambiguous_find_text_is_rejected(project):
    ambiguous = dict(COUPON_IGNORED, find="return")
    proc, _ = run_harness(project, [ambiguous])
    assert proc.returncode == 1
    assert "appears 2 times" in proc.stdout


def test_spec_missing_keys_is_rejected(project):
    proc, _ = run_harness(project, [{"name": "half a spec", "file": "orders.py"}])
    assert proc.returncode == 1
    assert "missing ['find', 'replace']" in proc.stdout


# --- safety -------------------------------------------------------------------

def test_subject_is_byte_identical_after_every_mutation(project):
    before = sha(project / "orders.py")
    proc, _ = run_harness(project, [COUPON_IGNORED, PLUMBING, EQUIVALENT])
    assert proc.returncode == 0
    assert sha(project / "orders.py") == before
    assert "verified byte-identical" in proc.stdout


def test_subject_is_restored_when_test_command_dies_mid_run(project):
    # The test command itself fails to execute for the mutation run; restoration
    # must still happen and the mutation must be reported as not run.
    before = sha(project / "orders.py")
    # First run is the baseline (green); a marker file flips the command to a failure.
    script = project / "flaky_cmd.py"
    script.write_text(
        "import sys, os, subprocess\n"
        "if os.path.exists('marker'):\n    sys.exit(127)\n"
        "open('marker', 'w').close()\n"
        f"sys.exit(subprocess.call({PYTEST_CMD!r}, shell=True))\n")
    proc, result = run_harness(project, [COUPON_IGNORED],
                               test_cmd=f'"{sys.executable}" flaky_cmd.py',
                               extra=["--skip-final-run"])
    assert sha(project / "orders.py") == before
    assert result["statuses"]["coupon ignored"] == "not_run"
    assert "DID NOT RUN" in proc.stdout


def test_hanging_mutation_times_out_and_audit_continues(project):
    # The mutation makes apply_coupon spin forever; with --timeout the run is
    # killed, reported as timed out (neither caught nor survived), the subject is
    # restored, and the next mutation still runs.
    hang = {"name": "hang", "file": "orders.py",
            "find": "return round(subtotal * (1 - COUPONS[code]), 2)",
            "replace": "\n    while True:\n        pass"}
    before = sha(project / "orders.py")
    proc, result = run_harness(project, [hang, EQUIVALENT], extra=["--timeout", "8"])
    assert proc.returncode == 0
    assert result["statuses"] == {"hang": "timeout", "clamp boundary (equivalent)": "survived"}
    assert result["timed_out_mutations"] == ["hang"]
    assert "hang" not in result["survived_mutations"]
    assert "TIMED OUT" in proc.stdout
    assert sha(project / "orders.py") == before
    # a killed run writes no JUnit file, so every baseline test is absent from it
    assert set(result["matrix"]["hang"].values()) == {"absent"}


def test_timeout_kills_the_whole_process_tree(project):
    # The test command spawns a grandchild that would outlive a kill aimed only
    # at the shell. It writes its own pid so the test can check that exact process.
    script = project / "spawner.py"
    script.write_text(
        "import subprocess, sys\n"
        "child = subprocess.Popen([sys.executable, '-c', "
        "'import os, time; open(\"grandchild.pid\", \"w\").write(str(os.getpid())); time.sleep(60)'])\n"
        "child.wait()\n")
    proc, result = run_harness(project, [COUPON_IGNORED],
                               test_cmd=f'"{sys.executable}" spawner.py', junit=None,
                               extra=["--timeout", "3", "--skip-final-run"])
    assert "BASELINE TIMED OUT" in proc.stdout
    assert proc.returncode == 1
    import os, time
    pid = int((project / "grandchild.pid").read_text())
    deadline = time.time() + 5
    while time.time() < deadline:
        try:
            os.kill(pid, 0)
        except ProcessLookupError:
            break
        # still exists: may be a zombie awaiting reap, or genuinely alive
        if open(f"/proc/{pid}/stat").read().split()[2] == "Z":
            break
        time.sleep(0.1)
    else:
        os.kill(pid, 9)
        raise AssertionError(f"grandchild {pid} survived the timeout kill")


def test_sigterm_mid_run_restores_the_subject(project):
    # Start the harness with a slow test command, SIGTERM it while a mutation is
    # applied, and check the subject is byte-identical afterwards.
    import os, signal, time
    before = sha(project / "orders.py")
    slow = project / "slow_cmd.py"
    slow.write_text(
        "import os, sys, time, subprocess\n"
        "n = int(open('calls').read()) + 1 if os.path.exists('calls') else 1\n"
        "open('calls', 'w').write(str(n))\n"
        "if n == 1:\n"
        f"    sys.exit(subprocess.call({PYTEST_CMD!r}, shell=True))\n"
        "time.sleep(30)\n")
    spec = project / "mutations.json"
    spec.write_text(json.dumps([COUPON_IGNORED]))
    proc = subprocess.Popen(
        [sys.executable, str(HARNESS), "--project", str(project), "--spec", str(spec),
         "--test-cmd", f'"{sys.executable}" slow_cmd.py', "--junit", "report.xml"],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    deadline = time.time() + 20
    while time.time() < deadline:
        if (project / "calls").exists() and (project / "calls").read_text() == "2" \
                and "return round(subtotal, 2)" in (project / "orders.py").read_text():
            break
        time.sleep(0.1)
    else:
        proc.kill()
        raise AssertionError("harness never reached the mutated run")
    proc.send_signal(signal.SIGTERM)
    out, _ = proc.communicate(timeout=20)
    assert sha(project / "orders.py") == before, out
    assert "RESTORATION FAILED" not in out
    # the in-flight suite run must not be left behind as an orphan
    time.sleep(0.3)
    left = subprocess.run(["pgrep", "-f", "slow_cmd.py"], capture_output=True, text=True).stdout.split()
    left = [pid for pid in left if os.path.exists(f"/proc/{pid}") and open(f"/proc/{pid}/stat").read().split()[2] != "Z"]
    for pid in left:
        os.kill(int(pid), 9)
    assert not left, f"suite run survived the harness: {left}"


def test_bytecode_writing_is_disabled_for_test_runs(project):
    probe = project / "probe.py"
    probe.write_text("import os, sys\n"
                     "open('env.txt', 'w').write(os.environ.get('PYTHONDONTWRITEBYTECODE', ''))\n"
                     "sys.exit(0)\n")
    run_harness(project, [COUPON_IGNORED], test_cmd=f'"{sys.executable}" probe.py', junit=None)
    assert (project / "env.txt").read_text() == "1"


def test_final_run_not_green_is_reported_and_exit_is_nonzero(project):
    # Baseline (call 1) and the mutation run (call 2) pass; the final run
    # (call 3) is made to fail, standing in for a stale build cache.
    script = project / "counting_cmd.py"
    script.write_text(
        "import sys, subprocess\n"
        "n = int(open('calls').read()) + 1 if __import__('os').path.exists('calls') else 1\n"
        "open('calls', 'w').write(str(n))\n"
        f"rc = subprocess.call({PYTEST_CMD!r}, shell=True)\n"
        "sys.exit(1 if n == 3 else rc)\n")
    proc, result = run_harness(project, [COUPON_IGNORED],
                               test_cmd=f'"{sys.executable}" counting_cmd.py')
    assert proc.returncode == 3
    assert "NOT GREEN" in proc.stdout
    assert "stale build or cache" in proc.stdout
    assert result["final_run_green"] is False
    assert result["statuses"]["coupon ignored"] == "caught"    # earlier results are still reported


def test_final_run_reports_green_and_can_be_skipped(project):
    proc, result = run_harness(project, [COUPON_IGNORED])
    assert "Final run against the restored tree" in proc.stdout
    assert result["final_run_green"] is True
    proc, result = run_harness(project, [COUPON_IGNORED], extra=["--skip-final-run"])
    assert "Final run" not in proc.stdout
    assert result["final_run_green"] is None
