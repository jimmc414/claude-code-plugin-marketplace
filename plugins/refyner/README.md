# Refyner Plugin

**Companion for your Refyner second brain — research grounded in what you've saved, plus propose→confirm capture.**

This plugin bundles the Refyner MCP server (OAuth) and a `second-brain` skill so Claude Code can search your saved knowledge before answering, and can propose new items for you to confirm before anything is written.

## Overview

[Refyner](https://refyner.me) is a personal "second brain" that stores articles, transcripts, and notes you've saved. This plugin connects Claude Code to your Refyner vault via MCP so that:

- Research questions are checked against what you've already saved, not just the open web.
- Anything worth keeping is **proposed** for your confirmation — nothing is written to your vault without an explicit yes.

## Requirements

- A free Refyner account: https://refyner.me
- One-time OAuth authentication with the bundled `refyner` MCP server (see Installation).

## Installation

```
/plugin install refyner@community-claude-plugins
```

After installing, connect and authenticate the bundled MCP server:

```
/mcp
```

Select **refyner** and choose **Authenticate** to complete the one-time browser OAuth login.

## How It Works

Claude automatically matches your request against the `second-brain` skill's description. When you ask to research a topic, recall something you've saved, or save new information, the skill loads and drives the following MCP tools:

- `search_vault(query)` — search your saved knowledge
- `get_vault_entry(id)` — read the full text of a saved item
- `propose_to_vault(...)` — preview a new capture (never writes) with duplicate detection
- `confirm_vault_capture(...)` — writes the capture, only after you explicitly confirm

## Usage Examples

- "Research context engineering — check my second brain too." → searches your vault, reads the most relevant entries, combines with a web search, and clearly labels what came from your saved knowledge vs. the web.
- "Save this thread to my second brain." → proposes a normalized preview (flagging duplicates), then captures it only after you confirm.
- "What have I saved about pricing?" → searches your vault and summarizes the hits.

## Components

| Component | Count |
|-----------|-------|
| Skills | 1 (`second-brain`) |
| MCP Servers | 1 (`refyner`, HTTP + OAuth) |

## License

MIT
