#!/usr/bin/env python3
"""
Import plugins, skills, agents, commands, or hooks from external sources.

Usage:
    python import.py plugin ./path/to/plugin.zip
    python import.py plugin https://github.com/user/repo/releases/download/v1.0/plugin.zip
    python import.py skill ./path/to/skill-folder --plugin my-plugin
    python import.py agent ./path/to/agent.md --plugin my-plugin
    python import.py command ./path/to/command.md --plugin my-plugin
    python import.py hook ./path/to/hooks-folder --plugin my-plugin
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


def import_hooks(source: str, plugin_name: str, force: bool = False) -> bool:
    """Import hooks (hooks.json + scripts) into a plugin."""
    source_path = Path(source)

    if not source_path.exists():
        print(f"Error: Source not found: {source_path}")
        return False

    plugin_dir = PLUGINS_DIR / plugin_name
    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin_name}' does not exist")
        return False

    # Check for hooks subdirectory or hooks.json
    source_hooks_dir = source_path / "hooks" if (source_path / "hooks").exists() else None
    source_scripts_dir = source_path / "scripts" if (source_path / "scripts").exists() else None

    if not source_hooks_dir and not source_scripts_dir:
        # Maybe source is directly a hooks folder
        if (source_path / "hooks.json").exists():
            source_hooks_dir = source_path
        else:
            print("Error: Source must contain hooks/ or scripts/ directory, or a hooks.json file")
            return False

    # Import hooks directory
    if source_hooks_dir:
        target_hooks = plugin_dir / "hooks"
        if target_hooks.exists() and not force:
            print(f"Error: Hooks already exist in plugin. Use --force to overwrite.")
            return False
        if target_hooks.exists():
            shutil.rmtree(target_hooks)
        target_hooks.mkdir(parents=True, exist_ok=True)

        for item in source_hooks_dir.iterdir():
            if item.is_file():
                shutil.copy(item, target_hooks / item.name)
            elif item.is_dir():
                shutil.copytree(item, target_hooks / item.name)

    # Import scripts directory
    if source_scripts_dir:
        target_scripts = plugin_dir / "scripts"
        if target_scripts.exists() and not force:
            print(f"Error: Scripts already exist in plugin. Use --force to overwrite.")
            return False
        if target_scripts.exists():
            shutil.rmtree(target_scripts)
        shutil.copytree(source_scripts_dir, target_scripts)

        # Make scripts executable
        for script in target_scripts.glob("*.sh"):
            os.chmod(script, 0o755)

    print(f"Imported hooks to: {plugin_dir}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Import Claude Code plugin components")
    parser.add_argument("type", choices=["plugin", "skill", "agent", "command", "hook"])
    parser.add_argument("source", help="Path or URL to import from")
    parser.add_argument("--plugin", "-p", help="Target plugin name (for skill/agent/command/hook)")
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
    elif args.type == "hook":
        if not args.plugin:
            print("Error: --plugin required for hook import")
            return
        import_hooks(args.source, args.plugin, args.force)


if __name__ == "__main__":
    main()
