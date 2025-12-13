#!/usr/bin/env python3
"""
Export plugins, skills, agents, commands, or hooks to standalone packages.

Usage:
    python export.py plugin my-plugin --output ./exported/
    python export.py skill my-skill --plugin my-plugin --output ./exported/
    python export.py agent my-agent --plugin my-plugin --output ./exported/
    python export.py command my-cmd --plugin my-plugin --output ./exported/
    python export.py hook --plugin my-plugin --output ./exported/
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


def export_hooks(plugin_name: str, output_dir: Path) -> Path:
    """Export hooks from a plugin (hooks.json + scripts)."""
    plugin_dir = PLUGINS_DIR / plugin_name
    hooks_dir = plugin_dir / "hooks"
    scripts_dir = plugin_dir / "scripts"

    if not hooks_dir.exists() and not scripts_dir.exists():
        raise FileNotFoundError(f"No hooks found in plugin '{plugin_name}'")

    output_dir.mkdir(parents=True, exist_ok=True)
    export_path = output_dir / f"{plugin_name}-hooks"

    if export_path.exists():
        shutil.rmtree(export_path)

    export_path.mkdir(parents=True)

    # Copy hooks directory
    if hooks_dir.exists():
        hooks_export = export_path / "hooks"
        shutil.copytree(hooks_dir, hooks_export)

    # Copy scripts directory
    if scripts_dir.exists():
        scripts_export = export_path / "scripts"
        shutil.copytree(scripts_dir, scripts_export)

    # Create a manifest for the hooks
    hooks_manifest = {
        "source_plugin": plugin_name,
        "exported_at": datetime.utcnow().isoformat() + "Z",
        "contents": {
            "hooks_json": (hooks_dir / "hooks.json").exists() if hooks_dir.exists() else False,
            "scripts": list(scripts_dir.glob("*.sh")) if scripts_dir.exists() else []
        }
    }
    hooks_manifest["contents"]["scripts"] = [s.name for s in hooks_manifest["contents"]["scripts"]]

    manifest_path = export_path / "manifest.json"
    with open(manifest_path, "w") as f:
        json.dump(hooks_manifest, f, indent=2)

    print(f"Exported hooks: {export_path}")
    print(f"Contents: hooks.json={hooks_manifest['contents']['hooks_json']}, scripts={hooks_manifest['contents']['scripts']}")
    return export_path


def export_all(output_dir: Path):
    """Export all plugins."""
    for plugin_dir in PLUGINS_DIR.iterdir():
        if plugin_dir.is_dir() and (plugin_dir / ".claude-plugin" / "plugin.json").exists():
            try:
                export_plugin(plugin_dir.name, output_dir)
            except Exception as e:
                print(f"Error exporting {plugin_dir.name}: {e}")


def main():
    parser = argparse.ArgumentParser(description="Export Claude Code plugin components")
    parser.add_argument("type", choices=["plugin", "skill", "agent", "command", "hook", "all"])
    parser.add_argument("name", nargs="?", help="Name of the component")
    parser.add_argument("--plugin", "-p", help="Plugin name (for skill/agent/command/hook)")
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
    elif args.type == "hook":
        if not args.plugin:
            print("Error: --plugin required for hook export")
            return
        export_hooks(args.plugin, output_dir)
    elif args.type == "all":
        export_all(output_dir)


if __name__ == "__main__":
    main()
