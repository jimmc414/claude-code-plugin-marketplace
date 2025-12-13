---
name: plugin-publishing
description: Knowledge for extracting local Claude Code components and publishing to plugin marketplaces. Use when helping users package skills, agents, hooks into shareable plugins. Triggers: publish, marketplace, share skill, share agent, extract plugin, contribute, upload plugin.
allowed-tools: Read, Grep, Glob, Bash
---

# Plugin Publishing Knowledge

This skill provides knowledge for extracting locally installed Claude Code components and packaging them into shareable plugins for marketplace submission.

## Claude Code Installation Paths

### Default Locations

| Component | Path | Format |
|-----------|------|--------|
| Skills | `~/.claude/skills/<name>/SKILL.md` | Directory with SKILL.md |
| Agents | `~/.claude/agents/<name>.md` | Single markdown file |
| Commands | `~/.claude/commands/<name>.md` | Single markdown file |
| Settings (hooks) | `~/.claude/settings.json` | JSON with `hooks` key |
| MCP Servers | `~/.claude/mcp.json` | JSON configuration |

### Project-Level Locations

Projects may have local overrides in:
- `.claude/skills/`
- `.claude/agents/`
- `.claude/commands/`
- `.claude/settings.json`

## Plugin Structure Requirements

A valid plugin MUST have:

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # REQUIRED: Plugin manifest
├── README.md                 # REQUIRED: Documentation
└── [components...]           # At least one component
```

### plugin.json Schema

```json
{
  "name": "plugin-name",           // REQUIRED: lowercase, hyphens allowed
  "version": "1.0.0",              // REQUIRED: semver format
  "description": "What it does",   // REQUIRED: one-line description
  "author": {
    "name": "Author Name",         // REQUIRED
    "email": "optional@email.com"  // Optional
  },
  "homepage": "https://...",       // Optional: documentation URL
  "repository": "https://...",     // Optional: source repo
  "license": "MIT",                // Recommended
  "keywords": ["tag1", "tag2"],    // Recommended: for discovery
  "category": "development",       // One of: devops, development, security, testing, documentation, utilities
  "dependencies": {},              // Optional: other plugins required
  "commands": "./commands/",       // Path if plugin has commands
  "agents": "./agents/",           // Path if plugin has agents
  "skills": "./skills/",           // Path if plugin has skills
  "hooks": "./hooks/hooks.json",   // Path if plugin has hooks
  "mcpServers": "./.mcp.json"      // Path if plugin has MCP servers
}
```

## Component Formats

### Skill Format (SKILL.md)

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

**Validation Rules:**
- MUST have YAML frontmatter with `name` and `description`
- `description` SHOULD include trigger keywords
- `allowed-tools` restricts what tools skill can use

### Agent Format (.md)

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

**Validation Rules:**
- MUST have YAML frontmatter with `name` and `description`
- `tools` lists allowed tool names
- `model` can be: inherit, sonnet, opus, haiku

### Command Format (.md)

```yaml
---
description: Brief description of what command does
argument-hint: [required-arg] [optional-arg]
allowed-tools: Bash, Read
---

# Command Name

## Arguments
- `$1` - First positional argument
- `$ARGUMENTS` - All arguments as string

## Instructions
What to do when user invokes this command.
```

### Hooks Format (hooks.json)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash|Write",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/my-hook.sh",
          "timeout": 30
        }]
      }
    ]
  }
}
```

**Hook Events:**
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `UserPromptSubmit` - When user submits prompt
- `SessionStart` - When session begins
- `SessionEnd` - When session ends

## Marketplace Formats

### marketplace.json

```json
{
  "name": "marketplace-name",
  "version": "1.0.0",
  "metadata": {
    "description": "Marketplace description",
    "pluginRoot": "./plugins"
  },
  "owner": {
    "name": "Owner Name"
  },
  "plugins": ["plugin-a", "plugin-b"],
  "categories": ["devops", "development", "testing"]
}
```

### catalog.json (Auto-Generated)

```json
{
  "generated_at": "ISO8601 timestamp",
  "total_plugins": 5,
  "verified_plugins": 2,
  "plugins": [
    {
      "name": "plugin-name",
      "version": "1.0.0",
      "description": "...",
      "author": "Name",
      "category": "development",
      "keywords": [],
      "components": {
        "commands": 0,
        "agents": 1,
        "skills": 1,
        "hooks": false,
        "mcp_servers": 0
      },
      "verified": false,
      "install_command": "/plugin install name@marketplace"
    }
  ],
  "categories": {"development": 3, "testing": 2}
}
```

## Category Selection Guide

| Category | Use For |
|----------|---------|
| `devops` | Deployment, CI/CD, infrastructure, Docker, Kubernetes |
| `development` | Coding workflows, git, testing, debugging |
| `security` | Security scanning, vulnerability detection, secrets |
| `testing` | Test generation, coverage, mutation testing |
| `documentation` | Doc generation, README creation, API docs |
| `utilities` | General-purpose tools, formatting, misc |

## Keyword Suggestions

Extract keywords from:
1. Component names (e.g., `parallel-worker` → `parallel`, `worker`)
2. Technologies mentioned (e.g., `git`, `docker`, `pytest`)
3. Actions performed (e.g., `deploy`, `test`, `monitor`)
4. Problem domain (e.g., `orchestration`, `automation`)

## Related Component Detection

Skills and agents often work together. Detect relationships by:

1. **Name patterns**: `foo-orchestrator` + `foo-worker` + `foo-monitor`
2. **Cross-references**: Agent mentions "use foo-skill"
3. **Shared keywords**: Multiple components with same domain terms
4. **Explicit dependencies**: Frontmatter mentions other components

## Validation Checklist

Before submission, verify:

- [ ] plugin.json has name, version, description, author
- [ ] All JSON files parse without errors
- [ ] Skills have frontmatter with name, description
- [ ] Agents have frontmatter with name, description
- [ ] Commands have frontmatter with description
- [ ] Hook scripts are executable (if any)
- [ ] README.md documents all components
- [ ] No hardcoded local paths or secrets
- [ ] No naming conflicts with existing plugins

## Common Issues to Fix During Extraction

| Issue | Fix |
|-------|-----|
| Hardcoded paths (`/home/user/...`) | Replace with relative or `~` |
| Local usernames | Replace with generic terms |
| API keys or secrets | Remove or use environment variables |
| Machine-specific configs | Generalize or document requirements |
| Missing frontmatter | Add required YAML frontmatter |
| Inconsistent naming | Standardize to lowercase-hyphenated |

## Marketplace Submission Workflow

1. **Fork** the marketplace repository
2. **Clone** your fork locally
3. **Create** plugin in `plugins/<name>/` directory
4. **Validate** with `python tools/validate.py <name>`
5. **Commit** with descriptive message
6. **Push** to your fork
7. **Create PR** with plugin details

### PR Description Template

```markdown
## New Plugin: <name>

**Description:** <one-line description>

**Category:** <category>

**Components:**
- Skills: <count>
- Agents: <count>
- Commands: <count>
- Hooks: yes/no

**Use Cases:**
- <use case 1>
- <use case 2>

**Testing:**
- [ ] Validated with `python tools/validate.py`
- [ ] Tested locally
- [ ] README complete
```
