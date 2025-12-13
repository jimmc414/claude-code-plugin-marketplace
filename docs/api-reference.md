# API Reference

Complete schema reference for Claude Code plugin components.

## Plugin Manifest (plugin.json)

Location: `.claude-plugin/plugin.json`

```json
{
  "name": "string",              // Required: lowercase, hyphens allowed
  "version": "string",           // Required: semver (e.g., "1.0.0")
  "description": "string",       // Required: brief plugin description
  "author": {                    // Required
    "name": "string",            // Required: author name
    "email": "string"            // Optional: author email
  },
  "homepage": "string",          // Optional: plugin homepage URL
  "repository": "string",        // Optional: repository URL
  "license": "string",           // Optional: license identifier (e.g., "MIT")
  "keywords": ["string"],        // Optional: search keywords
  "category": "string",          // Optional: category name
  "dependencies": {              // Optional: plugin dependencies
    "plugin-name": "version"     // e.g., ">=1.0.0", "^2.0.0"
  },
  "commands": "string",          // Optional: path to commands directory
  "agents": "string",            // Optional: path to agents directory
  "skills": "string",            // Optional: path to skills directory
  "hooks": "string",             // Optional: path to hooks.json
  "mcpServers": "string"         // Optional: path to .mcp.json
}
```

### Name Validation

- Must start with a lowercase letter
- Can contain lowercase letters, numbers, and hyphens
- Maximum 64 characters
- Pattern: `^[a-z][a-z0-9-]*$`

### Categories

Standard categories:
- `devops`
- `development`
- `security`
- `testing`
- `documentation`
- `utilities`

## Marketplace Manifest (marketplace.json)

Location: `.claude-plugin/marketplace.json`

```json
{
  "name": "string",              // Required: marketplace identifier
  "version": "string",           // Optional: marketplace version
  "metadata": {
    "description": "string",     // Optional: marketplace description
    "documentation": "string",   // Optional: documentation URL
    "pluginRoot": "string"       // Optional: path to plugins directory
  },
  "owner": {
    "name": "string",            // Required: owner name
    "email": "string",           // Optional: contact email
    "url": "string"              // Optional: owner URL
  },
  "plugins": [                   // Required: list of plugins
    {
      "name": "string",          // Required: plugin name
      "source": "string",        // Required: path or source config
      "version": "string",       // Optional: version constraint
      "description": "string",   // Optional: description
      "keywords": ["string"],    // Optional: keywords
      "category": "string"       // Optional: category
    }
  ],
  "categories": ["string"]       // Optional: available categories
}
```

## Catalog (catalog.json)

Auto-generated file listing all plugins.

```json
{
  "generated_at": "ISO8601",     // Generation timestamp
  "marketplace_name": "string",  // Marketplace identifier
  "total_plugins": "number",     // Total plugin count
  "verified_plugins": "number",  // Verified plugin count
  "plugins": [
    {
      "name": "string",
      "version": "string",
      "description": "string",
      "author": "string",
      "category": "string",
      "keywords": ["string"],
      "components": {
        "commands": "number",
        "agents": "number",
        "skills": "number",
        "hooks": "boolean",
        "mcp_servers": "number"
      },
      "install_command": "string",
      "source_url": "string",
      "dependencies": {},
      "verified": "boolean",
      "verified_at": "ISO8601",
      "verified_by": "string"
    }
  ],
  "categories": {
    "category-name": "number"    // Count per category
  }
}
```

## Slash Command (.md)

Location: `commands/{name}.md`

```yaml
---
description: "string"            # Required: brief description
argument-hint: "string"          # Optional: e.g., "[env] [version]"
allowed-tools: "string"          # Optional: comma-separated tool names
---

# Command Title

Markdown instructions for Claude.

## Arguments
- `$1` - First argument
- `$2` - Second argument
- `$ARGUMENTS` - All arguments as string

## Instructions
Step-by-step guide.
```

### Available Tools

Common tools to allow:
- `Read` - Read files
- `Write` - Write files
- `Edit` - Edit files
- `Bash` - Run shell commands
- `Grep` - Search file contents
- `Glob` - Find files by pattern

## Agent (.md)

Location: `agents/{name}.md`

```yaml
---
name: "string"                   # Required: agent identifier
description: "string"            # Required: what and when
tools: "string"                  # Optional: allowed tools
model: "string"                  # Optional: "inherit" or model ID
permissionMode: "string"         # Optional: "default" or "bypassPermissions"
skills: ["string"]               # Optional: skills to enable
---

# Agent Title

You are a specialized agent for [purpose].

## Your Expertise
- Item 1
- Item 2

## When Invoked
1. Step 1
2. Step 2

## Guidelines
- Do this
- Don't do that
```

## Skill (SKILL.md)

Location: `skills/{name}/SKILL.md`

```yaml
---
name: "string"                   # Required: skill identifier
description: "string"            # Required: includes trigger conditions
allowed-tools: "string"          # Optional: tool restrictions
---

# Skill Title

## Overview
What this skill enables.

## Instructions
### Step 1: Title
Instructions.

### Step 2: Title
Instructions.

## Examples
### Example 1
\`\`\`
User: "prompt"
Claude: [response]
\`\`\`

## Capabilities
- List of capabilities

## Limitations
- List of limitations
```

## Hooks (hooks.json)

Location: `hooks/hooks.json`

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "string",     // Optional: regex pattern for tool name
        "description": "string", // Optional: hook description
        "hooks": [
          {
            "type": "command",   // Required: "command"
            "command": "string", // Required: script path
            "timeout": "number"  // Optional: timeout in seconds
          }
        ]
      }
    ]
  }
}
```

### Hook Events

| Event | Trigger | Matcher Applies |
|-------|---------|-----------------|
| `PreToolUse` | Before tool execution | Yes |
| `PostToolUse` | After tool execution | Yes |
| `PermissionRequest` | Permission prompt | Yes |
| `UserPromptSubmit` | User sends message | No |
| `Notification` | Notification shown | No |
| `Stop` | Claude stops | No |
| `SubagentStop` | Subagent completes | No |
| `SessionStart` | Session begins | No |
| `SessionEnd` | Session ends | No |
| `PreCompact` | Before context compaction | No |

### Hook Script Input

JSON provided via stdin:

```json
{
  "tool_name": "string",         // Tool being used
  "tool_input": {},              // Tool parameters
  "session_id": "string"         // Current session ID
}
```

### Hook Script Output

JSON to stdout:

```json
{
  "decision": "approve",         // "approve" or "block"
  "reason": "string"             // Explanation
}
```

Exit codes:
- `0` - Success
- `2` - Blocking error
- Other - Non-blocking error

## MCP Configuration (.mcp.json)

Location: `.mcp.json`

```json
{
  "mcpServers": {
    "server-name": {
      "command": "string",       // Required: executable path
      "args": ["string"],        // Optional: arguments
      "env": {}                  // Optional: environment variables
    }
  }
}
```

## Environment Variables

Available in hook scripts:

| Variable | Description |
|----------|-------------|
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory |
| `HOME` | User home directory |

## Validation Rules

### plugin.json
- `name`: Required, matches pattern `^[a-z][a-z0-9-]*$`, max 64 chars
- `version`: Recommended, semver format
- `description`: Recommended, max 1024 chars
- `author.name`: Required

### Commands
- Must have YAML frontmatter
- Must have `description` field

### Agents
- Must have YAML frontmatter
- Must have `name` and `description` fields

### Skills
- Must be in directory with `SKILL.md`
- Must have YAML frontmatter
- Must have `name` and `description` fields

### Hooks
- Must be valid JSON
- Event names must be from allowed list
