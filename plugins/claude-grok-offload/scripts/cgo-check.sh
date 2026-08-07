#!/usr/bin/env bash
# cgo-check.sh — Ready state machine (design §4.5)
# Produces: $CGO_DATA/cgo-env + stdout "Ready: yes|no"
# Exit: 0 if Ready:yes, 1 if Ready:no, 2 on usage/internal error
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/cgo-env.sh
source "${SCRIPT_DIR}/lib/cgo-env.sh"

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
FIXTURE="${PLUGIN_ROOT}/fixtures/first-run-design.md"
MODELS_TIMEOUT_SEC="${CGO_MODELS_TIMEOUT:-30}"

# --- helpers ---

cgo_sandbox_toml() {
  if [[ -n "${GROK_SANDBOX_TOML:-}" ]]; then
    printf '%s\n' "$GROK_SANDBOX_TOML"
  else
    printf '%s\n' "${HOME}/.grok/sandbox.toml"
  fi
}

# True if [profiles.<name>] table header exists in sandbox.toml
cgo_profile_in_toml() {
  local name="$1" toml
  toml="$(cgo_sandbox_toml)"
  [[ -f "$toml" ]] || return 1
  grep -qE "^\[profiles\.${name}\]" "$toml"
}

# Portable soft timeout for auth probe
cgo_timeout_run() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$secs" "$@"
  elif command -v perl >/dev/null 2>&1; then
    perl -e 'alarm shift @ARGV; exec @ARGV' "$secs" "$@"
  else
    # Last resort: no timeout (still run)
    "$@"
  fi
}

cgo_fail() {
  local reason="$1"
  cgo_env_clear
  printf 'Ready: no\n'
  printf 'reason: %s\n' "$reason"
  exit 1
}

# --- probes 1–2: binary + soft auth ---

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
  cgo_fail "grok binary not found (set PATH or GROK_BINARY)"
fi

if [[ "${CGO_MOCK_GROK:-}" == "1" ]]; then
  : # soft auth skipped under mock
else
  if ! cgo_timeout_run "$MODELS_TIMEOUT_SEC" "$GROK_BIN" models >/dev/null 2>&1; then
    cgo_fail "soft auth failed: '${GROK_BIN} models' (timeout ${MODELS_TIMEOUT_SEC}s or non-zero)"
  fi
fi

# --- probe 3: PLUGIN_ROOT ---

if [[ ! -d "$PLUGIN_ROOT" ]]; then
  cgo_fail "PLUGIN_ROOT not a directory: $PLUGIN_ROOT"
fi
if [[ ! -f "${PLUGIN_ROOT}/.claude-plugin/plugin.json" && ! -d "${PLUGIN_ROOT}/fixtures" ]]; then
  # Soft: require at least fixtures or plugin.json
  cgo_fail "PLUGIN_ROOT looks incomplete: $PLUGIN_ROOT"
fi

# --- probe 8: fixture non-empty (AND with Ready) — early so we don't write partial env ---

if [[ ! -f "$FIXTURE" ]]; then
  cgo_fail "fixture missing: fixtures/first-run-design.md"
fi
if [[ ! -s "$FIXTURE" ]]; then
  cgo_fail "fixture empty: fixtures/first-run-design.md"
fi

# --- probes 6a / 6b / 7: sandbox profiles ---

CGO_SANDBOX=""
CGO_STAGING=""
CGO_SANDBOX_WRITE=""

if cgo_profile_in_toml "cgo_ro"; then
  CGO_SANDBOX="cgo_ro"
  CGO_STAGING="0"
else
  # 6b: built-in strict always available once binary+auth passed
  CGO_SANDBOX="strict"
  CGO_STAGING="1"
fi

# 6c would be both failing — strict is built-in, so only theoretical if binary broken (already handled)

if cgo_profile_in_toml "cgo_impl"; then
  CGO_SANDBOX_WRITE="cgo_impl"
fi

# --- write state + report ---

cgo_env_clear
cgo_env_write "CGO_SANDBOX=${CGO_SANDBOX}"
cgo_env_write "CGO_STAGING=${CGO_STAGING}"
if [[ -n "$CGO_SANDBOX_WRITE" ]]; then
  cgo_env_write "CGO_SANDBOX_WRITE=${CGO_SANDBOX_WRITE}"
fi

printf 'Ready: yes\n'
printf 'CGO_SANDBOX=%s\n' "$CGO_SANDBOX"
printf 'CGO_STAGING=%s\n' "$CGO_STAGING"
if [[ -n "$CGO_SANDBOX_WRITE" ]]; then
  printf 'CGO_SANDBOX_WRITE=%s\n' "$CGO_SANDBOX_WRITE"
else
  printf 'CGO_SANDBOX_WRITE=\n'
fi
printf 'grok=%s\n' "$GROK_BIN"
printf 'plugin_root=%s\n' "$PLUGIN_ROOT"
printf 'data_dir=%s\n' "$(cgo_data_dir)"
exit 0
