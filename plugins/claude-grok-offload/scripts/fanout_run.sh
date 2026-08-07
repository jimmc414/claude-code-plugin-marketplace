#!/usr/bin/env bash
# fanout_run.sh — generic R|W fan-out wrapper (product)
#
# Usage:
#   fanout_run.sh R <target-cwd> "<prompt>"
#   fanout_run.sh W <worktree-or-cwd> "<prompt>"
#   fanout_run.sh --print-only R <target-cwd> "<prompt>"
#
# Mode R: child CWD = target path; sandbox = $CGO_SANDBOX (from cgo-env).
#          No parent `cd /tmp` — each child anchors to its target.
# Mode W: CWD = worktree; sandbox = $CGO_SANDBOX_WRITE.
#
# Cap (optional documented-tier): CGO_FANOUT_CAP (default 20) counted from
# $CGO_DATA/usage.log field2=fanout within the current UTC ISO week.
#
# Exit: 0 ok · 1 grok fail · 2 cap · 3 usage/env
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

PRINT_ONLY=0
if [[ "${1:-}" == "--print-only" ]]; then
  PRINT_ONLY=1
  shift
fi

MODE="${1:-}"
TARGET="${2:-}"
PROMPT="${3:-}"

usage() {
  cat <<'EOF' >&2
Usage: fanout_run.sh [--print-only] R <target-cwd> "<prompt>"
       fanout_run.sh [--print-only] W <worktree-cwd> "<prompt>"

R = read-only recon at target cwd with $CGO_SANDBOX
W = write impl at worktree cwd with $CGO_SANDBOX_WRITE
Requires Ready cgo-env (run cgo-check.sh first).
EOF
}

if [[ -z "$MODE" || -z "$TARGET" || -z "$PROMPT" ]]; then
  usage
  exit 3
fi

case "$MODE" in
  R|W) ;;
  *)
    usage
    exit 3
    ;;
esac

if [[ ! -d "$TARGET" ]]; then
  echo "fanout_run: target/cwd not a directory: $TARGET" >&2
  exit 3
fi

# Absolute target
TARGET="$(cd "$TARGET" && pwd)"

ENV_PATH="$(cgo_env_path)"
if [[ ! -f "$ENV_PATH" ]]; then
  echo "fanout_run: cgo-env missing — run cgo-check.sh first" >&2
  exit 3
fi

CGO_SANDBOX="$(cgo_env_read CGO_SANDBOX 2>/dev/null || true)"
CGO_SANDBOX_WRITE="$(cgo_env_read CGO_SANDBOX_WRITE 2>/dev/null || true)"

if [[ -z "${CGO_SANDBOX:-}" ]]; then
  echo "fanout_run: CGO_SANDBOX unset in cgo-env" >&2
  exit 3
fi
if [[ "$CGO_SANDBOX" == "read-only" ]]; then
  echo "fanout_run: refuse CGO_SANDBOX=read-only" >&2
  exit 3
fi

if [[ "$MODE" == "W" ]]; then
  if [[ -z "${CGO_SANDBOX_WRITE:-}" ]]; then
    echo "fanout_run: W mode requires CGO_SANDBOX_WRITE" >&2
    exit 3
  fi
  SANDBOX_VAL="$CGO_SANDBOX_WRITE"
else
  SANDBOX_VAL="$CGO_SANDBOX"
fi

# Optional weekly cap (documented-tier)
DATA_DIR="$(cgo_data_dir)"
LOG="${DATA_DIR}/usage.log"
CAP="${CGO_FANOUT_CAP:-20}"
LOCK="${DATA_DIR}/.usage.lock"

cap_count() {
  local dow monday
  if [[ ! -f "$LOG" ]]; then
    echo 0
    return
  fi
  dow="$(date -u +%u)"
  # macOS date -v; Linux date -d
  if date -u -v-0d +%Y-%m-%d >/dev/null 2>&1; then
    monday="$(date -u -v-$((dow - 1))d +%Y-%m-%dT00:00:00Z)"
  else
    monday="$(date -u -d "$((dow - 1)) days ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -u +%Y-%m-%dT00:00:00Z)"
  fi
  awk -F'\t' -v t="$monday" '$2=="fanout" && $1>=t' "$LOG" 2>/dev/null | wc -l | tr -d ' '
}

if [[ "$(cap_count)" -ge "$CAP" ]]; then
  echo "fanout_run: weekly fanout cap reached ($(cap_count)/${CAP})" >&2
  exit 2
fi

resolve_grok() {
  if [[ -n "${GROK_BINARY:-}" ]]; then
    if [[ -x "$GROK_BINARY" ]]; then
      printf '%s\n' "$GROK_BINARY"
      return 0
    fi
    command -v "$GROK_BINARY" 2>/dev/null && return 0
    return 1
  fi
  command -v grok 2>/dev/null
}

if ! GROK_BIN="$(resolve_grok)"; then
  echo "fanout_run: grok binary not found" >&2
  exit 3
fi

MODEL="${CGO_MODEL:-grok-4.5}"
EFFORT="${CGO_EFFORT:-high}"
if [[ "$MODE" == "R" ]]; then
  MAX_TURNS="${CGO_MAX_TURNS:-30}"
else
  MAX_TURNS="${CGO_MAX_TURNS:-20}"
fi

detail="fanout-${MODE}:$(basename "$TARGET")"

if [[ "$PRINT_ONLY" -eq 1 ]]; then
  printf 'mode=%s\n' "$MODE"
  printf 'cwd=%s\n' "$TARGET"
  printf 'sandbox=%s\n' "$SANDBOX_VAL"
  printf 'parent_cd_tmp=0\n'
  printf 'GROK_BIN=%s\n' "$GROK_BIN"
  printf 'detail=%s\n' "$detail"
  printf 'cmd_preview=%s --single <prompt> -m %s --effort %s --sandbox %s --cwd %s\n' \
    "$GROK_BIN" "$MODEL" "$EFFORT" "$SANDBOX_VAL" "$TARGET"
  exit 0
fi

# Build command: CWD is the target — never force parent into /tmp
CMD=(
  "$GROK_BIN"
  --single "$PROMPT"
  -m "$MODEL"
  --effort "$EFFORT"
  --sandbox "$SANDBOX_VAL"
  --no-auto-update
  --max-turns "$MAX_TURNS"
  --cwd "$TARGET"
)
if [[ "$MODE" == "R" ]]; then
  CMD+=(--tools "read_file,grep,list_dir" --disable-web-search)
fi

set +e
(
  cd "$TARGET"
  "${CMD[@]}"
)
rc=$?
set -e

log_tag() {
  local tag="$1" det="$2" line
  mkdir -p "$DATA_DIR"
  line="$(printf '%s\t%s\t%s' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$tag" "$det")"
  if command -v flock >/dev/null 2>&1; then
    ( flock 9; printf '%s\n' "$line" >>"$LOG" ) 9>"$LOCK"
  else
    printf '%s\n' "$line" >>"$LOG"
  fi
}

# Success-only accounting (failed runs must not consume weekly cap)
if [[ "$rc" -eq 0 ]]; then
  log_tag fanout "$detail"
  if [[ "$MODE" == "W" ]]; then
    log_tag impl "$detail"
  fi
else
  echo "fanout_run: failed rc=$rc ($detail)" >&2
fi

exit "$rc"
