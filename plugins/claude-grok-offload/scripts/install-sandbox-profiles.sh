#!/usr/bin/env bash
# Install portable cgo_ro / cgo_impl sandbox profiles into ~/.grok/sandbox.toml
# Design: §4.7 portable sandbox · merge = upsert those two keys only
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FRAG_RO="${PLUGIN_ROOT}/sandbox/cgo_ro.toml.fragment"
FRAG_IMPL="${PLUGIN_ROOT}/sandbox/cgo_impl.toml.fragment"
SANDBOX_TOML="${GROK_SANDBOX_TOML:-${HOME}/.grok/sandbox.toml}"

if [[ ! -f "$FRAG_RO" ]]; then
  echo "install-sandbox-profiles: missing fragment: $FRAG_RO" >&2
  exit 2
fi
if [[ ! -f "$FRAG_IMPL" ]]; then
  echo "install-sandbox-profiles: missing fragment: $FRAG_IMPL" >&2
  exit 2
fi
if [[ -z "${HOME:-}" ]]; then
  echo "install-sandbox-profiles: HOME is unset" >&2
  exit 2
fi

ABS_HOME="$(cd "$HOME" && pwd)"
mkdir -p "$(dirname "$SANDBOX_TOML")"

BACKUP=""
if [[ -f "$SANDBOX_TOML" ]]; then
  UTC="$(date -u +%Y%m%dT%H%M%SZ)"
  BACKUP="${SANDBOX_TOML}.bak.${UTC}"
  cp "$SANDBOX_TOML" "$BACKUP"
fi

restore_and_fail() {
  local msg="$1"
  echo "install-sandbox-profiles: $msg" >&2
  if [[ -n "$BACKUP" && -f "$BACKUP" ]]; then
    cp "$BACKUP" "$SANDBOX_TOML"
    echo "install-sandbox-profiles: restored backup $BACKUP" >&2
  fi
  exit 2
}

# Expand __HOME__ and upsert [profiles.cgo_ro] / [profiles.cgo_impl] only.
# Other profiles and leading comments are preserved (text section strip + append).
if ! python3 - "$SANDBOX_TOML" "$FRAG_RO" "$FRAG_IMPL" "$ABS_HOME" <<'PY'
import re
import sys
from pathlib import Path

dest = Path(sys.argv[1])
frag_ro = Path(sys.argv[2]).read_text(encoding="utf-8")
frag_impl = Path(sys.argv[3]).read_text(encoding="utf-8")
abs_home = sys.argv[4]

if "__HOME__" not in frag_ro:
    print("cgo_ro fragment missing __HOME__ placeholder", file=sys.stderr)
    sys.exit(1)

ro = frag_ro.replace("__HOME__", abs_home)
impl = frag_impl.replace("__HOME__", abs_home)

# Reject accidental personal-path leak from fragments *before* HOME expand
# (after expand, abs_home legitimately contains the operator user path).
_users = "/" + "Users" + "/"
_home = "/" + "home" + "/"
_vault = "Obsidian" + " " + "Vault"
for label, body in (("cgo_ro", frag_ro), ("cgo_impl", frag_impl)):
    if _users in body or _home in body or _vault in body:
        print(f"{label}: forbidden hard-coded host path in fragment", file=sys.stderr)
        sys.exit(1)

existing = dest.read_text(encoding="utf-8") if dest.is_file() else ""


def strip_profile(content: str, name: str) -> str:
    """Remove [profiles.<name>] table body until next [profiles.*] header or EOF."""
    pattern = re.compile(
        rf"^\[profiles\.{re.escape(name)}\][^\n]*\n"
        rf"(?:(?!^\[profiles\.).*\n?)*",
        re.MULTILINE,
    )
    return pattern.sub("", content)


content = strip_profile(existing, "cgo_ro")
content = strip_profile(content, "cgo_impl")
# Collapse excessive trailing blank lines, then append both profiles.
content = content.rstrip() + "\n\n" + ro.rstrip() + "\n\n" + impl.rstrip() + "\n"

try:
    import tomllib
except ImportError:  # pragma: no cover — py3.11+ required in practice
    tomllib = None  # type: ignore

if tomllib is not None:
    try:
        tomllib.loads(content)
    except Exception as exc:  # noqa: BLE001 — surface parse error then restore
        print(f"TOML validate failed: {exc}", file=sys.stderr)
        sys.exit(1)

dest.write_text(content, encoding="utf-8")
print(f"installed profiles.cgo_ro + profiles.cgo_impl → {dest}")
if tomllib is not None:
    data = tomllib.loads(dest.read_text(encoding="utf-8"))
    profiles = data.get("profiles") or {}
    for need in ("cgo_ro", "cgo_impl"):
        if need not in profiles:
            print(f"missing profiles.{need} after write", file=sys.stderr)
            sys.exit(1)
PY
then
  restore_and_fail "merge/upsert failed"
fi

echo "install-sandbox-profiles: OK ($SANDBOX_TOML)"
exit 0
