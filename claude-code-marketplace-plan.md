# Claude Code Plugin Marketplace - Implementation Plan

## Overview

This document provides a complete blueprint for creating a GitHub-hosted Claude Code plugin marketplace with templates and import/export tooling.

---

## Part 1: Repository Structure

```
claude-code-marketplace/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace registry manifest
├── plugins/
│   ├── example-deployment/           # Example plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   ├── agents/
│   │   ├── skills/
│   │   ├── hooks/
│   │   └── scripts/
│   └── example-code-review/          # Another example
│       └── ...
├── templates/                        # Starter templates
│   ├── plugin/
│   ├── skill/
│   ├── agent/
│   ├── command/
│   └── hook/
├── tools/                            # Import/export utilities
│   ├── import.py
│   ├── export.py
│   ├── validate.py
│   └── scaffold.py
├── docs/
│   ├── getting-started.md
│   ├── creating-plugins.md
│   ├── submitting-plugins.md
│   └── api-reference.md
├── .github/
│   ├── workflows/
│   │   ├── validate-plugins.yml      # CI validation
│   │   └── publish-catalog.yml       # Auto-generate catalog
│   ├── ISSUE_TEMPLATE/
│   │   └── plugin-submission.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── catalog.json                      # Auto-generated plugin index
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## Part 2: Core Files

### 2.1 marketplace.json

```json
{
  "name": "community-claude-plugins",
  "version": "1.0.0",
  "metadata": {
    "description": "Community-maintained Claude Code plugin marketplace",
    "documentation": "https://github.com/yourname/claude-code-marketplace",
    "pluginRoot": "./plugins"
  },
  "owner": {
    "name": "Your Name or Organization",
    "email": "contact@example.com",
    "url": "https://github.com/yourname"
  },
  "plugins": [
    {
      "name": "example-deployment",
      "source": "./plugins/example-deployment",
      "version": "1.0.0",
      "description": "Deployment automation tools",
      "keywords": ["deploy", "ci-cd", "automation"],
      "category": "devops"
    },
    {
      "name": "example-code-review",
      "source": "./plugins/example-code-review",
      "version": "1.0.0",
      "description": "Automated code review tools",
      "keywords": ["review", "quality", "linting"],
      "category": "development"
    }
  ],
  "categories": [
    "devops",
    "development",
    "security",
    "testing",
    "documentation",
    "utilities"
  ]
}
```

### 2.2 catalog.json (Auto-generated)

```json
{
  "generated_at": "2025-01-15T10:30:00Z",
  "total_plugins": 2,
  "plugins": [
    {
      "name": "example-deployment",
      "version": "1.0.0",
      "description": "Deployment automation tools",
      "author": "Your Name",
      "category": "devops",
      "keywords": ["deploy", "ci-cd"],
      "components": {
        "commands": 3,
        "agents": 1,
        "skills": 2,
        "hooks": true,
        "mcp_servers": 0
      },
      "install_command": "/plugin install example-deployment@community-claude-plugins",
      "source_url": "https://github.com/yourname/claude-code-marketplace/tree/main/plugins/example-deployment",
      "downloads": 0,
      "stars": 0
    }
  ],
  "categories": {
    "devops": 1,
    "development": 1
  }
}
```

---

## Part 3: Templates

### 3.1 Plugin Template

**templates/plugin/.claude-plugin/plugin.json**
```json
{
  "name": "{{PLUGIN_NAME}}",
  "version": "1.0.0",
  "description": "{{PLUGIN_DESCRIPTION}}",
  "author": {
    "name": "{{AUTHOR_NAME}}",
    "email": "{{AUTHOR_EMAIL}}"
  },
  "homepage": "{{HOMEPAGE_URL}}",
  "repository": "{{REPOSITORY_URL}}",
  "license": "MIT",
  "keywords": [],
  "commands": ["./commands/"],
  "agents": ["./agents/"],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**templates/plugin/commands/.gitkeep**
```
# Add your slash command .md files here
```

**templates/plugin/agents/.gitkeep**
```
# Add your agent .md files here
```

**templates/plugin/skills/.gitkeep**
```
# Add skill directories here (each with SKILL.md)
```

**templates/plugin/hooks/hooks.json**
```json
{
  "hooks": {}
}
```

**templates/plugin/.mcp.json**
```json
{
  "mcpServers": {}
}
```

**templates/plugin/scripts/.gitkeep**
```
# Add helper scripts here
```

**templates/plugin/README.md**
```markdown
# {{PLUGIN_NAME}}

{{PLUGIN_DESCRIPTION}}

## Installation

```bash
/plugin marketplace add yourname/claude-code-marketplace
/plugin install {{PLUGIN_NAME}}@community-claude-plugins
```

## Components

### Commands
- `/command-name` - Description

### Agents
- `agent-name` - Description

### Skills
- `skill-name` - Description

## Configuration

Describe any configuration options here.

## License

MIT
```

---

### 3.2 Skill Template

**templates/skill/SKILL.md**
```yaml
---
name: {{SKILL_NAME}}
description: {{SKILL_DESCRIPTION}}. Use when {{TRIGGER_CONDITIONS}}.
allowed-tools: Read, Grep, Glob, Bash
---

# {{SKILL_TITLE}}

## Overview

Brief description of what this skill enables Claude to do.

## Instructions

### Step 1: Identify the Task
Explain how to recognize when this skill applies.

### Step 2: Execute
Provide clear instructions for Claude to follow.

```python
# Example code if applicable
```

### Step 3: Verify
How to confirm the task was completed correctly.

## Examples

### Example 1: Basic Usage
```
User: "{{EXAMPLE_PROMPT}}"
Claude: [Uses this skill to...]
```

## Capabilities

- Capability 1
- Capability 2
- Capability 3

## Limitations

- What this skill cannot do
- Edge cases to be aware of
```

**templates/skill/reference.md**
```markdown
# {{SKILL_NAME}} Reference

## Detailed Documentation

Extended reference material for the skill.

## API Reference

If the skill interacts with APIs, document them here.

## Troubleshooting

Common issues and solutions.
```

---

### 3.3 Agent Template

**templates/agent/agent.md**
```yaml
---
name: {{AGENT_NAME}}
description: {{AGENT_DESCRIPTION}}. Use for {{USE_CASES}}.
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
permissionMode: default
skills:
---

# {{AGENT_TITLE}}

You are a specialized agent for {{PURPOSE}}.

## Your Expertise

- Area of expertise 1
- Area of expertise 2
- Area of expertise 3

## When Invoked

1. First, understand the user's request
2. Gather necessary context using available tools
3. Execute the task systematically
4. Verify the results
5. Report completion with summary

## Guidelines

- Always {{DO_THIS}}
- Never {{DONT_DO_THIS}}
- Prefer {{PREFERRED_APPROACH}}

## Output Format

Structure your responses as:

1. **Analysis**: Brief analysis of the request
2. **Plan**: Steps you'll take
3. **Execution**: Results of each step
4. **Summary**: Final outcome

## Examples

### Example Request
"{{EXAMPLE_REQUEST}}"

### Example Response
[How you would handle this]
```

---

### 3.4 Command Template

**templates/command/command.md**
```yaml
---
description: {{COMMAND_DESCRIPTION}}
argument-hint: [arg1] [arg2]
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# {{COMMAND_NAME}}

## Purpose

{{DETAILED_PURPOSE}}

## Arguments

- `$1` - First argument: {{ARG1_DESCRIPTION}}
- `$2` - Second argument: {{ARG2_DESCRIPTION}}
- `$ARGUMENTS` - All arguments as string

## Instructions

When this command is invoked:

1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}

## Example Usage

```
/{{COMMAND_NAME}} arg1 arg2
```

## Notes

- {{NOTE_1}}
- {{NOTE_2}}
```

---

### 3.5 Hook Template

**templates/hook/hooks.json**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "{{TOOL_PATTERN}}",
        "description": "{{HOOK_DESCRIPTION}}",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/{{SCRIPT_NAME}}.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "description": "Run after file modifications",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-edit.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "description": "Process user input before Claude sees it",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/preprocess.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**templates/hook/scripts/hook-template.sh**
```bash
#!/bin/bash
# Hook Script Template
#
# Input: JSON via stdin
# Output: JSON to stdout
# Exit codes:
#   0 = success
#   2 = blocking error
#   other = non-blocking error

set -e

# Read input JSON
INPUT=$(cat)

# Parse relevant fields
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Your logic here
# ...

# Output response
cat << 'EOF'
{
  "decision": "approve",
  "reason": "Hook executed successfully"
}
EOF
```

---

## Part 4: Import/Export Tools

### 4.1 tools/scaffold.py

```python
#!/usr/bin/env python3
"""
Scaffold new plugins, skills, agents, commands, or hooks.

Usage:
    python scaffold.py plugin my-plugin
    python scaffold.py skill my-skill --plugin my-plugin
    python scaffold.py agent my-agent --plugin my-plugin
    python scaffold.py command my-command --plugin my-plugin
    python scaffold.py hook my-hook --plugin my-plugin
"""

import argparse
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

TEMPLATES_DIR = Path(__file__).parent.parent / "templates"
PLUGINS_DIR = Path(__file__).parent.parent / "plugins"


def replace_placeholders(content: str, replacements: dict) -> str:
    """Replace {{PLACEHOLDER}} patterns in content."""
    for key, value in replacements.items():
        content = content.replace(f"{{{{{key}}}}}", value)
    return content


def scaffold_plugin(name: str, description: str = "", author: str = ""):
    """Create a new plugin from template."""
    plugin_dir = PLUGINS_DIR / name

    if plugin_dir.exists():
        print(f"Error: Plugin '{name}' already exists")
        return False

    # Copy template
    template_dir = TEMPLATES_DIR / "plugin"
    shutil.copytree(template_dir, plugin_dir)

    # Update plugin.json
    plugin_json_path = plugin_dir / ".claude-plugin" / "plugin.json"
    with open(plugin_json_path, "r") as f:
        content = f.read()

    replacements = {
        "PLUGIN_NAME": name,
        "PLUGIN_DESCRIPTION": description or f"Description for {name}",
        "AUTHOR_NAME": author or "Your Name",
        "AUTHOR_EMAIL": "your@email.com",
        "HOMEPAGE_URL": f"https://github.com/yourname/claude-code-marketplace/tree/main/plugins/{name}",
        "REPOSITORY_URL": "https://github.com/yourname/claude-code-marketplace"
    }

    content = replace_placeholders(content, replacements)

    with open(plugin_json_path, "w") as f:
        f.write(content)

    # Update README
    readme_path = plugin_dir / "README.md"
    with open(readme_path, "r") as f:
        content = f.read()
    content = replace_placeholders(content, replacements)
    with open(readme_path, "w") as f:
        f.write(content)

    print(f"Created plugin: {plugin_dir}")
    print(f"Next steps:")
    print(f"  1. Edit {plugin_json_path}")
    print(f"  2. Add commands, agents, skills, hooks")
    print(f"  3. Run: python tools/validate.py {name}")
    return True


def scaffold_skill(name: str, plugin: str, description: str = ""):
    """Create a new skill in a plugin."""
    plugin_dir = PLUGINS_DIR / plugin

    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin}' does not exist")
        return False

    skill_dir = plugin_dir / "skills" / name

    if skill_dir.exists():
        print(f"Error: Skill '{name}' already exists in plugin '{plugin}'")
        return False

    skill_dir.mkdir(parents=True)

    # Copy SKILL.md template
    template_path = TEMPLATES_DIR / "skill" / "SKILL.md"
    with open(template_path, "r") as f:
        content = f.read()

    replacements = {
        "SKILL_NAME": name,
        "SKILL_TITLE": name.replace("-", " ").title(),
        "SKILL_DESCRIPTION": description or f"Description for {name}",
        "TRIGGER_CONDITIONS": "working with relevant tasks",
        "EXAMPLE_PROMPT": f"Help me with {name.replace('-', ' ')}"
    }

    content = replace_placeholders(content, replacements)

    with open(skill_dir / "SKILL.md", "w") as f:
        f.write(content)

    # Copy reference.md template
    template_path = TEMPLATES_DIR / "skill" / "reference.md"
    with open(template_path, "r") as f:
        content = f.read()
    content = replace_placeholders(content, replacements)
    with open(skill_dir / "reference.md", "w") as f:
        f.write(content)

    print(f"Created skill: {skill_dir}")
    return True


def scaffold_agent(name: str, plugin: str, description: str = ""):
    """Create a new agent in a plugin."""
    plugin_dir = PLUGINS_DIR / plugin

    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin}' does not exist")
        return False

    agents_dir = plugin_dir / "agents"
    agents_dir.mkdir(exist_ok=True)

    agent_path = agents_dir / f"{name}.md"

    if agent_path.exists():
        print(f"Error: Agent '{name}' already exists in plugin '{plugin}'")
        return False

    template_path = TEMPLATES_DIR / "agent" / "agent.md"
    with open(template_path, "r") as f:
        content = f.read()

    replacements = {
        "AGENT_NAME": name,
        "AGENT_TITLE": name.replace("-", " ").title(),
        "AGENT_DESCRIPTION": description or f"Specialized agent for {name.replace('-', ' ')}",
        "USE_CASES": f"{name.replace('-', ' ')} tasks",
        "PURPOSE": name.replace("-", " "),
        "DO_THIS": "follow best practices",
        "DONT_DO_THIS": "skip verification steps",
        "PREFERRED_APPROACH": "thorough analysis before action",
        "EXAMPLE_REQUEST": f"Help me with {name.replace('-', ' ')}"
    }

    content = replace_placeholders(content, replacements)

    with open(agent_path, "w") as f:
        f.write(content)

    print(f"Created agent: {agent_path}")
    return True


def scaffold_command(name: str, plugin: str, description: str = ""):
    """Create a new command in a plugin."""
    plugin_dir = PLUGINS_DIR / plugin

    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin}' does not exist")
        return False

    commands_dir = plugin_dir / "commands"
    commands_dir.mkdir(exist_ok=True)

    command_path = commands_dir / f"{name}.md"

    if command_path.exists():
        print(f"Error: Command '{name}' already exists in plugin '{plugin}'")
        return False

    template_path = TEMPLATES_DIR / "command" / "command.md"
    with open(template_path, "r") as f:
        content = f.read()

    replacements = {
        "COMMAND_NAME": name,
        "COMMAND_DESCRIPTION": description or f"Execute {name.replace('-', ' ')}",
        "DETAILED_PURPOSE": f"This command helps you {name.replace('-', ' ')}.",
        "ARG1_DESCRIPTION": "First argument description",
        "ARG2_DESCRIPTION": "Second argument description",
        "STEP_1": "Parse and validate arguments",
        "STEP_2": "Execute the main logic",
        "STEP_3": "Report results to user",
        "NOTE_1": "Important note 1",
        "NOTE_2": "Important note 2"
    }

    content = replace_placeholders(content, replacements)

    with open(command_path, "w") as f:
        f.write(content)

    print(f"Created command: {command_path}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Scaffold Claude Code plugin components")
    parser.add_argument("type", choices=["plugin", "skill", "agent", "command", "hook"])
    parser.add_argument("name", help="Name of the component")
    parser.add_argument("--plugin", "-p", help="Plugin name (required for non-plugin types)")
    parser.add_argument("--description", "-d", default="", help="Description")
    parser.add_argument("--author", "-a", default="", help="Author name (for plugins)")

    args = parser.parse_args()

    if args.type == "plugin":
        scaffold_plugin(args.name, args.description, args.author)
    elif args.type == "skill":
        if not args.plugin:
            print("Error: --plugin required for skill")
            return
        scaffold_skill(args.name, args.plugin, args.description)
    elif args.type == "agent":
        if not args.plugin:
            print("Error: --plugin required for agent")
            return
        scaffold_agent(args.name, args.plugin, args.description)
    elif args.type == "command":
        if not args.plugin:
            print("Error: --plugin required for command")
            return
        scaffold_command(args.name, args.plugin, args.description)
    elif args.type == "hook":
        print("For hooks, manually edit hooks/hooks.json in your plugin")
        print(f"Template available at: {TEMPLATES_DIR}/hook/hooks.json")


if __name__ == "__main__":
    main()
```

### 4.2 tools/export.py

```python
#!/usr/bin/env python3
"""
Export plugins, skills, agents, or commands to standalone packages.

Usage:
    python export.py plugin my-plugin --output ./exported/
    python export.py skill my-skill --plugin my-plugin --output ./exported/
    python export.py all --output ./exported/
"""

import argparse
import json
import os
import shutil
import zipfile
from pathlib import Path
from datetime import datetime

PLUGINS_DIR = Path(__file__).parent.parent / "plugins"


def export_plugin(name: str, output_dir: Path) -> Path:
    """Export a plugin to a zip file."""
    plugin_dir = PLUGINS_DIR / name

    if not plugin_dir.exists():
        raise FileNotFoundError(f"Plugin '{name}' not found")

    # Read plugin.json for version
    plugin_json_path = plugin_dir / ".claude-plugin" / "plugin.json"
    with open(plugin_json_path, "r") as f:
        plugin_data = json.load(f)

    version = plugin_data.get("version", "1.0.0")

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    # Create zip file
    zip_name = f"{name}-{version}.zip"
    zip_path = output_dir / zip_name

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for file_path in plugin_dir.rglob("*"):
            if file_path.is_file():
                arcname = file_path.relative_to(plugin_dir)
                zipf.write(file_path, arcname)

    # Also create manifest
    manifest = {
        "name": name,
        "version": version,
        "exported_at": datetime.utcnow().isoformat() + "Z",
        "components": count_components(plugin_dir)
    }

    manifest_path = output_dir / f"{name}-{version}.manifest.json"
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)

    print(f"Exported: {zip_path}")
    print(f"Manifest: {manifest_path}")
    return zip_path


def export_skill(skill_name: str, plugin_name: str, output_dir: Path) -> Path:
    """Export a single skill to a directory."""
    skill_dir = PLUGINS_DIR / plugin_name / "skills" / skill_name

    if not skill_dir.exists():
        raise FileNotFoundError(f"Skill '{skill_name}' not found in plugin '{plugin_name}'")

    output_dir.mkdir(parents=True, exist_ok=True)
    export_path = output_dir / skill_name

    if export_path.exists():
        shutil.rmtree(export_path)

    shutil.copytree(skill_dir, export_path)

    print(f"Exported skill: {export_path}")
    return export_path


def export_agent(agent_name: str, plugin_name: str, output_dir: Path) -> Path:
    """Export a single agent to a file."""
    agent_path = PLUGINS_DIR / plugin_name / "agents" / f"{agent_name}.md"

    if not agent_path.exists():
        raise FileNotFoundError(f"Agent '{agent_name}' not found in plugin '{plugin_name}'")

    output_dir.mkdir(parents=True, exist_ok=True)
    export_path = output_dir / f"{agent_name}.md"

    shutil.copy(agent_path, export_path)

    print(f"Exported agent: {export_path}")
    return export_path


def export_command(command_name: str, plugin_name: str, output_dir: Path) -> Path:
    """Export a single command to a file."""
    command_path = PLUGINS_DIR / plugin_name / "commands" / f"{command_name}.md"

    if not command_path.exists():
        raise FileNotFoundError(f"Command '{command_name}' not found in plugin '{plugin_name}'")

    output_dir.mkdir(parents=True, exist_ok=True)
    export_path = output_dir / f"{command_name}.md"

    shutil.copy(command_path, export_path)

    print(f"Exported command: {export_path}")
    return export_path


def export_all(output_dir: Path):
    """Export all plugins."""
    for plugin_dir in PLUGINS_DIR.iterdir():
        if plugin_dir.is_dir() and (plugin_dir / ".claude-plugin" / "plugin.json").exists():
            try:
                export_plugin(plugin_dir.name, output_dir)
            except Exception as e:
                print(f"Error exporting {plugin_dir.name}: {e}")


def count_components(plugin_dir: Path) -> dict:
    """Count components in a plugin."""
    components = {
        "commands": 0,
        "agents": 0,
        "skills": 0,
        "hooks": False,
        "mcp_servers": 0
    }

    commands_dir = plugin_dir / "commands"
    if commands_dir.exists():
        components["commands"] = len(list(commands_dir.glob("*.md")))

    agents_dir = plugin_dir / "agents"
    if agents_dir.exists():
        components["agents"] = len(list(agents_dir.glob("*.md")))

    skills_dir = plugin_dir / "skills"
    if skills_dir.exists():
        components["skills"] = len([d for d in skills_dir.iterdir() if d.is_dir() and (d / "SKILL.md").exists()])

    hooks_file = plugin_dir / "hooks" / "hooks.json"
    if hooks_file.exists():
        with open(hooks_file, "r") as f:
            hooks_data = json.load(f)
            components["hooks"] = bool(hooks_data.get("hooks"))

    mcp_file = plugin_dir / ".mcp.json"
    if mcp_file.exists():
        with open(mcp_file, "r") as f:
            mcp_data = json.load(f)
            components["mcp_servers"] = len(mcp_data.get("mcpServers", {}))

    return components


def main():
    parser = argparse.ArgumentParser(description="Export Claude Code plugin components")
    parser.add_argument("type", choices=["plugin", "skill", "agent", "command", "all"])
    parser.add_argument("name", nargs="?", help="Name of the component")
    parser.add_argument("--plugin", "-p", help="Plugin name (for skill/agent/command)")
    parser.add_argument("--output", "-o", default="./exported", help="Output directory")

    args = parser.parse_args()
    output_dir = Path(args.output)

    if args.type == "plugin":
        if not args.name:
            print("Error: name required for plugin export")
            return
        export_plugin(args.name, output_dir)
    elif args.type == "skill":
        if not args.name or not args.plugin:
            print("Error: name and --plugin required for skill export")
            return
        export_skill(args.name, args.plugin, output_dir)
    elif args.type == "agent":
        if not args.name or not args.plugin:
            print("Error: name and --plugin required for agent export")
            return
        export_agent(args.name, args.plugin, output_dir)
    elif args.type == "command":
        if not args.name or not args.plugin:
            print("Error: name and --plugin required for command export")
            return
        export_command(args.name, args.plugin, output_dir)
    elif args.type == "all":
        export_all(output_dir)


if __name__ == "__main__":
    main()
```

### 4.3 tools/import.py

```python
#!/usr/bin/env python3
"""
Import plugins, skills, agents, or commands from external sources.

Usage:
    python import.py plugin ./path/to/plugin.zip
    python import.py plugin https://github.com/user/repo/releases/download/v1.0/plugin.zip
    python import.py skill ./path/to/skill-folder --plugin my-plugin
    python import.py agent ./path/to/agent.md --plugin my-plugin
    python import.py command ./path/to/command.md --plugin my-plugin
"""

import argparse
import json
import os
import shutil
import tempfile
import zipfile
from pathlib import Path
from urllib.request import urlretrieve
from urllib.parse import urlparse

PLUGINS_DIR = Path(__file__).parent.parent / "plugins"


def download_if_url(source: str) -> Path:
    """Download file if source is a URL, return local path."""
    parsed = urlparse(source)
    if parsed.scheme in ("http", "https"):
        print(f"Downloading: {source}")
        temp_dir = tempfile.mkdtemp()
        filename = os.path.basename(parsed.path) or "downloaded.zip"
        local_path = Path(temp_dir) / filename
        urlretrieve(source, local_path)
        return local_path
    return Path(source)


def import_plugin(source: str, force: bool = False) -> bool:
    """Import a plugin from zip file or URL."""
    local_path = download_if_url(source)

    if not local_path.exists():
        print(f"Error: Source not found: {local_path}")
        return False

    # Extract to temp directory first
    temp_dir = tempfile.mkdtemp()

    try:
        with zipfile.ZipFile(local_path, "r") as zipf:
            zipf.extractall(temp_dir)

        # Find plugin.json to get name
        temp_path = Path(temp_dir)
        plugin_json = None

        # Check if plugin.json is at root or in subdirectory
        if (temp_path / ".claude-plugin" / "plugin.json").exists():
            plugin_json = temp_path / ".claude-plugin" / "plugin.json"
            source_dir = temp_path
        else:
            for subdir in temp_path.iterdir():
                if (subdir / ".claude-plugin" / "plugin.json").exists():
                    plugin_json = subdir / ".claude-plugin" / "plugin.json"
                    source_dir = subdir
                    break

        if not plugin_json:
            print("Error: No valid plugin.json found in archive")
            return False

        with open(plugin_json, "r") as f:
            plugin_data = json.load(f)

        plugin_name = plugin_data.get("name")
        if not plugin_name:
            print("Error: Plugin name not found in plugin.json")
            return False

        target_dir = PLUGINS_DIR / plugin_name

        if target_dir.exists():
            if force:
                shutil.rmtree(target_dir)
            else:
                print(f"Error: Plugin '{plugin_name}' already exists. Use --force to overwrite.")
                return False

        shutil.copytree(source_dir, target_dir)
        print(f"Imported plugin: {target_dir}")
        return True

    finally:
        shutil.rmtree(temp_dir)


def import_skill(source: str, plugin_name: str, force: bool = False) -> bool:
    """Import a skill folder into a plugin."""
    source_path = Path(source)

    if not source_path.exists():
        print(f"Error: Source not found: {source_path}")
        return False

    if not (source_path / "SKILL.md").exists():
        print("Error: Source must contain SKILL.md")
        return False

    plugin_dir = PLUGINS_DIR / plugin_name
    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin_name}' does not exist")
        return False

    skill_name = source_path.name
    target_dir = plugin_dir / "skills" / skill_name

    if target_dir.exists():
        if force:
            shutil.rmtree(target_dir)
        else:
            print(f"Error: Skill '{skill_name}' already exists. Use --force to overwrite.")
            return False

    target_dir.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source_path, target_dir)
    print(f"Imported skill: {target_dir}")
    return True


def import_agent(source: str, plugin_name: str, force: bool = False) -> bool:
    """Import an agent file into a plugin."""
    source_path = Path(source)

    if not source_path.exists():
        print(f"Error: Source not found: {source_path}")
        return False

    plugin_dir = PLUGINS_DIR / plugin_name
    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin_name}' does not exist")
        return False

    agents_dir = plugin_dir / "agents"
    agents_dir.mkdir(parents=True, exist_ok=True)

    target_path = agents_dir / source_path.name

    if target_path.exists() and not force:
        print(f"Error: Agent '{source_path.name}' already exists. Use --force to overwrite.")
        return False

    shutil.copy(source_path, target_path)
    print(f"Imported agent: {target_path}")
    return True


def import_command(source: str, plugin_name: str, force: bool = False) -> bool:
    """Import a command file into a plugin."""
    source_path = Path(source)

    if not source_path.exists():
        print(f"Error: Source not found: {source_path}")
        return False

    plugin_dir = PLUGINS_DIR / plugin_name
    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin_name}' does not exist")
        return False

    commands_dir = plugin_dir / "commands"
    commands_dir.mkdir(parents=True, exist_ok=True)

    target_path = commands_dir / source_path.name

    if target_path.exists() and not force:
        print(f"Error: Command '{source_path.name}' already exists. Use --force to overwrite.")
        return False

    shutil.copy(source_path, target_path)
    print(f"Imported command: {target_path}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Import Claude Code plugin components")
    parser.add_argument("type", choices=["plugin", "skill", "agent", "command"])
    parser.add_argument("source", help="Path or URL to import from")
    parser.add_argument("--plugin", "-p", help="Target plugin name (for skill/agent/command)")
    parser.add_argument("--force", "-f", action="store_true", help="Overwrite existing")

    args = parser.parse_args()

    if args.type == "plugin":
        import_plugin(args.source, args.force)
    elif args.type == "skill":
        if not args.plugin:
            print("Error: --plugin required for skill import")
            return
        import_skill(args.source, args.plugin, args.force)
    elif args.type == "agent":
        if not args.plugin:
            print("Error: --plugin required for agent import")
            return
        import_agent(args.source, args.plugin, args.force)
    elif args.type == "command":
        if not args.plugin:
            print("Error: --plugin required for command import")
            return
        import_command(args.source, args.plugin, args.force)


if __name__ == "__main__":
    main()
```

### 4.4 tools/validate.py

```python
#!/usr/bin/env python3
"""
Validate plugins, skills, agents, and commands against schemas.

Usage:
    python validate.py my-plugin
    python validate.py --all
"""

import argparse
import json
import re
import sys
from pathlib import Path

PLUGINS_DIR = Path(__file__).parent.parent / "plugins"

# Validation rules
NAME_PATTERN = re.compile(r"^[a-z][a-z0-9-]*$")
MAX_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024


class ValidationError:
    def __init__(self, path: str, message: str, severity: str = "error"):
        self.path = path
        self.message = message
        self.severity = severity

    def __str__(self):
        return f"[{self.severity.upper()}] {self.path}: {self.message}"


def validate_plugin_json(plugin_dir: Path) -> list[ValidationError]:
    """Validate plugin.json structure."""
    errors = []
    plugin_json_path = plugin_dir / ".claude-plugin" / "plugin.json"

    if not plugin_json_path.exists():
        errors.append(ValidationError(
            str(plugin_json_path),
            "plugin.json not found"
        ))
        return errors

    try:
        with open(plugin_json_path, "r") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(ValidationError(
            str(plugin_json_path),
            f"Invalid JSON: {e}"
        ))
        return errors

    # Required: name
    if "name" not in data:
        errors.append(ValidationError(
            str(plugin_json_path),
            "Missing required field: name"
        ))
    elif not NAME_PATTERN.match(data["name"]):
        errors.append(ValidationError(
            str(plugin_json_path),
            f"Invalid name format: '{data['name']}'. Must be lowercase letters, numbers, hyphens only."
        ))
    elif len(data["name"]) > MAX_NAME_LENGTH:
        errors.append(ValidationError(
            str(plugin_json_path),
            f"Name too long: {len(data['name'])} chars (max {MAX_NAME_LENGTH})"
        ))

    # Validate paths exist
    for path_field in ["commands", "agents", "hooks", "mcpServers"]:
        if path_field in data:
            paths = data[path_field] if isinstance(data[path_field], list) else [data[path_field]]
            for path in paths:
                if isinstance(path, str) and path.startswith("./"):
                    full_path = plugin_dir / path[2:]
                    if not full_path.exists():
                        errors.append(ValidationError(
                            str(plugin_json_path),
                            f"Path does not exist: {path}",
                            "warning"
                        ))

    return errors


def validate_skill(skill_dir: Path) -> list[ValidationError]:
    """Validate a skill directory."""
    errors = []
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        errors.append(ValidationError(
            str(skill_dir),
            "SKILL.md not found"
        ))
        return errors

    content = skill_md.read_text()

    # Check for frontmatter
    if not content.startswith("---"):
        errors.append(ValidationError(
            str(skill_md),
            "Missing YAML frontmatter"
        ))
        return errors

    # Parse frontmatter
    parts = content.split("---", 2)
    if len(parts) < 3:
        errors.append(ValidationError(
            str(skill_md),
            "Invalid frontmatter format"
        ))
        return errors

    frontmatter = parts[1].strip()

    # Check required fields
    if "name:" not in frontmatter:
        errors.append(ValidationError(
            str(skill_md),
            "Missing required frontmatter field: name"
        ))

    if "description:" not in frontmatter:
        errors.append(ValidationError(
            str(skill_md),
            "Missing required frontmatter field: description"
        ))

    return errors


def validate_agent(agent_path: Path) -> list[ValidationError]:
    """Validate an agent file."""
    errors = []

    if not agent_path.exists():
        errors.append(ValidationError(
            str(agent_path),
            "Agent file not found"
        ))
        return errors

    content = agent_path.read_text()

    # Check for frontmatter
    if not content.startswith("---"):
        errors.append(ValidationError(
            str(agent_path),
            "Missing YAML frontmatter"
        ))
        return errors

    parts = content.split("---", 2)
    if len(parts) < 3:
        errors.append(ValidationError(
            str(agent_path),
            "Invalid frontmatter format"
        ))
        return errors

    frontmatter = parts[1].strip()

    if "name:" not in frontmatter:
        errors.append(ValidationError(
            str(agent_path),
            "Missing required frontmatter field: name"
        ))

    if "description:" not in frontmatter:
        errors.append(ValidationError(
            str(agent_path),
            "Missing required frontmatter field: description"
        ))

    return errors


def validate_command(command_path: Path) -> list[ValidationError]:
    """Validate a command file."""
    errors = []

    if not command_path.exists():
        errors.append(ValidationError(
            str(command_path),
            "Command file not found"
        ))
        return errors

    content = command_path.read_text()

    # Check for frontmatter (required for commands)
    if not content.startswith("---"):
        errors.append(ValidationError(
            str(command_path),
            "Missing YAML frontmatter"
        ))
        return errors

    parts = content.split("---", 2)
    if len(parts) < 3:
        errors.append(ValidationError(
            str(command_path),
            "Invalid frontmatter format"
        ))
        return errors

    frontmatter = parts[1].strip()

    if "description:" not in frontmatter:
        errors.append(ValidationError(
            str(command_path),
            "Missing required frontmatter field: description",
            "warning"
        ))

    return errors


def validate_hooks(hooks_path: Path) -> list[ValidationError]:
    """Validate hooks.json."""
    errors = []

    if not hooks_path.exists():
        return errors  # Hooks are optional

    try:
        with open(hooks_path, "r") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(ValidationError(
            str(hooks_path),
            f"Invalid JSON: {e}"
        ))
        return errors

    valid_events = [
        "PreToolUse", "PostToolUse", "PermissionRequest",
        "UserPromptSubmit", "Notification", "Stop", "SubagentStop",
        "SessionStart", "SessionEnd", "PreCompact"
    ]

    hooks = data.get("hooks", {})
    for event_name in hooks:
        if event_name not in valid_events:
            errors.append(ValidationError(
                str(hooks_path),
                f"Unknown hook event: {event_name}",
                "warning"
            ))

    return errors


def validate_plugin(plugin_name: str) -> list[ValidationError]:
    """Validate an entire plugin."""
    errors = []
    plugin_dir = PLUGINS_DIR / plugin_name

    if not plugin_dir.exists():
        errors.append(ValidationError(
            str(plugin_dir),
            "Plugin directory not found"
        ))
        return errors

    # Validate plugin.json
    errors.extend(validate_plugin_json(plugin_dir))

    # Validate skills
    skills_dir = plugin_dir / "skills"
    if skills_dir.exists():
        for skill_dir in skills_dir.iterdir():
            if skill_dir.is_dir():
                errors.extend(validate_skill(skill_dir))

    # Validate agents
    agents_dir = plugin_dir / "agents"
    if agents_dir.exists():
        for agent_path in agents_dir.glob("*.md"):
            errors.extend(validate_agent(agent_path))

    # Validate commands
    commands_dir = plugin_dir / "commands"
    if commands_dir.exists():
        for command_path in commands_dir.glob("*.md"):
            errors.extend(validate_command(command_path))

    # Validate hooks
    hooks_path = plugin_dir / "hooks" / "hooks.json"
    errors.extend(validate_hooks(hooks_path))

    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate Claude Code plugins")
    parser.add_argument("plugin", nargs="?", help="Plugin name to validate")
    parser.add_argument("--all", "-a", action="store_true", help="Validate all plugins")

    args = parser.parse_args()

    if args.all:
        plugins = [d.name for d in PLUGINS_DIR.iterdir() if d.is_dir()]
    elif args.plugin:
        plugins = [args.plugin]
    else:
        print("Error: Specify a plugin name or use --all")
        sys.exit(1)

    total_errors = 0
    total_warnings = 0

    for plugin_name in plugins:
        print(f"\nValidating: {plugin_name}")
        print("-" * 40)

        errors = validate_plugin(plugin_name)

        if not errors:
            print("  OK - No issues found")
        else:
            for error in errors:
                print(f"  {error}")
                if error.severity == "error":
                    total_errors += 1
                else:
                    total_warnings += 1

    print(f"\n{'=' * 40}")
    print(f"Total: {total_errors} errors, {total_warnings} warnings")

    sys.exit(1 if total_errors > 0 else 0)


if __name__ == "__main__":
    main()
```

---

## Part 5: GitHub Actions CI/CD

### 5.1 .github/workflows/validate-plugins.yml

```yaml
name: Validate Plugins

on:
  push:
    branches: [main]
    paths:
      - 'plugins/**'
  pull_request:
    branches: [main]
    paths:
      - 'plugins/**'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Validate all plugins
        run: python tools/validate.py --all

      - name: Check JSON syntax
        run: |
          find plugins -name "*.json" -exec python -m json.tool {} \; > /dev/null

  generate-catalog:
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Generate catalog
        run: python tools/generate_catalog.py

      - name: Commit catalog
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add catalog.json
          git diff --staged --quiet || git commit -m "Update plugin catalog [skip ci]"
          git push
```

### 5.2 .github/workflows/publish-catalog.yml

```yaml
name: Publish Catalog

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

jobs:
  publish:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Generate catalog
        run: python tools/generate_catalog.py

      - name: Upload catalog artifact
        uses: actions/upload-artifact@v4
        with:
          name: catalog
          path: catalog.json

      - name: Deploy to GitHub Pages (optional)
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
          publish_branch: gh-pages
```

### 5.3 .github/ISSUE_TEMPLATE/plugin-submission.yml

```yaml
name: Plugin Submission
description: Submit a new plugin to the marketplace
title: "[Plugin] "
labels: ["plugin-submission"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for submitting a plugin to the Claude Code marketplace!

  - type: input
    id: plugin-name
    attributes:
      label: Plugin Name
      description: The name of your plugin (lowercase, hyphens only)
      placeholder: my-awesome-plugin
    validations:
      required: true

  - type: textarea
    id: description
    attributes:
      label: Description
      description: What does your plugin do?
    validations:
      required: true

  - type: dropdown
    id: category
    attributes:
      label: Category
      options:
        - devops
        - development
        - security
        - testing
        - documentation
        - utilities
    validations:
      required: true

  - type: input
    id: repository
    attributes:
      label: Source Repository
      description: URL to your plugin repository
      placeholder: https://github.com/username/plugin-repo
    validations:
      required: true

  - type: checkboxes
    id: checklist
    attributes:
      label: Submission Checklist
      options:
        - label: Plugin has a valid plugin.json
          required: true
        - label: Plugin passes validation (python tools/validate.py)
          required: true
        - label: Plugin has a README.md
          required: true
        - label: Plugin has a LICENSE file
          required: true
        - label: I have tested the plugin locally
          required: true
```

### 5.4 .github/PULL_REQUEST_TEMPLATE.md

```markdown
## Plugin Submission/Update

### Plugin Name
<!-- Name of the plugin -->

### Description
<!-- Brief description of what this PR adds/changes -->

### Type of Change
- [ ] New plugin
- [ ] Plugin update
- [ ] Bug fix
- [ ] Documentation update

### Checklist
- [ ] Plugin passes validation (`python tools/validate.py plugin-name`)
- [ ] JSON files are valid
- [ ] README is updated
- [ ] No sensitive data or secrets included
- [ ] Tested locally with Claude Code

### Components Included
- [ ] Commands
- [ ] Agents
- [ ] Skills
- [ ] Hooks
- [ ] MCP Servers

### Screenshots/Examples
<!-- If applicable, add screenshots or example usage -->
```

---

## Part 6: Documentation

### 6.1 docs/getting-started.md

```markdown
# Getting Started with the Claude Code Plugin Marketplace

## Installation

Add this marketplace to your Claude Code installation:

```bash
/plugin marketplace add yourname/claude-code-marketplace
```

## Browse Available Plugins

```bash
/plugin
```

## Install a Plugin

```bash
/plugin install plugin-name@community-claude-plugins
```

## List Installed Plugins

```bash
/plugin list
```

## Uninstall a Plugin

```bash
/plugin uninstall plugin-name
```
```

### 6.2 docs/creating-plugins.md

```markdown
# Creating Plugins

## Quick Start

1. Clone the marketplace repo
2. Run the scaffold tool:
   ```bash
   python tools/scaffold.py plugin my-plugin --description "My awesome plugin"
   ```
3. Add components:
   ```bash
   python tools/scaffold.py skill my-skill --plugin my-plugin
   python tools/scaffold.py agent my-agent --plugin my-plugin
   python tools/scaffold.py command my-cmd --plugin my-plugin
   ```
4. Validate:
   ```bash
   python tools/validate.py my-plugin
   ```
5. Submit a PR!

## Manual Creation

See the templates/ directory for starter files.
```

---

## Part 7: Quick Start Script

### setup.sh

```bash
#!/bin/bash
# Quick setup script for the marketplace

set -e

echo "Setting up Claude Code Plugin Marketplace..."

# Create directory structure
mkdir -p plugins
mkdir -p templates/{plugin,skill,agent,command,hook}
mkdir -p tools
mkdir -p docs
mkdir -p .github/workflows
mkdir -p .github/ISSUE_TEMPLATE

# Make tools executable
chmod +x tools/*.py 2>/dev/null || true

echo "Directory structure created!"
echo ""
echo "Next steps:"
echo "  1. Create your first plugin:"
echo "     python tools/scaffold.py plugin my-first-plugin"
echo ""
echo "  2. Add components:"
echo "     python tools/scaffold.py skill my-skill --plugin my-first-plugin"
echo ""
echo "  3. Validate:"
echo "     python tools/validate.py my-first-plugin"
echo ""
echo "  4. Push to GitHub and share:"
echo "     /plugin marketplace add yourname/this-repo"
```

---

## Part 8: Example Plugin

### plugins/example-deployment/.claude-plugin/plugin.json

```json
{
  "name": "example-deployment",
  "version": "1.0.0",
  "description": "Deployment automation tools for common platforms",
  "author": {
    "name": "Marketplace Team",
    "email": "team@example.com"
  },
  "license": "MIT",
  "keywords": ["deploy", "ci-cd", "docker", "kubernetes"],
  "commands": ["./commands/"],
  "agents": ["./agents/"],
  "skills": ["./skills/"],
  "hooks": "./hooks/hooks.json"
}
```

### plugins/example-deployment/commands/deploy.md

```yaml
---
description: Deploy application to specified environment
argument-hint: [environment] [version]
allowed-tools: Bash, Read, Grep
---

# Deploy Command

Deploy the application to the specified environment.

## Arguments
- `$1` - Environment (dev, staging, prod)
- `$2` - Version tag (optional, defaults to latest)

## Steps

1. Validate the environment argument
2. Check for deployment configuration
3. Run pre-deployment checks
4. Execute deployment
5. Verify deployment success

## Usage

```
/deploy staging v1.2.3
/deploy prod
```
```

### plugins/example-deployment/agents/deployer.md

```yaml
---
name: deployer
description: Autonomous deployment agent. Use for complex multi-step deployments requiring coordination.
tools: Bash, Read, Grep, Edit
model: inherit
---

You are an expert deployment engineer.

## Capabilities

- Analyze deployment configurations
- Execute multi-step deployment processes
- Handle rollbacks when needed
- Verify deployment health

## Process

1. Review deployment configuration
2. Run pre-flight checks
3. Execute deployment steps
4. Monitor for issues
5. Verify success or initiate rollback
```

### plugins/example-deployment/skills/docker-deploy/SKILL.md

```yaml
---
name: docker-deploy
description: Deploy applications using Docker. Use when deploying containerized applications, building images, or managing Docker Compose stacks.
allowed-tools: Bash, Read, Grep
---

# Docker Deployment Skill

## Instructions

### Building Images

```bash
docker build -t app:version .
```

### Deploying with Compose

```bash
docker-compose up -d
```

### Health Checks

```bash
docker ps
docker logs container-name
```

## Examples

### Deploy a new version
```bash
docker build -t myapp:v1.2.3 .
docker-compose down
docker-compose up -d
```
```

### plugins/example-deployment/hooks/hooks.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "description": "Log deployment commands",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-command.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### plugins/example-deployment/scripts/log-command.sh

```bash
#!/bin/bash
# Log deployment-related commands

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ "$COMMAND" == *"deploy"* ]] || [[ "$COMMAND" == *"docker"* ]]; then
  echo "[$(date -Iseconds)] $COMMAND" >> /tmp/deployment-log.txt
fi

echo '{"decision": "approve"}'
```

---

## Summary: Implementation Checklist

### Phase 1: Setup (Day 1)
- [ ] Create GitHub repository
- [ ] Set up directory structure
- [ ] Create marketplace.json
- [ ] Add templates
- [ ] Create scaffolding tools

### Phase 2: Tooling (Day 2)
- [ ] Implement validate.py
- [ ] Implement scaffold.py
- [ ] Implement import.py
- [ ] Implement export.py
- [ ] Add generate_catalog.py

### Phase 3: CI/CD (Day 3)
- [ ] Set up validation workflow
- [ ] Set up catalog generation
- [ ] Create issue templates
- [ ] Create PR templates

### Phase 4: Documentation (Day 4)
- [ ] Write getting-started.md
- [ ] Write creating-plugins.md
- [ ] Write submitting-plugins.md
- [ ] Create README.md

### Phase 5: Example Content (Day 5)
- [ ] Create example-deployment plugin
- [ ] Create example-code-review plugin
- [ ] Test all workflows end-to-end

### Phase 6: Launch
- [ ] Announce marketplace
- [ ] Share installation instructions
- [ ] Accept first community submissions

---

## Part 9: Claude Code Prompt to Generate the Marketplace

Use this prompt with Claude Code to have it scaffold out the entire marketplace structure ready to push to GitHub:

```
Create a Claude Code plugin marketplace in a new directory called "claude-code-marketplace".

Generate ALL files from the plan in claude-code-marketplace-plan.md, including:

1. Directory structure:
   - .claude-plugin/marketplace.json
   - plugins/example-deployment/ (complete working plugin)
   - templates/plugin/, templates/skill/, templates/agent/, templates/command/, templates/hook/
   - tools/scaffold.py, tools/export.py, tools/import.py, tools/validate.py, tools/generate_catalog.py
   - docs/getting-started.md, docs/creating-plugins.md, docs/submitting-plugins.md
   - .github/workflows/validate-plugins.yml, .github/workflows/publish-catalog.yml
   - .github/ISSUE_TEMPLATE/plugin-submission.yml
   - .github/PULL_REQUEST_TEMPLATE.md

2. Make all Python scripts executable and fully functional

3. Create a complete example-deployment plugin with:
   - Working plugin.json
   - At least 2 slash commands (deploy.md, status.md)
   - At least 1 agent (deployer.md)
   - At least 1 skill with SKILL.md (docker-deploy)
   - Working hooks.json with a sample hook
   - Helper scripts in scripts/

4. Create a README.md with:
   - Marketplace overview
   - Installation instructions
   - How to browse and install plugins
   - How to contribute plugins
   - Link to documentation

5. Create a LICENSE file (MIT)

6. Create a .gitignore appropriate for Python projects

7. Generate an initial catalog.json

After creating all files, validate the example plugin by running:
python tools/validate.py example-deployment

Then provide instructions for pushing to GitHub.
```

### Alternative: Minimal Starter Prompt

For a quicker minimal setup:

```
Create a minimal Claude Code plugin marketplace in "claude-code-marketplace" with:

1. .claude-plugin/marketplace.json (empty plugins array)
2. plugins/.gitkeep
3. templates/ with basic plugin, skill, agent, command templates
4. tools/scaffold.py and tools/validate.py (functional)
5. README.md with setup instructions
6. .github/workflows/validate-plugins.yml

Make it ready to push to GitHub and start accepting plugins.
```

### Post-Generation Steps

After Claude generates the files:

```bash
# Navigate to the marketplace
cd claude-code-marketplace

# Initialize git
git init

# Validate everything works
python tools/validate.py --all

# Create GitHub repo and push
gh repo create claude-code-marketplace --public --source=. --push

# Test the marketplace
# In Claude Code:
/plugin marketplace add yourusername/claude-code-marketplace
```

### Customization Options

When running the prompt, you can customize:

| Option | How to Specify |
|--------|----------------|
| Marketplace name | Change "claude-code-marketplace" in the prompt |
| Organization name | Add "Set owner name to 'My Org' in marketplace.json" |
| Categories | Add "Use these categories: devops, security, testing, ai" |
| Example plugins | Add "Create example plugins for: code-review, testing, documentation" |
| License | Add "Use Apache-2.0 license instead of MIT" |

### Example with Customizations

```
Create a Claude Code plugin marketplace called "acme-claude-plugins" with:

- Owner: "ACME Corporation"
- Categories: devops, security, testing, monitoring, utilities
- License: Apache-2.0
- Example plugins:
  1. security-scanner - SAST scanning with commands and skills
  2. test-runner - pytest/jest automation with hooks

Generate all files from claude-code-marketplace-plan.md with these customizations.
Include full Python tooling (scaffold, validate, import, export).
Make everything production-ready.
```
