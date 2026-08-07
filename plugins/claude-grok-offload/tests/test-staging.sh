#!/usr/bin/env bash
# staging-prepare.sh — hardlink deny + copy works
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ST_PREP="$PLUGIN_ROOT/scripts/staging-prepare.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

assert_exit() {
  local name="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]: exit want=$want got=$got" >&2
    fail=$((fail + 1))
  fi
}

assert_true() {
  local name="$1"
  if eval "$2"; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]" >&2
    fail=$((fail + 1))
  fi
}

SRC="$TMP/src-tree"
mkdir -p "$SRC/sub"
printf 'live\n' >"$SRC/a.txt"
printf 'nested\n' >"$SRC/sub/b.txt"

# Use non-temp staging root when TMP is temp — put under plugin data mock
DATA="$TMP/data"
export CLAUDE_PLUGIN_DATA="$DATA"
export CGO_STAGING_ROOT="$DATA/staging"
# If DATA is under /tmp, staging-prepare will refuse. Use a sibling under $HOME test path.
# On CI, /tmp is standard — work around by only testing hardlink deny + explicit dest
# that we pre-check: when dest is under temp, script fails. For positive path, use dest
# that we create outside if possible.
# Simpler: mock is_temp by using CGO_STAGING_ROOT that is TMP — will fail on temp hosts.
# Positive test: pass explicit dest under TMP and temporarily patch? No — product refuses temp.
# Solution: positive test only when we can use a non-temp dir; else test hardlink + error paths.

# Case 1–3: hardlink flags → exit 2
set +e
out1="$("$ST_PREP" --link "$SRC" 2>&1)"
rc1=$?
set -e
assert_exit "case1-link" "2" "$rc1"
assert_true "case1-msg" "printf '%s' \"$out1\" | grep -qi hardlink"

set +e
out2="$("$ST_PREP" -H "$SRC" 2>&1)"
rc2=$?
set -e
assert_exit "case2-H" "2" "$rc2"

set +e
out3="$("$ST_PREP" --hard-links "$SRC" 2>&1)"
rc3=$?
set -e
assert_exit "case3-hard-links" "2" "$rc3"

# Case 4: clustered -aH
set +e
out4="$("$ST_PREP" -aH "$SRC" 2>&1)"
rc4=$?
set -e
assert_exit "case4-aH" "2" "$rc4"

# Case 5: missing src
set +e
out5="$("$ST_PREP" "$TMP/missing" 2>&1)"
rc5=$?
set -e
assert_exit "case5-missing" "1" "$rc5"

# Case 6: usage
set +e
out6="$("$ST_PREP" 2>&1)"
rc6=$?
set -e
assert_exit "case6-usage" "2" "$rc6"

# Case 7: positive copy — force non-temp via a path that is_temp_path accepts as OK.
# Product treats /var/folders and /tmp as temp. On macOS mktemp is under /var/folders.
# We reimplement a local positive path by calling rsync logic indirectly:
# Override: place staging under $PLUGIN_ROOT/.test-staging-$$ (plugin tree is non-temp)
STAGE_ROOT="$PLUGIN_ROOT/.test-staging-$$"
export CGO_STAGING_ROOT="$STAGE_ROOT"
trap 'rm -rf "$TMP" "$STAGE_ROOT"' EXIT

set +e
out7="$("$ST_PREP" "$SRC" 2>&1)"
rc7=$?
set -e
assert_exit "case7-copy-exit" "0" "$rc7"
assert_true "case7-path" "[[ -d \"$out7\" ]]"
assert_true "case7-file-a" "[[ -f \"$out7/a.txt\" ]]"
assert_true "case7-file-b" "[[ -f \"$out7/sub/b.txt\" ]]"
assert_true "case7-content" "grep -q live \"$out7/a.txt\""
# staged copy should not be same inode as source (not hardlinked)
if [[ -f "$out7/a.txt" && -f "$SRC/a.txt" ]]; then
  ino_s=$(stat -f %i "$SRC/a.txt" 2>/dev/null || stat -c %i "$SRC/a.txt")
  ino_d=$(stat -f %i "$out7/a.txt" 2>/dev/null || stat -c %i "$out7/a.txt")
  if [[ "$ino_s" != "$ino_d" ]]; then
    pass=$((pass + 1))
  else
    echo "FAIL [case7-inode]: same inode (hardlink leak)" >&2
    fail=$((fail + 1))
  fi
else
  fail=$((fail + 1))
fi

# mutate staging should not mutate src
printf 'mutated\n' >"$out7/a.txt"
assert_true "case7-isolation" "grep -q live \"$SRC/a.txt\""

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail assertion(s), $pass passed" >&2
  exit 1
fi
echo "OK test-staging ($pass assertions)"
exit 0
