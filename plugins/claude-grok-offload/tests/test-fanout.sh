#!/usr/bin/env bash
# fanout_run.sh dry-run / refuse tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FANOUT="$PLUGIN_ROOT/scripts/fanout_run.sh"

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
assert_not_out() {
  local name="$1" banned="$2" actual="$3"
  if printf '%s' "$actual" | grep -qF -- "$banned"; then
    echo "FAIL [$name]: banned $banned" >&2; fail=$((fail + 1)); else pass=$((pass + 1)); fi
}

make_mock_grok() {
  mkdir -p "$1"
  cat >"$1/grok" <<'EOF'
#!/usr/bin/env bash
echo "mock-grok $*"
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

TREE="$TMP/tree"
mkdir -p "$TREE"
printf 'x\n' >"$TREE/f.txt"

# Case 1: missing env
CASE1="$TMP/c1"
mkdir -p "$CASE1/bin" "$CASE1/data" "$CASE1/home"
make_mock_grok "$CASE1/bin"
export HOME="$CASE1/home"
export CLAUDE_PLUGIN_DATA="$CASE1/data"
export PATH="$CASE1/bin:/usr/bin:/bin"
unset GROK_BINARY || true
set +e
out1="$("$FANOUT" --print-only R "$TREE" "hi" 2>&1)"
rc1=$?
set -e
assert_exit "c1-exit" "3" "$rc1"

# Case 2: R print-only — cwd=target, sandbox from env, no parent cd tmp
CASE2="$TMP/c2"
mkdir -p "$CASE2/bin" "$CASE2/data" "$CASE2/home"
make_mock_grok "$CASE2/bin"
export HOME="$CASE2/home"
export CLAUDE_PLUGIN_DATA="$CASE2/data"
export PATH="$CASE2/bin:/usr/bin:/bin"
write_env "$CASE2/data" "CGO_SANDBOX=strict" "CGO_STAGING=1"
set +e
out2="$("$FANOUT" --print-only R "$TREE" "probe" 2>&1)"
rc2=$?
set -e
assert_exit "c2-exit" "0" "$rc2"
assert_out "c2-mode" "mode=R" "$out2"
assert_out "c2-sandbox" "sandbox=strict" "$out2"
assert_out "c2-parent" "parent_cd_tmp=0" "$out2"
# cwd must be the tree (absolute), not /tmp alone as product force
assert_out "c2-cwd-tree" "cwd=" "$out2"
assert_not_out "c2-no-cd-tmp-force" "parent_cd_tmp=1" "$out2"
# ensure resolved tree path appears
abs_tree="$(cd "$TREE" && pwd)"
assert_out "c2-cwd-abs" "cwd=$abs_tree" "$out2"

# Case 3: W without write key
write_env "$CASE2/data" "CGO_SANDBOX=cgo_ro" "CGO_STAGING=0"
set +e
out3="$("$FANOUT" --print-only W "$TREE" "impl" 2>&1)"
rc3=$?
set -e
assert_exit "c3-exit" "3" "$rc3"
assert_out "c3-msg" "CGO_SANDBOX_WRITE" "$out3"

# Case 4: W with write key uses env value
write_env "$CASE2/data" "CGO_SANDBOX=cgo_ro" "CGO_SANDBOX_WRITE=cgo_impl" "CGO_STAGING=0"
set +e
out4="$("$FANOUT" --print-only W "$TREE" "impl" 2>&1)"
rc4=$?
set -e
assert_exit "c4-exit" "0" "$rc4"
assert_out "c4-sandbox-write" "sandbox=cgo_impl" "$out4"
assert_out "c4-mode-w" "mode=W" "$out4"

# Case 5: refuse read-only
write_env "$CASE2/data" "CGO_SANDBOX=read-only"
set +e
out5="$("$FANOUT" --print-only R "$TREE" "x" 2>&1)"
rc5=$?
set -e
assert_exit "c5-exit" "3" "$rc5"

# Case 6: usage
set +e
out6="$("$FANOUT" 2>&1)"
rc6=$?
set -e
assert_exit "c6-usage" "3" "$rc6"

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail, passed $pass" >&2
  exit 1
fi
echo "OK test-fanout ($pass assertions)"
exit 0
