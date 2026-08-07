#!/usr/bin/env bash
# worktree-prepare.sh — non-temp path + basic create
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WT_PREP="$PLUGIN_ROOT/scripts/worktree-prepare.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

assert_true() {
  local name="$1"
  if eval "$2"; then
    pass=$((pass + 1))
  else
    echo "FAIL [$name]" >&2
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

is_tmpish() {
  case "$1" in
    /tmp/*|/private/tmp/*|/var/folders/*|/private/var/folders/*) return 0 ;;
    *) return 1 ;;
  esac
}

# Fixture repo
REPO="$TMP/sample-repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email "test@example.com"
git -C "$REPO" config user.name "test"
printf 'hello\n' >"$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -qm "init"

# Case 1: worktree under repo/.cgo-worktrees
set +e
out1="$("$WT_PREP" "$REPO" 2>&1)"
rc1=$?
set -e
assert_exit "case1-exit" "0" "$rc1"
assert_true "case1-path-exists" "[[ -d \"$out1\" ]]"
assert_true "case1-has-marker" "[[ \"$out1\" == *\".cgo-worktrees\"* ]]"
# macOS may print /private/var/... — require .cgo-worktrees segment and that parent is the repo tree
assert_true "case1-under-repo" "[[ \"$(basename "$(dirname "$out1")")\" == \".cgo-worktrees\" ]]"
repo_base="$(basename "$REPO")"
assert_true "case1-repo-name" "[[ \"$out1\" == *\"/${repo_base}/.cgo-worktrees/\"* ]]"

# Case 2: CGO_WORKTREE_ROOT under temp must fail when TMP is temp-ish
# Force /tmp root (product must refuse — sandbox temp rules)
export CGO_WORKTREE_ROOT="/tmp/cgo-worktree-test-$$"
set +e
out2="$("$WT_PREP" "$REPO" 2>&1)"
rc2=$?
set -e
assert_exit "case2-temp-root-fail" "1" "$rc2"
assert_true "case2-msg" "printf '%s' \"$out2\" | grep -qi temp"
unset CGO_WORKTREE_ROOT
rm -rf "/tmp/cgo-worktree-test-$$" 2>/dev/null || true

# Case 3: missing repo
set +e
out3="$("$WT_PREP" "$TMP/no-such-repo" 2>&1)"
rc3=$?
set -e
assert_exit "case3-missing" "1" "$rc3"

# Case 4: non-git dir
mkdir -p "$TMP/notgit"
set +e
out4="$("$WT_PREP" "$TMP/notgit" 2>&1)"
rc4=$?
set -e
assert_exit "case4-nongit" "1" "$rc4"

# Case 5: usage
set +e
out5="$("$WT_PREP" 2>&1)"
rc5=$?
set -e
assert_exit "case5-usage" "2" "$rc5"

if [[ "$fail" -gt 0 ]]; then
  echo "FAILED: $fail assertion(s), $pass passed" >&2
  exit 1
fi
echo "OK test-worktree ($pass assertions)"
exit 0
