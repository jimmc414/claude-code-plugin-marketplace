# Claude Code Plugin Marketplace - Operator Cheatsheet

Quick reference for Claude Code instances operating this marketplace.

---

## Overview

This marketplace hosts Claude Code plugins containing:
- **Skills** - Auto-triggered capabilities (model-invoked)
- **Agents** - Specialized subagents (user-invoked via Task tool)
- **Commands** - Slash commands (user-invoked via `/command`)
- **Hooks** - Event-triggered automation

**Repository**: https://github.com/jimmc414/claude-code-plugin-marketplace

---

## Directory Structure

```
claude-code-marketplace/
├── .claude-plugin/marketplace.json    # Marketplace registry
├── plugins/                           # All plugins live here
│   └── <plugin-name>/
│       ├── .claude-plugin/plugin.json # Plugin manifest
│       ├── commands/*.md              # Slash commands
│       ├── agents/*.md                # Subagents
│       ├── skills/<name>/SKILL.md     # Skills
│       ├── hooks/hooks.json           # Hook configurations
│       └── scripts/*.sh               # Hook scripts
├── templates/                         # Scaffolding templates
├── tools/                             # Python utilities
├── docs/                              # Documentation
└── catalog.json                       # Auto-generated index
```

---

## Python Tools Reference

All tools are in `/tools/` directory. Run from marketplace root.

### scaffold.py - Create New Components

```bash
# Create a new plugin
python tools/scaffold.py plugin <name> --description "Description"

# Add components to existing plugin
python tools/scaffold.py command <name> --plugin <plugin-name>
python tools/scaffold.py skill <name> --plugin <plugin-name>
python tools/scaffold.py agent <name> --plugin <plugin-name>
python tools/scaffold.py hook <name> --plugin <plugin-name>

# With description
python tools/scaffold.py skill my-skill --plugin my-plugin --description "Does X"
```

### validate.py - Validate Plugins

```bash
# Validate single plugin
python tools/validate.py <plugin-name>

# Validate all plugins
python tools/validate.py --all

# Check for naming conflicts with other plugins
python tools/validate.py <plugin-name> --check-conflicts

# Mark plugin as verified (after manual review)
python tools/validate.py <plugin-name> --mark-verified --reviewer "Name"
```

### export.py - Export Components

```bash
# Export entire plugin as zip
python tools/export.py plugin <name> --output ./exported/

# Export individual components
python tools/export.py skill <skill-name> --plugin <plugin-name> --output ./exported/
python tools/export.py agent <agent-name> --plugin <plugin-name> --output ./exported/
python tools/export.py command <cmd-name> --plugin <plugin-name> --output ./exported/

# Export hooks (includes hooks.json + scripts/)
python tools/export.py hook --plugin <plugin-name> --output ./exported/

# Export all plugins
python tools/export.py all --output ./exported/
```

### import.py - Import Components

```bash
# Import plugin from zip
python tools/import.py plugin ./path/to/plugin.zip
python tools/import.py plugin https://example.com/plugin.zip

# Import into existing plugin
python tools/import.py skill ./path/to/skill-folder --plugin <plugin-name>
python tools/import.py agent ./path/to/agent.md --plugin <plugin-name>
python tools/import.py command ./path/to/command.md --plugin <plugin-name>
python tools/import.py hook ./path/to/hooks-folder --plugin <plugin-name>

# Force overwrite existing
python tools/import.py plugin ./plugin.zip --force
```

### generate_catalog.py - Update Catalog

```bash
# Regenerate catalog.json from all plugins
python tools/generate_catalog.py

# Output to custom path
python tools/generate_catalog.py --output ./custom-catalog.json
```

---

## Common Workflows

### Create a New Plugin from Scratch

```bash
# 1. Scaffold plugin
python tools/scaffold.py plugin my-plugin --description "What it does"

# 2. Add components
python tools/scaffold.py skill core-skill --plugin my-plugin
python tools/scaffold.py agent helper-agent --plugin my-plugin
python tools/scaffold.py command do-thing --plugin my-plugin

# 3. Edit the generated files in plugins/my-plugin/

# 4. Validate
python tools/validate.py my-plugin

# 5. Update catalog
python tools/generate_catalog.py

# 6. Commit and push
git add plugins/my-plugin catalog.json
git commit -m "Add my-plugin"
git push
```

### Convert Existing Skills/Agents to Plugin

```bash
# 1. Create plugin scaffold
python tools/scaffold.py plugin my-plugin --description "Converted from local"

# 2. Import existing components
python tools/import.py skill ~/.claude/skills/my-skill --plugin my-plugin
python tools/import.py agent ~/.claude/agents/my-agent.md --plugin my-plugin

# 3. Update plugin.json metadata
# Edit plugins/my-plugin/.claude-plugin/plugin.json

# 4. Create README
# Edit plugins/my-plugin/README.md

# 5. Validate and push
python tools/validate.py my-plugin
python tools/generate_catalog.py
git add . && git commit -m "Add my-plugin" && git push
```

### Share Individual Hooks

```bash
# Export hooks from a plugin
python tools/export.py hook --plugin source-plugin --output ./shared/

# Import into another plugin
python tools/import.py hook ./shared/source-plugin-hooks --plugin target-plugin
```

### Update an Existing Plugin

```bash
# 1. Make changes to plugin files

# 2. Bump version in plugin.json
# Edit plugins/<name>/.claude-plugin/plugin.json

# 3. Validate
python tools/validate.py <plugin-name>

# 4. Regenerate catalog and push
python tools/generate_catalog.py
git add . && git commit -m "Update <plugin-name> to vX.Y.Z" && git push
```

---

## Plugin Manifest (plugin.json)

Required fields:
```json
{
  "name": "plugin-name",        // lowercase, hyphens ok
  "version": "1.0.0",           // semver
  "description": "What it does",
  "author": {
    "name": "Author Name"
  }
}
```

Optional fields:
```json
{
  "keywords": ["tag1", "tag2"],
  "category": "development",    // devops, development, security, testing, documentation, utilities
  "dependencies": {
    "other-plugin": ">=1.0.0"
  },
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

---

## Component Formats

### Skill (SKILL.md)

```yaml
---
name: skill-name
description: What it does. Use when [triggers]. Triggers: keyword1, keyword2.
allowed-tools: Read, Grep, Glob, Bash
---

# Skill Title

## Instructions
Step-by-step guide for Claude.

## Examples
Concrete usage examples.
```

### Agent (.md)

```yaml
---
name: agent-name
description: What it does. Use for [use cases].
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
---

# Agent Title

You are a specialized agent for [purpose].

## When Invoked
1. Step 1
2. Step 2
```

### Command (.md)

```yaml
---
description: Brief description
argument-hint: [arg1] [arg2]
allowed-tools: Bash, Read
---

# Command Name

## Arguments
- `$1` - First argument
- `$ARGUMENTS` - All arguments

## Instructions
What to do when invoked.
```

### Hooks (hooks.json)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash|Write",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/hook.sh",
          "timeout": 30
        }]
      }
    ]
  }
}
```

Hook events: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`

---

## Verification System

Plugins can be marked as verified after manual review:

```bash
# Mark verified
python tools/validate.py my-plugin --mark-verified --reviewer "Your Name"

# Check verification status
python tools/validate.py my-plugin
# Shows: [VERIFIED] by Name at timestamp
```

Verification data stored in `.verified.json` (gitignored by default).

---

## Catalog Format

`catalog.json` is auto-generated. Contains:

```json
{
  "generated_at": "ISO8601",
  "total_plugins": 3,
  "verified_plugins": 1,
  "plugins": [
    {
      "name": "plugin-name",
      "version": "1.0.0",
      "description": "...",
      "category": "development",
      "components": {
        "commands": 2,
        "agents": 1,
        "skills": 1,
        "hooks": true
      },
      "verified": true,
      "install_command": "/plugin install plugin-name@community-claude-plugins"
    }
  ],
  "categories": {"development": 2, "devops": 1}
}
```

---

## User-Facing Commands

Users interact with the marketplace via Claude Code's `/plugin` command:

```bash
# Add marketplace
/plugin marketplace add jimmc414/claude-code-plugin-marketplace

# Browse/install
/plugin
/plugin install <name>@community-claude-plugins

# List installed
/plugin list

# Uninstall
/plugin uninstall <name>
```

---

## Current Plugins

| Plugin | Category | Components |
|--------|----------|------------|
| example-deployment | devops | 2 commands, 1 agent, 1 skill |
| parallel-workflows | development | 3 skills, 3 agents |
| local-llm | development | 1 skill, 1 agent, 5 templates |

---

## Quick Validation Checklist

Before committing a plugin:

- [ ] `python tools/validate.py <name>` passes
- [ ] `python tools/validate.py <name> --check-conflicts` passes
- [ ] All JSON files valid: `python -m json.tool <file>`
- [ ] README.md is complete
- [ ] plugin.json has name, version, description, author
- [ ] Skills have frontmatter with name, description
- [ ] Agents have frontmatter with name, description
- [ ] Commands have frontmatter with description
- [ ] Hook scripts are executable (`chmod +x`)

---

## File Locations Summary

| What | Where |
|------|-------|
| Marketplace manifest | `.claude-plugin/marketplace.json` |
| Plugin manifest | `plugins/<name>/.claude-plugin/plugin.json` |
| Plugin catalog | `catalog.json` |
| Verification data | `.verified.json` |
| Templates | `templates/` |
| Tools | `tools/` |
| Documentation | `docs/` |

---

## Troubleshooting

### Validation fails with "plugin.json not found"
- Ensure `.claude-plugin/plugin.json` exists in plugin directory

### Import fails with "SKILL.md not found"
- Skills must be directories containing `SKILL.md`

### Hooks not triggering
- Verify `hooks.json` is valid JSON
- Check script is executable: `chmod +x scripts/*.sh`
- Ensure script outputs valid JSON response

### Catalog not updating
- Run `python tools/generate_catalog.py`
- Check plugin has valid `plugin.json`
