#!/usr/bin/env bash
# invoke-grok.sh — shell-out to real grok with cgo-env sandbox keys + staging
# Design: §4.7.1 input supply · §4.5 state keys only (no hardcode contract_ro / read-only)
#
# Usage:
#   invoke-grok.sh --mode grill|verify|judge|impl|fanout|sweep|heavy-burn \
#     [--print-only] [--input PATH]... [--prompt TEXT] [--verify-kind plan|code|fact] \
#     [--] [extra grok args]
#
# Exit:
#   0  ok (or print-only success)
#   1  grok / runtime failure
#   2  refuse-to-start (missing check env, missing write key, bad usage)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
FIXTURE="${PLUGIN_ROOT}/fixtures/first-run-design.md"

# --- defaults ---
MODE=""
PRINT_ONLY=0
VERIFY_KIND=""
PROMPT_TEXT=""
MODEL="${CGO_MODEL:-grok-4.5}"
EFFORT="${CGO_EFFORT:-high}"
MAX_TURNS="${CGO_MAX_TURNS:-20}"
INPUTS=()
EXTRA_ARGS=()

usage() {
  cat <<'EOF' >&2
Usage: invoke-grok.sh --mode MODE [options] [-- extra grok args]

Modes: grill | verify | judge | impl | fanout | sweep | heavy-burn

Options:
  --mode MODE           Required. Offload axis.
  --print-only          Print RUN_CWD / sandbox / inputs; do not run grok (tests).
  --input PATH          Input file path (repeatable). No-arg grill → fixture.
  --prompt TEXT         Prompt body override (else mode-default template).
  --verify-kind KIND    plan|code|fact (verify mode; fact may keep web search).
  --model ID            Default grok-4.5 (or CGO_MODEL).
  --effort LEVEL        Default high (or CGO_EFFORT).
  --max-turns N         Default 20.
  -h, --help            This help.

Requires Ready state from cgo-check.sh ($CGO_DATA/cgo-env).
EOF
}

# --- arg parse ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --mode needs a value" >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    --print-only)
      PRINT_ONLY=1
      shift
      ;;
    --input)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --input needs a path" >&2; exit 2; }
      INPUTS+=("$2")
      shift 2
      ;;
    --prompt)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --prompt needs text" >&2; exit 2; }
      PROMPT_TEXT="$2"
      shift 2
      ;;
    --verify-kind)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --verify-kind needs plan|code|fact" >&2; exit 2; }
      VERIFY_KIND="$2"
      shift 2
      ;;
    --model)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --model needs an id" >&2; exit 2; }
      MODEL="$2"
      shift 2
      ;;
    --effort)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --effort needs a level" >&2; exit 2; }
      EFFORT="$2"
      shift 2
      ;;
    --max-turns)
      [[ $# -ge 2 ]] || { echo "invoke-grok: --max-turns needs N" >&2; exit 2; }
      MAX_TURNS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      EXTRA_ARGS+=("$@")
      break
      ;;
    -*)
      echo "invoke-grok: unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      # bare path → treat as input
      INPUTS+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "invoke-grok: --mode is required" >&2
  usage
  exit 2
fi

case "$MODE" in
  grill|verify|judge|impl|fanout|sweep|heavy-burn) ;;
  *)
    echo "invoke-grok: unknown mode: $MODE" >&2
    exit 2
    ;;
esac

# --- load cgo-env (Ready gate) ---
ENV_PATH="$(cgo_env_path)"
if [[ ! -f "$ENV_PATH" ]]; then
  echo "invoke-grok: cgo-env missing ($ENV_PATH) — run /claude-grok-offload:check (or scripts/cgo-check.sh) first" >&2
  exit 2
fi

CGO_SANDBOX="$(cgo_env_read CGO_SANDBOX 2>/dev/null || true)"
CGO_STAGING="$(cgo_env_read CGO_STAGING 2>/dev/null || true)"
CGO_SANDBOX_WRITE="$(cgo_env_read CGO_SANDBOX_WRITE 2>/dev/null || true)"

if [[ -z "${CGO_SANDBOX:-}" ]]; then
  echo "invoke-grok: CGO_SANDBOX unset in cgo-env — re-run check" >&2
  exit 2
fi

# Invariant: never pass built-in read-only or host contract_ro as a product hardcode.
# Values must come from check. Refuse known-forbidden product defaults if env is poisoned.
if [[ "$CGO_SANDBOX" == "read-only" ]]; then
  echo "invoke-grok: refuse CGO_SANDBOX=read-only (product forbids built-in read-only; re-run check)" >&2
  exit 2
fi

# Write vs RO axis
is_write_mode=0
case "$MODE" in
  impl) is_write_mode=1 ;;
  fanout)
    # fanout W when CGO_FANOUT_WRITE=1 (caller) or --verify-kind unused; default R
    if [[ "${CGO_FANOUT_WRITE:-0}" == "1" ]]; then
      is_write_mode=1
    fi
    ;;
esac

SANDBOX_VAL=""
if [[ "$is_write_mode" -eq 1 ]]; then
  if [[ -z "${CGO_SANDBOX_WRITE:-}" ]]; then
    echo "invoke-grok: write mode '$MODE' requires CGO_SANDBOX_WRITE (install cgo_impl + re-run check)" >&2
    exit 2
  fi
  SANDBOX_VAL="$CGO_SANDBOX_WRITE"
else
  SANDBOX_VAL="$CGO_SANDBOX"
fi

# --- resolve grok binary ---
resolve_grok() {
  if [[ -n "${GROK_BINARY:-}" ]]; then
    if [[ -x "$GROK_BINARY" ]]; then
      printf '%s\n' "$GROK_BINARY"
      return 0
    fi
    if command -v "$GROK_BINARY" >/dev/null 2>&1; then
      command -v "$GROK_BINARY"
      return 0
    fi
    return 1
  fi
  command -v grok 2>/dev/null
}

GROK_BIN=""
if ! GROK_BIN="$(resolve_grok)"; then
  echo "invoke-grok: grok binary not found (PATH or GROK_BINARY)" >&2
  exit 2
fi

# --- input selection (fixture for no-arg grill) ---
if [[ ${#INPUTS[@]} -eq 0 ]]; then
  if [[ "$MODE" == "grill" ]]; then
    if [[ ! -f "$FIXTURE" || ! -s "$FIXTURE" ]]; then
      echo "invoke-grok: fixture missing/empty: $FIXTURE" >&2
      exit 2
    fi
    INPUTS=("$FIXTURE")
  else
    # verify/judge/etc with no input: still create run dir but warn
    :
  fi
fi

# --- grant roots (cgo_ro portable grants from fragment) ---
# When CGO_STAGING=1 (strict fallback), always stage — grant check unused.
grant_roots=()
if [[ "${CGO_STAGING:-0}" != "1" ]]; then
  # Portable product grants (mirrors cgo_ro fragment)
  grant_roots+=("${HOME}/.claude" "${HOME}/.grok/docs")
fi

path_under() {
  # path_under NEEDLE ROOT — true if NEEDLE is ROOT or under ROOT
  local needle="$1" root="$2"
  local n r
  n="$(cd "$(dirname "$needle")" 2>/dev/null && pwd)/$(basename "$needle")"
  r="$(cd "$root" 2>/dev/null && pwd)" || return 1
  [[ "$n" == "$r" || "$n" == "$r"/* ]]
}

path_in_grants() {
  local p="$1" g
  [[ ${#grant_roots[@]} -eq 0 ]] && return 1
  for g in "${grant_roots[@]}"; do
    if path_under "$p" "$g"; then
      return 0
    fi
  done
  return 1
}

need_stage_path() {
  local p="$1"
  # Always stage fixture (package path; S1 path)
  if [[ "$p" == "$FIXTURE" ]]; then
    return 0
  fi
  if [[ "${CGO_STAGING:-0}" == "1" ]]; then
    return 0
  fi
  if path_in_grants "$p"; then
    return 1
  fi
  return 0
}

# --- create run dir ---
DATA_DIR="$(cgo_data_dir)"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
RUN_CWD="${DATA_DIR}/runs/${RUN_ID}"
mkdir -p "$RUN_CWD"

# Never use HOME as long-run CWD
if [[ "$RUN_CWD" == "$HOME" || "$RUN_CWD" == "${HOME}/" ]]; then
  echo "invoke-grok: internal error: RUN_CWD must not be HOME" >&2
  exit 2
fi

# --- stage or keep live ---
RESOLVED_INPUTS=()
STAGED_ANY=0
for src in "${INPUTS[@]+"${INPUTS[@]}"}"; do
  if [[ -z "$src" ]]; then
    continue
  fi
  if [[ ! -e "$src" ]]; then
    echo "invoke-grok: input not found: $src" >&2
    exit 2
  fi
  # Normalize to absolute
  if [[ "$src" != /* ]]; then
    src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
  fi
  if need_stage_path "$src"; then
    base="$(basename "$src")"
    dest="${RUN_CWD}/${base}"
    # Avoid clobber: unique name if exists
    if [[ -e "$dest" ]]; then
      dest="${RUN_CWD}/$(printf '%s' "$base" | sed 's/\./-/g')-$$"
      # keep extension-ish: just append suffix before reuse of name
      dest="${RUN_CWD}/${base}.$$"
    fi
    if [[ -d "$src" ]]; then
      # copy tree (no hardlink)
      mkdir -p "$dest"
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --copy-links "$src"/ "$dest"/
      else
        cp -R "$src"/. "$dest"/
      fi
    else
      cp "$src" "$dest"
    fi
    RESOLVED_INPUTS+=("$dest")
    STAGED_ANY=1
  else
    RESOLVED_INPUTS+=("$src")
  fi
done

# Primary design/input path for prompt
PRIMARY=""
if [[ ${#RESOLVED_INPUTS[@]} -gt 0 ]]; then
  PRIMARY="${RESOLVED_INPUTS[0]}"
fi

# --- load stripped contracts from prompts/*.md (Task 4) ---
# Extract first fenced ``` block after a "Prompt body" heading; substitute placeholders.
extract_prompt_body() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  # awk: after seeing Prompt body heading, capture first ``` … ``` fence
  awk '
    BEGIN { in_body=0; in_fence=0 }
    /^##[ ]+[Pp]rompt[ ]+body/ { in_body=1; next }
    in_body && /^```/ {
      if (in_fence==0) { in_fence=1; next }
      else { exit }
    }
    in_fence { print }
  ' "$file"
}

substitute_placeholders() {
  # stdin → stdout with common placeholders replaced
  local design="${PRIMARY:-}"
  local ssot=""
  local ctx=""
  local i
  if [[ ${#RESOLVED_INPUTS[@]} -gt 0 ]]; then
    # PRIMARY is [0]; remaining inputs are SSOT/context
    local rest=()
    for ((i=1; i<${#RESOLVED_INPUTS[@]}; i++)); do
      rest+=("${RESOLVED_INPUTS[$i]}")
    done
    if [[ ${#rest[@]} -gt 0 ]]; then
      ssot=$(IFS=', '; echo "${rest[*]}")
      ctx="$ssot"
    fi
  fi
  local mode_kind="${VERIFY_KIND:-plan}"
  local axes="${CGO_JUDGE_AXES:-cost, reversibility, ops burden, security}"
  local principles="${CGO_PRINCIPLES_PATHS:-}"
  # sed-safe: use python if available for robust replace; else bash parameter expansion via env
  if command -v python3 >/dev/null 2>&1; then
    DESIGN_PATH="$design" SSOT_PATHS="$ssot" TARGET_PATH="$design" \
    MODE_KIND="$mode_kind" CONTEXT_PATHS="$ctx" AXES="$axes" \
    PRINCIPLES_PATHS="$principles" \
    python3 -c '
import os, sys
t = sys.stdin.read()
repl = {
  "{{DESIGN_PATH}}": os.environ.get("DESIGN_PATH",""),
  "{{SSOT_PATHS}}": os.environ.get("SSOT_PATHS","") or "(none listed)",
  "{{TARGET_PATH}}": os.environ.get("TARGET_PATH","") or "(missing)",
  "{{MODE}}": os.environ.get("MODE_KIND","plan"),
  "{{CONTEXT_PATHS}}": os.environ.get("CONTEXT_PATHS","") or "(none listed)",
  "{{AXES}}": os.environ.get("AXES","cost, reversibility, ops burden, security"),
  "{{PRINCIPLES_PATHS}}": os.environ.get("PRINCIPLES_PATHS","") or "(none)",
}
for k,v in repl.items():
  t = t.replace(k, v)
sys.stdout.write(t)
'
  else
    # minimal fallback
    local body
    body="$(cat)"
    body="${body//\{\{DESIGN_PATH\}\}/$design}"
    body="${body//\{\{TARGET_PATH\}\}/$design}"
    body="${body//\{\{SSOT_PATHS\}\}/${ssot:-(none listed)}}"
    body="${body//\{\{CONTEXT_PATHS\}\}/${ctx:-(none listed)}}"
    body="${body//\{\{MODE\}\}/$mode_kind}"
    body="${body//\{\{AXES\}\}/$axes}"
    body="${body//\{\{PRINCIPLES_PATHS\}\}/${principles:-(none)}}"
    printf '%s' "$body"
  fi
}

if [[ -z "$PROMPT_TEXT" ]]; then
  PROMPT_FILE="${PLUGIN_ROOT}/prompts/${MODE}.md"
  body=""
  if [[ -f "$PROMPT_FILE" ]]; then
    body="$(extract_prompt_body "$PROMPT_FILE" || true)"
  fi
  if [[ -n "${body//[$'\t\r\n ']/}" ]]; then
    PROMPT_TEXT="$(printf '%s\n' "$body" | substitute_placeholders)"
  else
    # Fallback short templates if prompt file missing (later modes until ported)
    case "$MODE" in
      grill)
        PROMPT_TEXT="You did not write this design. Assume defects and adversarially review it. Read-only: report findings and stop.
Target design: ${PRIMARY:-<missing>}
Procedure: read the design; list [fatal]/important]/note] findings with evidence quotes; end with verdict PASS or REVISE."
        ;;
      verify)
        PROMPT_TEXT="Verify the subject (${VERIFY_KIND:-plan/code/fact}). Target: ${PRIMARY:-<stdin/extra>}. Read-only. Report PASS or REVISE with evidence."
        ;;
      judge)
        PROMPT_TEXT="Judge the options in: ${PRIMARY:-<missing>}. Read-only. Compare trade-offs; recommend one with one-line rationale."
        ;;
      impl)
        PROMPT_TEXT="Implement per the five-slot spec in: ${PRIMARY:-<missing>}. Write only under CWD. No silent fallback."
        ;;
      fanout|sweep|heavy-burn)
        PROMPT_TEXT="Mode ${MODE}. Inputs: ${PRIMARY:-none}. Follow product contract for this mode."
        ;;
    esac
  fi
fi

# --- tools / web ---
TOOLS_ALLOW="read_file,grep,list_dir"
DISABLE_WEB=1
if [[ "$MODE" == "verify" && "$VERIFY_KIND" == "fact" ]]; then
  DISABLE_WEB=0
  TOOLS_ALLOW="read_file,grep,list_dir,web_search,web_fetch"
fi
if [[ "$is_write_mode" -eq 1 ]]; then
  # write modes: do not force RO tool allowlist (leave default / extra args)
  TOOLS_ALLOW=""
fi

# --- print-only report ---
inputs_joined=""
if [[ ${#RESOLVED_INPUTS[@]} -gt 0 ]]; then
  inputs_joined=$(IFS=,; echo "${RESOLVED_INPUTS[*]}")
fi

print_report() {
  printf 'mode=%s\n' "$MODE"
  printf 'RUN_CWD=%s\n' "$RUN_CWD"
  printf 'sandbox=%s\n' "$SANDBOX_VAL"
  printf 'CGO_STAGING=%s\n' "${CGO_STAGING:-}"
  printf 'staged=%s\n' "$STAGED_ANY"
  printf 'inputs=%s\n' "$inputs_joined"
  printf 'primary=%s\n' "${PRIMARY:-}"
  printf 'GROK_BIN=%s\n' "$GROK_BIN"
  printf 'model=%s\n' "$MODEL"
  printf 'effort=%s\n' "$EFFORT"
  printf 'disable_web=%s\n' "$DISABLE_WEB"
  if [[ -n "$TOOLS_ALLOW" ]]; then
    printf 'tools=%s\n' "$TOOLS_ALLOW"
  fi
  # Safety markers for tests
  printf 'forbidden_sandbox_read_only=0\n'
  printf 'hardcoded_contract_ro=0\n'
}

if [[ "$PRINT_ONLY" -eq 1 ]]; then
  print_report
  # Also show the conceptual argv (no execute)
  {
    printf 'cmd_preview=%s --single <prompt> -m %s --effort %s --sandbox %s' \
      "$GROK_BIN" "$MODEL" "$EFFORT" "$SANDBOX_VAL"
    if [[ -n "$TOOLS_ALLOW" ]]; then
      printf ' --tools %s' "$TOOLS_ALLOW"
    fi
    if [[ "$DISABLE_WEB" -eq 1 ]]; then
      printf ' --disable-web-search'
    fi
    printf ' --no-auto-update --max-turns %s --cwd %s' "$MAX_TURNS" "$RUN_CWD"
    if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
      printf ' %s' "${EXTRA_ARGS[*]}"
    fi
    printf '\n'
  }
  exit 0
fi

# --- real invoke ---
# Build argv carefully — sandbox value is always from env keys, never literal product defaults.
CMD=(
  "$GROK_BIN"
  --single "$PROMPT_TEXT"
  -m "$MODEL"
  --effort "$EFFORT"
  --sandbox "$SANDBOX_VAL"
  --no-auto-update
  --max-turns "$MAX_TURNS"
  --cwd "$RUN_CWD"
)
if [[ -n "$TOOLS_ALLOW" ]]; then
  CMD+=(--tools "$TOOLS_ALLOW")
fi
if [[ "$DISABLE_WEB" -eq 1 ]]; then
  CMD+=(--disable-web-search)
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

# Execute with CWD=RUN_CWD (isolation; never HOME root)
set +e
(
  cd "$RUN_CWD"
  "${CMD[@]}"
)
rc=$?
set -e

# Optional usage log under plugin data (no host personal log path)
if [[ -d "$DATA_DIR" ]]; then
  printf '%s\t%s\t%s\t%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$MODE" \
    "$(basename "${PRIMARY:-none}")" \
    "$rc" >>"${DATA_DIR}/usage.log" 2>/dev/null || true
fi

exit "$rc"
