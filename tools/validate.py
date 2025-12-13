#!/usr/bin/env python3
"""
Validate plugins, skills, agents, and commands against schemas.

Usage:
    python validate.py my-plugin
    python validate.py --all
    python validate.py my-plugin --check-conflicts
    python validate.py my-plugin --mark-verified --reviewer "John Doe"
"""

import argparse
import json
import re
import sys
from pathlib import Path
from datetime import datetime

PLUGINS_DIR = Path(__file__).parent.parent / "plugins"
VERIFIED_FILE = Path(__file__).parent.parent / ".verified.json"

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

    # Required: version
    if "version" not in data:
        errors.append(ValidationError(
            str(plugin_json_path),
            "Missing required field: version",
            "warning"
        ))

    # Validate dependencies format if present
    if "dependencies" in data:
        deps = data["dependencies"]
        if not isinstance(deps, dict):
            errors.append(ValidationError(
                str(plugin_json_path),
                "Dependencies must be an object"
            ))
        else:
            for dep_name, version_spec in deps.items():
                if not NAME_PATTERN.match(dep_name):
                    errors.append(ValidationError(
                        str(plugin_json_path),
                        f"Invalid dependency name: '{dep_name}'"
                    ))
                if not isinstance(version_spec, str):
                    errors.append(ValidationError(
                        str(plugin_json_path),
                        f"Dependency version must be a string: '{dep_name}'"
                    ))

    # Validate paths exist
    for path_field in ["commands", "agents", "skills", "hooks", "mcpServers"]:
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


def check_conflicts(plugin_name: str) -> list[ValidationError]:
    """Check for naming conflicts with other plugins."""
    errors = []
    plugin_dir = PLUGINS_DIR / plugin_name

    if not plugin_dir.exists():
        return errors

    # Collect this plugin's names
    commands = set()
    skills = set()
    agents = set()

    cmd_dir = plugin_dir / "commands"
    if cmd_dir.exists():
        commands = {f.stem for f in cmd_dir.glob("*.md")}

    skills_dir = plugin_dir / "skills"
    if skills_dir.exists():
        skills = {d.name for d in skills_dir.iterdir() if d.is_dir() and (d / "SKILL.md").exists()}

    agents_dir = plugin_dir / "agents"
    if agents_dir.exists():
        agents = {f.stem for f in agents_dir.glob("*.md")}

    # Check against other plugins
    for other_dir in PLUGINS_DIR.iterdir():
        if other_dir.name == plugin_name or not other_dir.is_dir():
            continue

        # Check commands
        other_cmd_dir = other_dir / "commands"
        if other_cmd_dir.exists():
            other_commands = {f.stem for f in other_cmd_dir.glob("*.md")}
            conflicts = commands & other_commands
            for cmd in conflicts:
                errors.append(ValidationError(
                    str(cmd_dir),
                    f"Command '/{cmd}' conflicts with plugin '{other_dir.name}'",
                    "warning"
                ))

        # Check skills
        other_skills_dir = other_dir / "skills"
        if other_skills_dir.exists():
            other_skills = {d.name for d in other_skills_dir.iterdir() if d.is_dir()}
            conflicts = skills & other_skills
            for skill in conflicts:
                errors.append(ValidationError(
                    str(skills_dir),
                    f"Skill '{skill}' conflicts with plugin '{other_dir.name}'",
                    "warning"
                ))

        # Check agents
        other_agents_dir = other_dir / "agents"
        if other_agents_dir.exists():
            other_agents = {f.stem for f in other_agents_dir.glob("*.md")}
            conflicts = agents & other_agents
            for agent in conflicts:
                errors.append(ValidationError(
                    str(agents_dir),
                    f"Agent '{agent}' conflicts with plugin '{other_dir.name}'",
                    "warning"
                ))

    return errors


def validate_plugin(plugin_name: str, check_conflict: bool = False) -> list[ValidationError]:
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

    # Check conflicts if requested
    if check_conflict:
        errors.extend(check_conflicts(plugin_name))

    return errors


def load_verified_data() -> dict:
    """Load the verified plugins data."""
    if VERIFIED_FILE.exists():
        with open(VERIFIED_FILE, "r") as f:
            return json.load(f)
    return {"plugins": {}}


def save_verified_data(data: dict):
    """Save the verified plugins data."""
    with open(VERIFIED_FILE, "w") as f:
        json.dump(data, f, indent=2)


def mark_verified(plugin_name: str, reviewer: str):
    """Mark a plugin as verified after manual review."""
    plugin_dir = PLUGINS_DIR / plugin_name
    if not plugin_dir.exists():
        print(f"Error: Plugin '{plugin_name}' not found")
        return False

    # First validate the plugin
    errors = validate_plugin(plugin_name, check_conflict=True)
    error_count = sum(1 for e in errors if e.severity == "error")

    if error_count > 0:
        print(f"Error: Plugin has {error_count} validation errors. Fix before marking verified.")
        for error in errors:
            print(f"  {error}")
        return False

    # Update verified data
    data = load_verified_data()
    data["plugins"][plugin_name] = {
        "verified": True,
        "verified_at": datetime.utcnow().isoformat() + "Z",
        "verified_by": reviewer
    }
    save_verified_data(data)

    print(f"Plugin '{plugin_name}' marked as verified by {reviewer}")
    return True


def is_verified(plugin_name: str) -> dict | None:
    """Check if a plugin is verified."""
    data = load_verified_data()
    return data["plugins"].get(plugin_name)


def main():
    parser = argparse.ArgumentParser(description="Validate Claude Code plugins")
    parser.add_argument("plugin", nargs="?", help="Plugin name to validate")
    parser.add_argument("--all", "-a", action="store_true", help="Validate all plugins")
    parser.add_argument("--check-conflicts", "-c", action="store_true", help="Check for naming conflicts")
    parser.add_argument("--mark-verified", action="store_true", help="Mark plugin as verified")
    parser.add_argument("--reviewer", default="Unknown", help="Name of reviewer (for --mark-verified)")

    args = parser.parse_args()

    if args.mark_verified:
        if not args.plugin:
            print("Error: Specify a plugin name to mark verified")
            sys.exit(1)
        success = mark_verified(args.plugin, args.reviewer)
        sys.exit(0 if success else 1)

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

        # Check verification status
        verified = is_verified(plugin_name)
        if verified:
            print(f"  [VERIFIED] by {verified['verified_by']} at {verified['verified_at']}")

        errors = validate_plugin(plugin_name, args.check_conflicts)

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
