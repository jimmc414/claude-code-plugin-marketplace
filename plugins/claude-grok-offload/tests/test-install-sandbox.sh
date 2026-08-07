#!/usr/bin/env bash
# Install-sandbox merge contract tests (portable HOME; no personal paths).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$PLUGIN_ROOT/scripts/install-sandbox-profiles.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export HOME="$TMP/home"
export GROK_SANDBOX_TOML="$HOME/.grok/sandbox.toml"
mkdir -p "$HOME/.grok"

printf '%s\n' '[profiles.keepme]' 'extends = "strict"' >"$GROK_SANDBOX_TOML"

bash "$INSTALL"

# Required profiles present
grep -q '\[profiles.cgo_ro\]' "$GROK_SANDBOX_TOML"
grep -q '\[profiles.cgo_impl\]' "$GROK_SANDBOX_TOML"
# Pre-existing profile preserved
grep -q '\[profiles.keepme\]' "$GROK_SANDBOX_TOML"
# No vault-style path leak from fragments (test HOME expansion is expected)
_vault_marker="$(printf '%s %s' 'Obsidian' 'Vault')"
if grep -qF "$_vault_marker" "$GROK_SANDBOX_TOML"; then
  echo "FAIL: vault path leaked into sandbox.toml" >&2
  exit 1
fi
# Absolute HOME expanded (not tilde / not __HOME__)
grep -q "$HOME/.claude" "$GROK_SANDBOX_TOML"
grep -q "$HOME/.grok/docs" "$GROK_SANDBOX_TOML"
if grep -q '__HOME__' "$GROK_SANDBOX_TOML"; then
  echo "FAIL: __HOME__ placeholder left unexpanded" >&2
  exit 1
fi
if grep -qE '(^|[[:space:]])~/' "$GROK_SANDBOX_TOML"; then
  echo "FAIL: tilde path written to sandbox.toml" >&2
  exit 1
fi

# Backup created when file already existed
shopt -s nullglob
baks=("$GROK_SANDBOX_TOML".bak.*)
shopt -u nullglob
if [[ ${#baks[@]} -lt 1 ]]; then
  echo "FAIL: expected backup *.bak.<utc>" >&2
  exit 1
fi

# Idempotent second run — keepme still present, both cgo profiles still once each
bash "$INSTALL"
cgo_ro_n="$(grep -c '\[profiles.cgo_ro\]' "$GROK_SANDBOX_TOML" || true)"
cgo_impl_n="$(grep -c '\[profiles.cgo_impl\]' "$GROK_SANDBOX_TOML" || true)"
keepme_n="$(grep -c '\[profiles.keepme\]' "$GROK_SANDBOX_TOML" || true)"
if [[ "$cgo_ro_n" -ne 1 || "$cgo_impl_n" -ne 1 || "$keepme_n" -ne 1 ]]; then
  echo "FAIL: idempotent upsert counts ro=$cgo_ro_n impl=$cgo_impl_n keepme=$keepme_n" >&2
  exit 1
fi

# cgo_impl has no home path grants; extends workspace
grep -A2 '\[profiles.cgo_impl\]' "$GROK_SANDBOX_TOML" | grep -q 'extends = "workspace"'
if grep -A20 '\[profiles.cgo_impl\]' "$GROK_SANDBOX_TOML" | grep -q 'read_only'; then
  echo "FAIL: cgo_impl should not grant read_only home paths" >&2
  exit 1
fi

# cgo_ro extends strict
grep -A2 '\[profiles.cgo_ro\]' "$GROK_SANDBOX_TOML" | grep -q 'extends = "strict"'

echo OK
