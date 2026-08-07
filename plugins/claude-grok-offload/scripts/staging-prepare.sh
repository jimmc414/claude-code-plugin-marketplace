#!/usr/bin/env bash
# staging-prepare.sh — rsync copy of a non-repo tree for write-isolated impl
#
# Usage:
#   staging-prepare.sh <src-dir> [dest-dir]
#   Env:
#     CGO_STAGING_ROOT  optional base (default: $CGO_DATA/staging)
#
# Hardlink flags are refused: --link, -H, --hard-links, and rsync -H.
# Path-based sandboxes treat hardlink write as live inode write — isolation breaks.
#
# Stdout: absolute staging path
# Exit: 0 ok · 1 fail · 2 bad flags / usage
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

usage() {
  cat <<'EOF' >&2
Usage: staging-prepare.sh <src-dir> [dest-dir]

Copies src into an isolated staging directory (rsync -a --copy-links, or cp -R).
Rejects hardlink options (--link, -H, --hard-links).
Prints the staging absolute path on stdout.
EOF
}

# Scan argv for hardlink-related flags anywhere (caller may pass extra opts later)
for arg in "$@"; do
  case "$arg" in
    --link|-H|--hard-links|--hard-link)
      echo "staging-prepare: hardlink flags are forbidden ($arg) — path sandbox isolation breaks" >&2
      exit 2
      ;;
    -*H*|-*H)
      # cluster short opts containing H (e.g. -aH)
      if [[ "$arg" == -* && "$arg" != --* && "$arg" == *H* ]]; then
        echo "staging-prepare: hardlink short option H is forbidden ($arg)" >&2
        exit 2
      fi
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

SRC_IN="$1"
DEST_IN="${2:-}"

if [[ ! -d "$SRC_IN" ]]; then
  echo "staging-prepare: src not a directory: $SRC_IN" >&2
  exit 1
fi

SRC="$(cd "$SRC_IN" && pwd)"

is_temp_path() {
  local p="$1"
  case "$p" in
    /tmp|/tmp/*|/private/tmp|/private/tmp/*)
      return 0
      ;;
  esac
  return 1
}

if [[ -n "$DEST_IN" ]]; then
  DEST="$DEST_IN"
  # parent may not exist yet
  mkdir -p "$(dirname "$DEST")"
  if [[ "$DEST" != /* ]]; then
    DEST="$(cd "$(dirname "$DEST")" && pwd)/$(basename "$DEST")"
  fi
else
  ROOT="${CGO_STAGING_ROOT:-}"
  if [[ -z "$ROOT" ]]; then
    ROOT="$(cgo_data_dir)/staging"
  fi
  if is_temp_path "$ROOT"; then
    echo "staging-prepare: staging root must not be temp: $ROOT" >&2
    exit 1
  fi
  mkdir -p "$ROOT"
  ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
  DEST="${ROOT}/${ID}"
fi

if is_temp_path "$DEST"; then
  echo "staging-prepare: dest must not be under temp: $DEST" >&2
  exit 1
fi

if [[ -e "$DEST" ]]; then
  echo "staging-prepare: dest already exists: $DEST" >&2
  exit 1
fi

mkdir -p "$DEST"

# Prefer rsync without hardlinks; --copy-links expands symlinks into copies
if command -v rsync >/dev/null 2>&1; then
  # Explicitly avoid -H / --link. -a includes archive without hardlink.
  if ! rsync -a --copy-links "$SRC"/ "$DEST"/; then
    echo "staging-prepare: rsync failed" >&2
    rm -rf "$DEST"
    exit 1
  fi
else
  if ! cp -R "$SRC"/. "$DEST"/; then
    echo "staging-prepare: cp failed" >&2
    rm -rf "$DEST"
    exit 1
  fi
fi

# Optional: init git baseline so impl can tag/diff (best-effort)
if command -v git >/dev/null 2>&1; then
  (
    cd "$DEST"
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git init -q
      git add -A
      git commit -qm "cgo staging baseline" --allow-empty 2>/dev/null || true
      git tag -f cgo-baseline 2>/dev/null || true
    fi
  ) || true
fi

printf '%s\n' "$DEST"
exit 0
