#!/usr/bin/env python3
"""
Fix SKILL.md files with missing frontmatter fields.

Adds 'name' field derived from directory name if missing.
Can be run standalone or imported by other tools.
"""

import re
import sys
from pathlib import Path


def fix_skill_frontmatter(skill_md_path: Path, dry_run: bool = False) -> bool:
    """
    Fix missing frontmatter fields in a SKILL.md file.

    Returns True if changes were made, False otherwise.
    """
    content = skill_md_path.read_text()

    if not content.startswith("---"):
        return False

    parts = content.split("---", 2)
    if len(parts) < 3:
        return False

    frontmatter = parts[1]
    body = parts[2]
    skill_name = skill_md_path.parent.name

    # Check if name is missing
    if "name:" not in frontmatter:
        # Add name as first field in frontmatter
        frontmatter = f"\nname: {skill_name}" + frontmatter

        new_content = f"---{frontmatter}---{body}"

        if not dry_run:
            skill_md_path.write_text(new_content)

        return True

    return False


def fix_all_skills(plugins_dir: Path, dry_run: bool = False) -> dict:
    """Fix all SKILL.md files in all plugins."""
    results = {"fixed": [], "skipped": [], "errors": []}

    for plugin_dir in plugins_dir.iterdir():
        if not plugin_dir.is_dir():
            continue

        skills_dir = plugin_dir / "skills"
        if not skills_dir.exists():
            continue

        for skill_dir in skills_dir.iterdir():
            if not skill_dir.is_dir():
                continue

            skill_md = skill_dir / "SKILL.md"
            if not skill_md.exists():
                continue

            try:
                if fix_skill_frontmatter(skill_md, dry_run):
                    results["fixed"].append(str(skill_md))
                else:
                    results["skipped"].append(str(skill_md))
            except Exception as e:
                results["errors"].append(f"{skill_md}: {e}")

    return results


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Fix SKILL.md frontmatter")
    parser.add_argument("--dry-run", "-n", action="store_true",
                       help="Show what would be changed without modifying files")
    parser.add_argument("--plugin", "-p", help="Fix only a specific plugin")

    args = parser.parse_args()

    plugins_dir = Path(__file__).parent.parent / "plugins"

    if args.plugin:
        plugin_dir = plugins_dir / args.plugin
        if not plugin_dir.exists():
            print(f"Error: Plugin '{args.plugin}' not found")
            sys.exit(1)
        # Create a temp dir structure for single plugin
        results = {"fixed": [], "skipped": [], "errors": []}
        skills_dir = plugin_dir / "skills"
        if skills_dir.exists():
            for skill_dir in skills_dir.iterdir():
                if skill_dir.is_dir():
                    skill_md = skill_dir / "SKILL.md"
                    if skill_md.exists():
                        try:
                            if fix_skill_frontmatter(skill_md, args.dry_run):
                                results["fixed"].append(str(skill_md))
                            else:
                                results["skipped"].append(str(skill_md))
                        except Exception as e:
                            results["errors"].append(f"{skill_md}: {e}")
    else:
        results = fix_all_skills(plugins_dir, args.dry_run)

    # Report results
    mode = "[DRY RUN] " if args.dry_run else ""

    if results["fixed"]:
        print(f"{mode}Fixed {len(results['fixed'])} files:")
        for f in results["fixed"]:
            print(f"  ✓ {f}")

    if results["errors"]:
        print(f"\n{mode}Errors ({len(results['errors'])}):")
        for e in results["errors"]:
            print(f"  ✗ {e}")

    print(f"\n{mode}Summary: {len(results['fixed'])} fixed, {len(results['skipped'])} already valid, {len(results['errors'])} errors")

    sys.exit(1 if results["errors"] else 0)


if __name__ == "__main__":
    main()
