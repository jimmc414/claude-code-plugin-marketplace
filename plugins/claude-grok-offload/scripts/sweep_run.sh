#!/usr/bin/env bash
# sweep_run.sh — generic batch audit (product)
#
# Usage:
#   sweep_run.sh [--print-only] [targets-file]
#   sweep_run.sh [--print-only] <single-repo-path>
#
# Targets file: one absolute path per line (# comments / blank skipped).
# Default targets file: $HOME/.config/claude-grok-offload/sweep-targets.txt
# Override: first arg if it is a file; or env CGO_SWEEP_TARGETS
#
# Each target: if git repo → git ls-files scan; else skip with message (product
# does not hardcode host non-repo recipes).
#
# Sandbox: $CGO_SANDBOX from cgo-env. CWD = each target.
# Output: $CGO_DATA/sweep/<ISO-WEEK>-<name>.md
#
# Exit: 0 all ok · 1 partial fail · 2 cap · 3 usage/env
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

PRINT_ONLY=0
if [[ "${1:-}" == "--print-only" ]]; then
  PRINT_ONLY=1
  shift
fi

DATA_DIR="$(cgo_data_dir)"
OUTDIR="${DATA_DIR}/sweep"
LOG="${DATA_DIR}/usage.log"
LOCK="${DATA_DIR}/.usage.lock"
CAP="${CGO_SWEEP_CAP:-20}"
WEEK="$(date -u +%G-W%V)"
DEFAULT_TARGETS="${HOME}/.config/claude-grok-offload/sweep-targets.txt"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
CONTRACT="${PLUGIN_ROOT}/prompts/sweep.md"

usage() {
  cat <<'EOF' >&2
Usage: sweep_run.sh [--print-only] [targets-file | single-repo-path]

Targets file default: ~/.config/claude-grok-offload/sweep-targets.txt
One absolute path per line. Example: examples/sweep-targets.example.txt
Requires Ready cgo-env (cgo-check.sh).
EOF
}

ENV_PATH="$(cgo_env_path)"
if [[ ! -f "$ENV_PATH" ]]; then
  echo "sweep_run: cgo-env missing — run cgo-check.sh first" >&2
  exit 3
fi

CGO_SANDBOX="$(cgo_env_read CGO_SANDBOX 2>/dev/null || true)"
if [[ -z "${CGO_SANDBOX:-}" ]]; then
  echo "sweep_run: CGO_SANDBOX unset" >&2
  exit 3
fi
if [[ "$CGO_SANDBOX" == "read-only" ]]; then
  echo "sweep_run: refuse CGO_SANDBOX=read-only" >&2
  exit 3
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
  echo "sweep_run: grok binary not found" >&2
  exit 3
fi

MODEL="${CGO_MODEL:-grok-4.5}"
EFFORT="${CGO_EFFORT:-high}"
MAX_TURNS="${CGO_MAX_TURNS:-30}"

cap_count() {
  local dow monday
  if [[ ! -f "$LOG" ]]; then
    echo 0
    return
  fi
  dow="$(date -u +%u)"
  if date -u -v-0d +%Y-%m-%d >/dev/null 2>&1; then
    monday="$(date -u -v-$((dow - 1))d +%Y-%m-%dT00:00:00Z)"
  else
    monday="$(date -u -d "$((dow - 1)) days ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -u +%Y-%m-%dT00:00:00Z)"
  fi
  awk -F'\t' -v t="$monday" '($2=="sweep" || $2=="sweep-fail") && $1>=t' "$LOG" 2>/dev/null | wc -l | tr -d ' '
}

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

file_list() {
  local repo="$1"
  git -C "$repo" ls-files 2>/dev/null \
    | grep -Ev '(^|/)(node_modules|__pycache__|dist|out|build|\.git)/' \
    | grep -E '\.(py|js|jsx|ts|tsx|sh|bash|rb|go|rs|swift|json|toml|yaml|yml)$' \
    | head -200
}

# Resolve target list
TARGETS=()
ARG1="${1:-}"
if [[ -n "$ARG1" ]]; then
  if [[ -f "$ARG1" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%#*}"
      line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      [[ -z "$line" ]] && continue
      TARGETS+=("$line")
    done <"$ARG1"
  elif [[ -d "$ARG1" ]]; then
    TARGETS+=("$ARG1")
  else
    echo "sweep_run: not a file or directory: $ARG1" >&2
    exit 3
  fi
elif [[ -n "${CGO_SWEEP_TARGETS:-}" && -f "${CGO_SWEEP_TARGETS}" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    TARGETS+=("$line")
  done <"$CGO_SWEEP_TARGETS"
elif [[ -f "$DEFAULT_TARGETS" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    TARGETS+=("$line")
  done <"$DEFAULT_TARGETS"
else
  echo "sweep_run: no targets — create $DEFAULT_TARGETS or pass a targets file" >&2
  usage
  exit 3
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "sweep_run: targets list empty" >&2
  exit 3
fi

mkdir -p "$OUTDIR"

if [[ "$PRINT_ONLY" -eq 1 ]]; then
  printf 'sandbox=%s\n' "$CGO_SANDBOX"
  printf 'week=%s\n' "$WEEK"
  printf 'outdir=%s\n' "$OUTDIR"
  printf 'target_count=%s\n' "${#TARGETS[@]}"
  for t in "${TARGETS[@]}"; do
    printf 'target=%s\n' "$t"
  done
  printf 'parent_cd_tmp=0\n'
  exit 0
fi

sweep_one() {
  local repo="$1" name out tmp files prompt rc
  name="$(basename "$repo")"
  if [[ ! -d "$repo" ]]; then
    echo "sweep_run: skip missing: $repo" >&2
    return 3
  fi
  if [[ ! -d "$repo/.git" ]] && ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "sweep_run: skip non-git (product has no non-repo recipe): $repo" >&2
    return 3
  fi
  if [[ "$(cap_count)" -ge "$CAP" ]]; then
    echo "sweep_run: weekly sweep cap reached ($(cap_count)/$CAP)" >&2
    return 2
  fi

  files="$(file_list "$repo")"
  if [[ -z "$files" ]]; then
    echo "sweep_run: no scan files: $name" >&2
    return 3
  fi

  out="${OUTDIR}/${WEEK}-${name}.md"
  if [[ -e "$out" ]]; then
    out="${OUTDIR}/${WEEK}-${name}-2.md"
  fi

  prompt="You did not author this code. Collect defect candidates only.
Read-only — do not modify files or change system state.

Target repo: ${repo} (CWD)
Scan list (stay inside; prioritize entry points):
${files}

If CLAUDE.md or PRINCIPLES.md exists at CWD root, read first (house style).

Audit axes:
1. silent failure — empty catch, broad except, silent fallback, unlogged failure
2. dead code — static zero-ref import/function only
3. TODO/FIXME — location and text only (no age judgment)
4. test gaps — core paths without tests
5. error path / log defects — unactionable messages, ignored exit codes

Output:
## Scan scope
(files actually read; note misses vs injected list)
## Candidates
- [candidate] axisN — file:line — one-line summary
  evidence: quoted code
(No verdict, no fix proposals, no praise.)"

  tmp="$(mktemp "${OUTDIR}/.sweep-${name}.XXXXXX")"
  set +e
  (
    cd "$repo"
    "$GROK_BIN" --single "$prompt" -m "$MODEL" --effort "$EFFORT" \
      --sandbox "$CGO_SANDBOX" \
      --tools "read_file,grep,list_dir" \
      --disable-web-search --no-auto-update --max-turns "$MAX_TURNS" \
      --cwd "$repo"
  ) >"$tmp" 2>&1
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    mv "$tmp" "$out"
    log_tag sweep "$name"
    echo "sweep_run: OK $name → $out"
  else
    mv "$tmp" "${out}.fail"
    log_tag sweep-fail "$name"
    echo "sweep_run: FAIL($rc) $name → ${out}.fail" >&2
  fi
  return "$rc"
}

failed=0
for repo in "${TARGETS[@]}"; do
  # expand ~
  case "$repo" in
    "~/"*) repo="${HOME}/${repo#~/}" ;;
  esac
  sweep_one "$repo"
  rc=$?
  if [[ "$rc" -eq 2 ]]; then
    exit 2
  fi
  if [[ "$rc" -ne 0 ]]; then
    failed=$((failed + 1))
  fi
done

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
exit 0
