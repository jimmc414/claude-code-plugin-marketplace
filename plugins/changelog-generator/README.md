# generate-changelog

A Claude Code skill + zero-dependency bash script that generates a structured, Keep-a-Changelog style `CHANGELOG.md` from your git history.

Built for the [$50 claude-builders-bounty #1](https://github.com/claude-builders-bounty/claude-builders-bounty/issues/1). Tested on a real repo ([`sharkdp/bat`](https://github.com/sharkdp/bat): 260 commits since tag `v0.26.1`, all four categories populated).

## Install

**As a Claude Code plugin (recommended):**

```bash
/plugin install github:fliptrigga13/generate-changelog
```

Then run `/generate-changelog` in any repo.

**Or just the script — no Claude Code needed:**

```bash
curl -sO https://raw.githubusercontent.com/fliptrigga13/generate-changelog/main/scripts/changelog.sh
bash changelog.sh
```

**Or manual skill install:** copy `skills/generate-changelog/` into `~/.claude/skills/`.

## Usage

```bash
bash scripts/changelog.sh            # writes ./CHANGELOG.md
bash scripts/changelog.sh OUT.md     # writes OUT.md
```

Or in Claude Code: `/generate-changelog`

## How it works

- **Range:** commits since your most recent git tag (`git describe --tags --abbrev=0`); falls back to full history when the repo has no tags. Merge commits are skipped.
- **Categorization:** conventional-commit prefixes win first (`feat:` → Added, `fix:` → Fixed, `docs:`/`chore:`/`test:`/`ci:`/`build:`/`style:`/`refactor:`/`perf:` → Changed), keyword heuristics as fallback (remove/delete/deprecate → Removed; fix/bug/patch → Fixed; add/new/feature → Added; everything else → Changed).
- **Output:** Keep-a-Changelog markdown under `## [Unreleased]`, one bullet per commit with its short hash.

See [`sample/CHANGELOG.md`](sample/CHANGELOG.md) for real output.

## Requirements

`git` and `bash`. That's it — no dependencies.

## License

MIT — see [LICENSE](LICENSE).
