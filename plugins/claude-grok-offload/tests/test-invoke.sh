#!/usr/bin/env bash
# invoke-grok.sh tests — mock env, temp HOME/CLAUDE_PLUGIN_DATA, --print-only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INVOKE="$PLUGIN_ROOT/scripts/invoke-grok.sh"
ENV_LIB="$PLUGIN_ROOT/scripts/lib/cgo-env.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

assert_out() {
  local name="$1" expected="$2" actual="$3"
  if printf '%s' "$actual" | grep -qF -- "$expected"; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]: expected substring: $expected" >&2
    echo "----- output -----" >&2
    printf '%s\n' "$actual" >&2
    fail=$((fail + 1))
  fi
}

assert_not_out() {
  local name="$1" banned="$2" actual="$3"
  if printf '%s' "$actual" | grep -qF -- "$banned"; then
    echo "FAIL [$name]: banned substring present: $banned" >&2
    printf '%s\n' "$actual" >&2
    fail=$((fail + 1))
  else
    pass=$((pass + 1))
  fi
}

assert_exit() {
  local name="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]: exit want=$want got=$got" >&2
    fail=$((fail + 1))
  fi
}

make_mock_grok() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"
  cat >"$bin_dir/grok" <<'EOF'
#!/usr/bin/env bash
# test mock — never network
echo "mock-grok: $*"
exit 0
EOF
  chmod +x "$bin_dir/grok"
}

write_env() {
  # write_env DATA_DIR KEY=VAL ...
  local data="$1"
  shift
  mkdir -p "$data"
  : >"$data/cgo-env"
  local kv
  for kv in "$@"; do
    printf '%s\n' "$kv" >>"$data/cgo-env"
  done
}

# ---------- Case 1: missing cgo-env → exit 2 ----------
CASE1="$TMP/case1"
mkdir -p "$CASE1/home" "$CASE1/data" "$CASE1/bin"
make_mock_grok "$CASE1/bin"
export HOME="$CASE1/home"
export CLAUDE_PLUGIN_DATA="$CASE1/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE1/bin:/usr/bin:/bin"
unset GROK_BINARY || true
rm -f "$CLAUDE_PLUGIN_DATA/cgo-env"
set +e
out1="$("$INVOKE" --mode grill --print-only 2>&1)"
rc1=$?
set -e
assert_exit "case1-exit-2" "2" "$rc1"
assert_out "case1-msg-check" "check" "$out1"

# ---------- Case 2: no-arg grill + staging → fixture in RUN_CWD, sandbox=strict ----------
CASE2="$TMP/case2"
mkdir -p "$CASE2/home" "$CASE2/data" "$CASE2/bin"
make_mock_grok "$CASE2/bin"
export HOME="$CASE2/home"
export CLAUDE_PLUGIN_DATA="$CASE2/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE2/bin:/usr/bin:/bin"
unset GROK_BINARY || true
write_env "$CASE2/data" "CGO_SANDBOX=strict" "CGO_STAGING=1"
set +e
out2="$("$INVOKE" --mode grill --print-only 2>&1)"
rc2=$?
set -e
assert_exit "case2-exit-0" "0" "$rc2"
assert_out "case2-sandbox-strict" "sandbox=strict" "$out2"
assert_out "case2-fixture-name" "first-run-design.md" "$out2"
assert_out "case2-run-cwd" "RUN_CWD=" "$out2"
# RUN_CWD under plugin data
run_cwd2="$(printf '%s\n' "$out2" | sed -n 's/^RUN_CWD=//p' | head -1)"
if [[ -n "$run_cwd2" && "$run_cwd2" == "$CASE2/data/runs/"* ]]; then
  pass=$((pass + 1))
else
  echo "FAIL [case2-run-under-data]: RUN_CWD=$run_cwd2" >&2
  fail=$((fail + 1))
fi
# staged file exists
if [[ -f "${run_cwd2}/first-run-design.md" ]]; then
  pass=$((pass + 1))
else
  echo "FAIL [case2-staged-file]: missing ${run_cwd2}/first-run-design.md" >&2
  fail=$((fail + 1))
fi
# never hardcode forbidden sandboxes in output
assert_not_out "case2-no-readonly" "sandbox=read-only" "$out2"
assert_not_out "case2-no-contract-ro" "sandbox=contract_ro" "$out2"
assert_out "case2-cmd-sandbox-flag" "--sandbox strict" "$out2"

# ---------- Case 3: write mode without CGO_SANDBOX_WRITE → exit 2 ----------
CASE3="$TMP/case3"
mkdir -p "$CASE3/home" "$CASE3/data" "$CASE3/bin"
make_mock_grok "$CASE3/bin"
export HOME="$CASE3/home"
export CLAUDE_PLUGIN_DATA="$CASE3/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE3/bin:/usr/bin:/bin"
write_env "$CASE3/data" "CGO_SANDBOX=strict" "CGO_STAGING=1"
# no CGO_SANDBOX_WRITE
set +e
out3="$("$INVOKE" --mode impl --print-only 2>&1)"
rc3=$?
set -e
assert_exit "case3-write-missing" "2" "$rc3"
assert_out "case3-msg-write" "CGO_SANDBOX_WRITE" "$out3"

# ---------- Case 4: write mode with key → sandbox=cgo_impl ----------
CASE4="$TMP/case4"
mkdir -p "$CASE4/home" "$CASE4/data" "$CASE4/bin"
make_mock_grok "$CASE4/bin"
export HOME="$CASE4/home"
export CLAUDE_PLUGIN_DATA="$CASE4/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE4/bin:/usr/bin:/bin"
write_env "$CASE4/data" "CGO_SANDBOX=cgo_ro" "CGO_STAGING=0" "CGO_SANDBOX_WRITE=cgo_impl"
# provide a dummy input for impl
printf 'spec\n' >"$CASE4/spec.md"
set +e
out4="$("$INVOKE" --mode impl --input "$CASE4/spec.md" --print-only 2>&1)"
rc4=$?
set -e
assert_exit "case4-exit-0" "0" "$rc4"
assert_out "case4-sandbox-write" "sandbox=cgo_impl" "$out4"
assert_not_out "case4-not-ro-sandbox" "sandbox=cgo_ro" "$out4"

# ---------- Case 5: cgo_ro + path outside grants → staged ----------
CASE5="$TMP/case5"
mkdir -p "$CASE5/home" "$CASE5/data" "$CASE5/bin" "$CASE5/outside"
make_mock_grok "$CASE5/bin"
export HOME="$CASE5/home"
export CLAUDE_PLUGIN_DATA="$CASE5/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE5/bin:/usr/bin:/bin"
write_env "$CASE5/data" "CGO_SANDBOX=cgo_ro" "CGO_STAGING=0"
printf 'outside design\n' >"$CASE5/outside/design.md"
set +e
out5="$("$INVOKE" --mode grill --input "$CASE5/outside/design.md" --print-only 2>&1)"
rc5=$?
set -e
assert_exit "case5-exit-0" "0" "$rc5"
assert_out "case5-sandbox-ro" "sandbox=cgo_ro" "$out5"
assert_out "case5-staged-flag" "staged=1" "$out5"
run_cwd5="$(printf '%s\n' "$out5" | sed -n 's/^RUN_CWD=//p' | head -1)"
if [[ -f "${run_cwd5}/design.md" ]]; then
  pass=$((pass + 1))
else
  echo "FAIL [case5-copy]: expected staged design.md under $run_cwd5" >&2
  fail=$((fail + 1))
fi

# ---------- Case 6: cgo_ro + path inside grant ($HOME/.claude) → live (no stage) ----------
CASE6="$TMP/case6"
mkdir -p "$CASE6/home/.claude/docs" "$CASE6/data" "$CASE6/bin"
make_mock_grok "$CASE6/bin"
export HOME="$CASE6/home"
export CLAUDE_PLUGIN_DATA="$CASE6/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE6/bin:/usr/bin:/bin"
write_env "$CASE6/data" "CGO_SANDBOX=cgo_ro" "CGO_STAGING=0"
printf 'granted design\n' >"$CASE6/home/.claude/docs/granted-design.md"
set +e
out6="$("$INVOKE" --mode grill --input "$CASE6/home/.claude/docs/granted-design.md" --print-only 2>&1)"
rc6=$?
set -e
assert_exit "case6-exit-0" "0" "$rc6"
assert_out "case6-staged-0" "staged=0" "$out6"
assert_out "case6-live-path" "$CASE6/home/.claude/docs/granted-design.md" "$out6"

# ---------- Case 7: refuse poisoned CGO_SANDBOX=read-only ----------
CASE7="$TMP/case7"
mkdir -p "$CASE7/home" "$CASE7/data" "$CASE7/bin"
make_mock_grok "$CASE7/bin"
export HOME="$CASE7/home"
export CLAUDE_PLUGIN_DATA="$CASE7/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE7/bin:/usr/bin:/bin"
write_env "$CASE7/data" "CGO_SANDBOX=read-only" "CGO_STAGING=1"
set +e
out7="$("$INVOKE" --mode grill --print-only 2>&1)"
rc7=$?
set -e
assert_exit "case7-refuse-readonly" "2" "$rc7"
assert_out "case7-msg" "read-only" "$out7"

# ---------- Case 8: verify fact keeps web (disable_web=0) ----------
CASE8="$TMP/case8"
mkdir -p "$CASE8/home" "$CASE8/data" "$CASE8/bin"
make_mock_grok "$CASE8/bin"
export HOME="$CASE8/home"
export CLAUDE_PLUGIN_DATA="$CASE8/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export PATH="$CASE8/bin:/usr/bin:/bin"
write_env "$CASE8/data" "CGO_SANDBOX=strict" "CGO_STAGING=1"
printf 'plan\n' >"$CASE8/plan.md"
set +e
out8="$("$INVOKE" --mode verify --verify-kind fact --input "$CASE8/plan.md" --print-only 2>&1)"
rc8=$?
set -e
assert_exit "case8-exit-0" "0" "$rc8"
assert_out "case8-web-on" "disable_web=0" "$out8"
assert_not_out "case8-no-disable-flag" "--disable-web-search" "$out8"

# grill default disables web
set +e
out8b="$("$INVOKE" --mode grill --print-only 2>&1)"
rc8b=$?
set -e
assert_exit "case8b-exit-0" "0" "$rc8b"
assert_out "case8b-web-off" "disable_web=1" "$out8b"
assert_out "case8b-flag" "--disable-web-search" "$out8b"

# ---------- Safety: RUN_CWD never HOME ----------
if printf '%s' "$out2$out5$out6" | grep -qE "^RUN_CWD=${HOME}$"; then
  echo "FAIL [safety]: RUN_CWD equals HOME" >&2
  fail=$((fail + 1))
else
  pass=$((pass + 1))
fi

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail assertion(s), $pass passed" >&2
  exit 1
fi
echo "OK ($pass assertions)"
exit 0
