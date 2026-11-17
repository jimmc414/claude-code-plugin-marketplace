#!/usr/bin/env python3
"""Fail unless SKILL.md starts with YAML frontmatter carrying name and description.

Claude Code will not load a skill whose frontmatter is missing or malformed, and
nothing else in CI would notice.
"""
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
m = re.match(r"---\n(.*?)\n---\n", text, re.S)
if not m:
    sys.exit("no frontmatter block at top of file")
fields = dict(re.findall(r"^([a-z]+):\s*(.+)$", m.group(1), re.M))
for key in ("name", "description"):
    if not fields.get(key, "").strip():
        sys.exit(f"frontmatter missing {key!r}")
if len(fields["description"]) > 1024:
    sys.exit("description exceeds 1024 characters")
print(f"frontmatter ok: name={fields['name']!r}, description {len(fields['description'])} chars")
