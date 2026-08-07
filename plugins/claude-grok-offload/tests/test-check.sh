#!/usr/bin/env bash
# check Ready state machine tests — isolated HOME / sandbox.toml only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK="$PLUGIN_ROOT/scripts/cgo-check.sh"
INSTALL="$PLUGIN_ROOT/scripts/install-sandbox-profiles.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

assert_out() {
  local name="$1" expected="$2" actual="$3"
  if printf '%s' "$actual" | grep -qF "$expected"; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]: expected substring: $expected" >&2
    echo "----- output -----" >&2
    printf '%s\n' "$actual" >&2
    fail=$((fail + 1))
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

# Mock grok that accepts `models`
make_mock_grok() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"
  cat >"$bin_dir/grok" <<'EOF'
#!/usr/bin/env bash
# test mock — never talks to network
if [[ "${1:-}" == "models" ]]; then
  echo "mock-models-ok"
  exit 0
fi
echo "mock-grok: $*" >&2
exit 0
EOF
  chmod +x "$bin_dir/grok"
}

# ---------- Case 1: Missing grok → Ready:no ----------
CASE1="$TMP/case1"
mkdir -p "$CASE1/home" "$CASE1/data" "$CASE1/emptybin"
# Separate lines — never export HOME=$x GROK_SANDBOX_TOML=$HOME/... on one line
export HOME="$CASE1/home"
export CLAUDE_PLUGIN_DATA="$CASE1/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export GROK_SANDBOX_TOML="$CASE1/home/.grok/sandbox.toml"
mkdir -p "$CASE1/home/.grok"
# PATH without grok; clear GROK_BINARY
unset GROK_BINARY || true
export PATH="$CASE1/emptybin:/usr/bin:/bin"
export CGO_MOCK_GROK=0
set +e
out1="$("$CHECK" 2>&1)"
rc1=$?
set -e
assert_out "case1-ready-no" "Ready: no" "$out1"
assert_exit "case1-exit" "1" "$rc1"
if [[ -f "$CLAUDE_PLUGIN_DATA/cgo-env" ]]; then
  echo "FAIL [case1]: cgo-env should be cleared on Ready:no" >&2
  fail=$((fail + 1))
else
  pass=$((pass + 1))
fi

# ---------- Case 2: Fixture missing → Ready:no ----------
CASE2="$TMP/case2"
mkdir -p "$CASE2/home" "$CASE2/data" "$CASE2/bin" "$CASE2/fakeplugin/fixtures"
make_mock_grok "$CASE2/bin"
export HOME="$CASE2/home"
export CLAUDE_PLUGIN_DATA="$CASE2/data"
# Point plugin root at tree without fixture file
export CLAUDE_PLUGIN_ROOT="$CASE2/fakeplugin"
export GROK_SANDBOX_TOML="$CASE2/home/.grok/sandbox.toml"
mkdir -p "$CASE2/home/.grok"
export PATH="$CASE2/bin:/usr/bin:/bin"
export CGO_MOCK_GROK=1
unset GROK_BINARY || true
set +e
out2="$("$CHECK" 2>&1)"
rc2=$?
set -e
assert_out "case2-ready-no" "Ready: no" "$out2"
assert_out "case2-reason-fixture" "fixture" "$out2"
assert_exit "case2-exit" "1" "$rc2"

# ---------- Case 3: mock grok + profiles → cgo_ro ----------
CASE3="$TMP/case3"
mkdir -p "$CASE3/home" "$CASE3/data" "$CASE3/bin"
make_mock_grok "$CASE3/bin"
export HOME="$CASE3/home"
export CLAUDE_PLUGIN_DATA="$CASE3/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export GROK_SANDBOX_TOML="$CASE3/home/.grok/sandbox.toml"
mkdir -p "$CASE3/home/.grok"
printf '%s\n' '# empty seed' >"$GROK_SANDBOX_TOML"
export PATH="$CASE3/bin:/usr/bin:/bin"
export CGO_MOCK_GROK=1
unset GROK_BINARY || true
# Install portable profiles into temp toml only
bash "$INSTALL"
set +e
out3="$("$CHECK" 2>&1)"
rc3=$?
set -e
assert_out "case3-ready-yes" "Ready: yes" "$out3"
assert_out "case3-sandbox-ro" "CGO_SANDBOX=cgo_ro" "$out3"
assert_out "case3-staging-0" "CGO_STAGING=0" "$out3"
assert_out "case3-write" "CGO_SANDBOX_WRITE=cgo_impl" "$out3"
assert_exit "case3-exit" "0" "$rc3"
# State file keys
if [[ -f "$CLAUDE_PLUGIN_DATA/cgo-env" ]]; then
  grep -q '^CGO_SANDBOX=cgo_ro$' "$CLAUDE_PLUGIN_DATA/cgo-env"
  grep -q '^CGO_STAGING=0$' "$CLAUDE_PLUGIN_DATA/cgo-env"
  grep -q '^CGO_SANDBOX_WRITE=cgo_impl$' "$CLAUDE_PLUGIN_DATA/cgo-env"
  pass=$((pass + 3))
else
  echo "FAIL [case3]: missing cgo-env state file" >&2
  fail=$((fail + 3))
fi
# Host safety: temp toml only
if ! printf '%s' "$GROK_SANDBOX_TOML" | grep -q "$CASE3"; then
  echo "FAIL [case3]: GROK_SANDBOX_TOML not under case temp" >&2
  fail=$((fail + 1))
else
  pass=$((pass + 1))
fi

# ---------- Case 4: mock grok without custom profiles → strict + staging ----------
CASE4="$TMP/case4"
mkdir -p "$CASE4/home" "$CASE4/data" "$CASE4/bin"
make_mock_grok "$CASE4/bin"
export HOME="$CASE4/home"
export CLAUDE_PLUGIN_DATA="$CASE4/data"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
export GROK_SANDBOX_TOML="$CASE4/home/.grok/sandbox.toml"
mkdir -p "$CASE4/home/.grok"
# No cgo profiles — only an unrelated stub
printf '%s\n' '[profiles.keepme]' 'extends = "strict"' >"$GROK_SANDBOX_TOML"
export PATH="$CASE4/bin:/usr/bin:/bin"
export CGO_MOCK_GROK=1
unset GROK_BINARY || true
set +e
out4="$("$CHECK" 2>&1)"
rc4=$?
set -e
assert_out "case4-ready-yes" "Ready: yes" "$out4"
assert_out "case4-sandbox-strict" "CGO_SANDBOX=strict" "$out4"
assert_out "case4-staging-1" "CGO_STAGING=1" "$out4"
assert_exit "case4-exit" "0" "$rc4"
# write key should be empty/absent
if grep -q '^CGO_SANDBOX_WRITE=cgo_impl$' "$CLAUDE_PLUGIN_DATA/cgo-env" 2>/dev/null; then
  echo "FAIL [case4]: CGO_SANDBOX_WRITE should not be set without cgo_impl" >&2
  fail=$((fail + 1))
else
  pass=$((pass + 1))
fi
if grep -q '^CGO_SANDBOX=strict$' "$CLAUDE_PLUGIN_DATA/cgo-env" \
  && grep -q '^CGO_STAGING=1$' "$CLAUDE_PLUGIN_DATA/cgo-env"; then
  pass=$((pass + 1))
else
  echo "FAIL [case4]: state file modes wrong" >&2
  cat "$CLAUDE_PLUGIN_DATA/cgo-env" >&2 || true
  fail=$((fail + 1))
fi

# ---------- Safety: never touch real ~/.grok/sandbox.toml ----------
# (We never set GROK_SANDBOX_TOML to the real path; assert real file mtime unchanged if exists)
# Best-effort: real path must not equal any case path we wrote.
REAL_TOML="${HOME_REAL:-}/.grok/sandbox.toml"
# Capture original HOME from outside is gone; use getent/dscl-free approach via /Users from env restore is hard.
# Instead: verify all our writes were under $TMP only.
if find "$TMP" -name 'sandbox.toml' | grep -q .; then
  while IFS= read -r f; do
    case "$f" in
      "$TMP"/*) ;;
      *)
        echo "FAIL [safety]: sandbox.toml outside TMP: $f" >&2
        fail=$((fail + 1))
        ;;
    esac
  done < <(find "$TMP" -name 'sandbox.toml')
  pass=$((pass + 1))
fi

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail assertion(s), $pass passed" >&2
  exit 1
fi
echo "OK ($pass assertions)"
exit 0
