#!/usr/bin/env bash
# worktree-prepare.sh — create an isolated non-temp git worktree for impl/fanout-W
#
# Usage:
#   worktree-prepare.sh <repo> [base-ref]
#   base-ref default: HEAD  (pass a branch name, or omit for detach at HEAD)
#   Env:
#     CGO_WORKTREE_ROOT  optional base for worktrees (default: <repo>/.cgo-worktrees)
#     CLAUDE_PLUGIN_DATA / HOME — fallback via cgo_data_dir when root unset
#
# Stdout: absolute worktree path (single line)
# Exit: 0 ok · 1 fail · 2 usage
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

usage() {
  cat <<'EOF' >&2
Usage: worktree-prepare.sh <repo> [base-ref]

Creates a detached (or branch-tracking) worktree under a non-temp path.
Prints the worktree absolute path on stdout.

base-ref defaults to HEAD. Worktree path is never under /tmp or $TMPDIR.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

REPO_IN="$1"
BASE_REF="${2:-HEAD}"

if [[ ! -d "$REPO_IN" ]]; then
  echo "worktree-prepare: repo not found: $REPO_IN" >&2
  exit 1
fi

# Normalize repo to absolute toplevel when possible
if git -C "$REPO_IN" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO="$(git -C "$REPO_IN" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "${REPO:-}" ]]; then
    REPO="$(cd "$REPO_IN" && pwd)"
  fi
else
  echo "worktree-prepare: not a git work tree: $REPO_IN" >&2
  exit 1
fi

# Prefer repo-local .cgo-worktrees; allow override
if [[ -n "${CGO_WORKTREE_ROOT:-}" ]]; then
  WT_ROOT="$CGO_WORKTREE_ROOT"
else
  WT_ROOT="${REPO}/.cgo-worktrees"
fi

# Refuse temp roots (sandbox temp rules make CWD isolation meaningless)
# Refuse pure system temp roots only.
# Repo-local .cgo-worktrees (even if the repo itself lives under mktemp in tests) is OK —
# isolation is relative to the main checkout. Sandbox "temp write allowed" risk is /tmp CWD.
is_temp_path() {
  local p="$1"
  case "$p" in
    /tmp|/tmp/*|/private/tmp|/private/tmp/*)
      return 0
      ;;
  esac
  return 1
}

if is_temp_path "$WT_ROOT"; then
  echo "worktree-prepare: worktree root must not be under a temp directory: $WT_ROOT" >&2
  exit 1
fi

mkdir -p "$WT_ROOT"

ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
# short hash of base for uniqueness
if HASH="$(git -C "$REPO" rev-parse --short "$BASE_REF" 2>/dev/null)"; then
  ID="${ID}-${HASH}"
fi
WT="${WT_ROOT}/${ID}"

if is_temp_path "$WT"; then
  echo "worktree-prepare: resolved worktree path is temp: $WT" >&2
  exit 1
fi

if [[ -e "$WT" ]]; then
  echo "worktree-prepare: path already exists: $WT" >&2
  exit 1
fi

# Detached worktree at BASE_REF (branch name or commit-ish)
# --detach keeps main checkout free of branch checkout conflicts.
if ! git -C "$REPO" worktree add --detach "$WT" "$BASE_REF" >/dev/null 2>&1; then
  # Some older git: need full error for operators
  if ! git -C "$REPO" worktree add --detach "$WT" "$BASE_REF"; then
    echo "worktree-prepare: git worktree add failed" >&2
    exit 1
  fi
fi

# Final guard: path must exist and still not be temp
if [[ ! -d "$WT" ]]; then
  echo "worktree-prepare: worktree missing after add: $WT" >&2
  exit 1
fi
if is_temp_path "$WT"; then
  echo "worktree-prepare: refusing temp worktree path: $WT" >&2
  git -C "$REPO" worktree remove --force "$WT" 2>/dev/null || true
  exit 1
fi

printf '%s\n' "$WT"
exit 0
