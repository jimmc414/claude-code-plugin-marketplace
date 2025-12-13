#!/usr/bin/env python3
"""
Generate catalog.json from all plugins in the plugins/ directory.

Usage:
    python generate_catalog.py
    python generate_catalog.py --output ./custom-catalog.json
"""

import argparse
import json
from datetime import datetime
from pathlib import Path

PLUGINS_DIR = Path(__file__).parent.parent / "plugins"
CATALOG_PATH = Path(__file__).parent.parent / "catalog.json"
VERIFIED_FILE = Path(__file__).parent.parent / ".verified.json"
MARKETPLACE_FILE = Path(__file__).parent.parent / ".claude-plugin" / "marketplace.json"


def load_verified_data() -> dict:
    """Load the verified plugins data."""
    if VERIFIED_FILE.exists():
        with open(VERIFIED_FILE, "r") as f:
            return json.load(f)
    return {"plugins": {}}


def load_marketplace_data() -> dict:
    """Load the marketplace.json data."""
    if MARKETPLACE_FILE.exists():
        with open(MARKETPLACE_FILE, "r") as f:
            return json.load(f)
    return {}


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
        components["commands"] = len([f for f in commands_dir.glob("*.md") if f.is_file()])

    agents_dir = plugin_dir / "agents"
    if agents_dir.exists():
        components["agents"] = len([f for f in agents_dir.glob("*.md") if f.is_file()])

    skills_dir = plugin_dir / "skills"
    if skills_dir.exists():
        components["skills"] = len([d for d in skills_dir.iterdir() if d.is_dir() and (d / "SKILL.md").exists()])

    hooks_file = plugin_dir / "hooks" / "hooks.json"
    if hooks_file.exists():
        try:
            with open(hooks_file, "r") as f:
                hooks_data = json.load(f)
                components["hooks"] = bool(hooks_data.get("hooks"))
        except json.JSONDecodeError:
            components["hooks"] = False

    mcp_file = plugin_dir / ".mcp.json"
    if mcp_file.exists():
        try:
            with open(mcp_file, "r") as f:
                mcp_data = json.load(f)
                components["mcp_servers"] = len(mcp_data.get("mcpServers", {}))
        except json.JSONDecodeError:
            components["mcp_servers"] = 0

    return components


def generate_catalog(output_path: Path = None):
    """Generate catalog.json from plugins directory."""
    if output_path is None:
        output_path = CATALOG_PATH

    plugins = []
    categories = {}

    # Load verified data
    verified_data = load_verified_data()

    # Load marketplace data for metadata
    marketplace_data = load_marketplace_data()
    marketplace_name = marketplace_data.get("name", "community-claude-plugins")

    for plugin_dir in sorted(PLUGINS_DIR.iterdir()):
        if not plugin_dir.is_dir():
            continue

        plugin_json_path = plugin_dir / ".claude-plugin" / "plugin.json"
        if not plugin_json_path.exists():
            continue

        try:
            with open(plugin_json_path, "r") as f:
                data = json.load(f)
        except json.JSONDecodeError:
            print(f"Warning: Invalid JSON in {plugin_json_path}, skipping")
            continue

        plugin_name = data.get("name", plugin_dir.name)
        category = data.get("category", "utilities")
        categories[category] = categories.get(category, 0) + 1

        # Get author info
        author_data = data.get("author", {})
        if isinstance(author_data, dict):
            author_name = author_data.get("name", "Unknown")
        else:
            author_name = str(author_data)

        # Build plugin entry
        plugin_entry = {
            "name": plugin_name,
            "version": data.get("version", "1.0.0"),
            "description": data.get("description", ""),
            "author": author_name,
            "category": category,
            "keywords": data.get("keywords", []),
            "components": count_components(plugin_dir),
            "install_command": f"/plugin install {plugin_name}@{marketplace_name}",
            "source_url": f"./plugins/{plugin_name}",
            "dependencies": data.get("dependencies", {}),
        }

        # Add verification info if present
        verified_info = verified_data.get("plugins", {}).get(plugin_name)
        if verified_info:
            plugin_entry["verified"] = verified_info.get("verified", False)
            plugin_entry["verified_at"] = verified_info.get("verified_at")
            plugin_entry["verified_by"] = verified_info.get("verified_by")
        else:
            plugin_entry["verified"] = False

        plugins.append(plugin_entry)

    catalog = {
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "marketplace_name": marketplace_name,
        "total_plugins": len(plugins),
        "verified_plugins": sum(1 for p in plugins if p.get("verified")),
        "plugins": plugins,
        "categories": categories
    }

    with open(output_path, "w") as f:
        json.dump(catalog, f, indent=2)

    print(f"Generated catalog with {len(plugins)} plugins ({catalog['verified_plugins']} verified)")
    print(f"Categories: {categories}")
    print(f"Output: {output_path}")

    return catalog


def main():
    parser = argparse.ArgumentParser(description="Generate Claude Code plugin catalog")
    parser.add_argument("--output", "-o", help="Output path for catalog.json")

    args = parser.parse_args()

    output_path = Path(args.output) if args.output else None
    generate_catalog(output_path)


if __name__ == "__main__":
    main()
