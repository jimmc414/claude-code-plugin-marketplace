# Creating Plugins

This guide walks you through creating Claude Code plugins for the marketplace.

## Quick Start

### 1. Clone the Marketplace

```bash
git clone https://github.com/yourname/claude-code-marketplace.git
cd claude-code-marketplace
```

### 2. Scaffold a New Plugin

```bash
python tools/scaffold.py plugin my-plugin --description "My awesome plugin"
```

This creates the basic plugin structure in `plugins/my-plugin/`.

### 3. Add Components

```bash
# Add a slash command
python tools/scaffold.py command my-cmd --plugin my-plugin

# Add a skill
python tools/scaffold.py skill my-skill --plugin my-plugin

# Add an agent
python tools/scaffold.py agent my-agent --plugin my-plugin

# Add a hook script
python tools/scaffold.py hook my-hook --plugin my-plugin
```

### 4. Customize Your Components

Edit the generated files in `plugins/my-plugin/`:

- `commands/*.md` - Slash command prompts
- `skills/*/SKILL.md` - Skill instructions
- `agents/*.md` - Agent definitions
- `hooks/hooks.json` - Hook configurations
- `scripts/*.sh` - Hook scripts

### 5. Validate

```bash
python tools/validate.py my-plugin
```

### 6. Test Locally

Add the local marketplace and test your plugin:

```bash
/plugin marketplace add ./claude-code-marketplace
/plugin install my-plugin@community-claude-plugins
```

### 7. Submit

See [Submitting Plugins](./submitting-plugins.md).

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Required: Plugin metadata
├── commands/                 # Slash commands
│   └── my-command.md
├── agents/                   # Specialized agents
│   └── my-agent.md
├── skills/                   # Agent skills
│   └── my-skill/
│       └── SKILL.md
├── hooks/                    # Event hooks
│   └── hooks.json
├── scripts/                  # Hook scripts
│   └── my-hook.sh
├── .mcp.json                # MCP server config (optional)
└── README.md                # Plugin documentation
```

## Component Types

### Slash Commands

User-invoked shortcuts. Create `.md` files in `commands/`:

```yaml
---
description: Brief description shown in help
argument-hint: [required-arg] [optional]
allowed-tools: Bash, Read, Grep
---

# Command Title

Instructions for Claude when this command is invoked.

## Arguments
- `$1` - First argument
- `$ARGUMENTS` - All arguments

## Steps
1. What to do first
2. What to do next
```

### Agent Skills

Model-invoked capabilities. Create in `skills/skill-name/SKILL.md`:

```yaml
---
name: skill-name
description: Description including WHEN to use this skill
allowed-tools: Read, Grep, Glob, Bash
---

# Skill Title

## Overview
What this skill does.

## Instructions
Step-by-step guide for Claude.

## Examples
Concrete usage examples.
```

### Agents

Specialized agents for complex tasks. Create `.md` files in `agents/`:

```yaml
---
name: agent-name
description: What this agent does and when to use it
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
permissionMode: default
---

# Agent Title

You are a specialized agent for [purpose].

## Your Expertise
- Skill 1
- Skill 2

## When Invoked
1. Step 1
2. Step 2

## Guidelines
- Do this
- Never that
```

### Hooks

Event-triggered automation. Configure in `hooks/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "description": "What this hook does",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/hook.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Available hook events:
- `PreToolUse` - Before a tool runs
- `PostToolUse` - After a tool completes
- `UserPromptSubmit` - When user submits a prompt
- `SessionStart` - When session begins
- `SessionEnd` - When session ends

### Hook Scripts

Bash scripts in `scripts/`:

```bash
#!/bin/bash
# Read JSON input from stdin
INPUT=$(cat)

# Parse with jq
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Your logic here
# ...

# Output JSON response
cat << 'EOF'
{
  "decision": "approve",
  "reason": "All good"
}
EOF
```

## Best Practices

1. **Clear Descriptions**: Write descriptions that help Claude know when to use your skill
2. **Specific Instructions**: Provide step-by-step guidance
3. **Include Examples**: Show concrete usage examples
4. **Handle Errors**: Include guidance for error scenarios
5. **Test Thoroughly**: Test your plugin locally before submitting
6. **Document Well**: Include a README with usage examples

## Plugin Metadata

Required fields in `plugin.json`:

```json
{
  "name": "my-plugin",           // Required: lowercase, hyphens ok
  "version": "1.0.0",            // Required: semver format
  "description": "...",          // Required: brief description
  "author": {
    "name": "Your Name",         // Required
    "email": "you@example.com"   // Optional
  }
}
```

Optional fields:

```json
{
  "homepage": "https://...",
  "repository": "https://...",
  "license": "MIT",
  "keywords": ["tag1", "tag2"],
  "category": "devops",
  "dependencies": {
    "other-plugin": ">=1.0.0"
  }
}
```

## Validation

Always validate before submitting:

```bash
# Validate structure and syntax
python tools/validate.py my-plugin

# Check for conflicts with other plugins
python tools/validate.py my-plugin --check-conflicts
```

## Next Steps

- Read the [API Reference](./api-reference.md) for full schemas
- See [Submitting Plugins](./submitting-plugins.md) to publish
- Check [Security Guidelines](./security.md) for best practices
