#!/usr/bin/env bash
# sweep_run.sh dry-run / targets file
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SWEEP="$PLUGIN_ROOT/scripts/sweep_run.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

assert_exit() {
  local name="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then pass=$((pass + 1)); else
    echo "FAIL [$name]: exit want=$want got=$got" >&2; fail=$((fail + 1)); fi
}
assert_out() {
  local name="$1" expected="$2" actual="$3"
  if printf '%s' "$actual" | grep -qF -- "$expected"; then pass=$((pass + 1)); else
    echo "FAIL [$name]: expected $expected" >&2; printf '%s\n' "$actual" >&2; fail=$((fail + 1)); fi
}

make_mock_grok() {
  mkdir -p "$1"
  cat >"$1/grok" <<'EOF'
#!/usr/bin/env bash
echo "mock-sweep $*"
exit 0
EOF
  chmod +x "$1/grok"
}

write_env() {
  local data="$1"; shift
  mkdir -p "$data"
  : >"$data/cgo-env"
  for kv in "$@"; do printf '%s\n' "$kv" >>"$data/cgo-env"; done
}

# Fixture repo with a scannable file
REPO="$TMP/app"
mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email "t@example.com"
git -C "$REPO" config user.name "t"
printf 'echo hi\n' >"$REPO/run.sh"
git -C "$REPO" add run.sh
git -C "$REPO" commit -qm init

CASE="$TMP/c"
mkdir -p "$CASE/bin" "$CASE/data" "$CASE/home"
make_mock_grok "$CASE/bin"
export HOME="$CASE/home"
export CLAUDE_PLUGIN_DATA="$CASE/data"
export PATH="$CASE/bin:/usr/bin:/bin"
write_env "$CASE/data" "CGO_SANDBOX=strict" "CGO_STAGING=1"

TARGETS="$TMP/targets.txt"
printf '# comment\n%s\n' "$REPO" >"$TARGETS"

# Case 1: print-only with targets file
set +e
out1="$("$SWEEP" --print-only "$TARGETS" 2>&1)"
rc1=$?
set -e
assert_exit "c1-exit" "0" "$rc1"
assert_out "c1-sandbox" "sandbox=strict" "$out1"
assert_out "c1-count" "target_count=1" "$out1"
assert_out "c1-target" "target=$REPO" "$out1"
assert_out "c1-no-tmp-parent" "parent_cd_tmp=0" "$out1"

# Case 2: missing targets (empty home config)
set +e
out2="$("$SWEEP" --print-only 2>&1)"
rc2=$?
set -e
assert_exit "c2-no-targets" "3" "$rc2"

# Case 3: single repo arg
set +e
out3="$("$SWEEP" --print-only "$REPO" 2>&1)"
rc3=$?
set -e
assert_exit "c3-exit" "0" "$rc3"
assert_out "c3-target" "target=$REPO" "$out3"

# Case 4: real run with mock (should write sweep md)
set +e
out4="$("$SWEEP" "$TARGETS" 2>&1)"
rc4=$?
set -e
assert_exit "c4-run" "0" "$rc4"
# output under data/sweep
if ls "$CASE/data/sweep/"*.md >/dev/null 2>&1; then
  pass=$((pass + 1))
else
  echo "FAIL [c4-md]: no sweep md under $CASE/data/sweep" >&2
  ls -la "$CASE/data/sweep" 2>&1 || true
  fail=$((fail + 1))
fi

# Case 5: default config path
mkdir -p "$CASE/home/.config/claude-grok-offload"
printf '%s\n' "$REPO" >"$CASE/home/.config/claude-grok-offload/sweep-targets.txt"
set +e
out5="$("$SWEEP" --print-only 2>&1)"
rc5=$?
set -e
assert_exit "c5-default" "0" "$rc5"
assert_out "c5-target" "target=$REPO" "$out5"

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail, passed $pass" >&2
  exit 1
fi
echo "OK test-sweep ($pass assertions)"
exit 0
