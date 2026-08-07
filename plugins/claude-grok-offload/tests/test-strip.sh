#!/usr/bin/env bash
# Fail if product tree contains personal / host-only markers (Task 4 strip gate).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"

cd "$REPO_ROOT"

TARGET="plugins/claude-grok-offload"

# Build pattern without embedding contiguous forbidden tokens in this file.
_u="$(printf '%s%s' 'jang' 'donghwa')"
_users="$(printf '/%s/' 'Users')"
_vault="$(printf '%s %s' 'Obsidian' 'Vault')"
_pre="$(printf '%s-%s' 'precode' 'gate')"
_vm="$(printf '%s_%s' 'vault' 'merge')"
_bird="$(printf '%s%s' 'bird' 'claw')"
PATTERN="${_u}|${_users}|${_vault}|${_pre}|${_vm}|${_bird}"

hits=""
if command -v rg >/dev/null 2>&1; then
  set +e
  hits="$(rg -n --glob '!tests/test-strip.sh' "$PATTERN" "$TARGET" 2>/dev/null)"
  set -e
else
  set +e
  hits="$(grep -RInE --exclude='test-strip.sh' "$PATTERN" "$TARGET" 2>/dev/null)"
  set -e
fi

if [[ -n "${hits:-}" ]]; then
  echo "FAIL test-strip: personal/host markers under $TARGET:" >&2
  printf '%s\n' "$hits" >&2
  exit 1
fi

echo "OK test-strip: no personal markers under $TARGET"
exit 0
