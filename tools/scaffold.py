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


def scaffold_hook(name: str, plugin: str, description: str = ""):
    """Create a new hook script in a plugin."""
    plugin_dir = PLUGINS_DIR / plugin

    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin}' does not exist")
        return False

    scripts_dir = plugin_dir / "scripts"
    scripts_dir.mkdir(exist_ok=True)

    script_path = scripts_dir / f"{name}.sh"

    if script_path.exists():
        print(f"Error: Hook script '{name}' already exists in plugin '{plugin}'")
        return False

    template_path = TEMPLATES_DIR / "hook" / "scripts" / "hook-template.sh"
    with open(template_path, "r") as f:
        content = f.read()

    with open(script_path, "w") as f:
        f.write(content)

    # Make executable
    os.chmod(script_path, 0o755)

    print(f"Created hook script: {script_path}")
    print(f"Note: Add hook configuration to {plugin_dir}/hooks/hooks.json")
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
        if not args.plugin:
            print("Error: --plugin required for hook")
            return
        scaffold_hook(args.name, args.plugin, args.description)


if __name__ == "__main__":
    main()
