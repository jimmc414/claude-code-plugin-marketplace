# Local Development Guide

This guide covers how to develop and test plugins locally before submitting.

## Setting Up Your Environment

### 1. Clone the Marketplace

```bash
git clone https://github.com/yourname/claude-code-marketplace.git
cd claude-code-marketplace
```

### 2. Create Your Plugin

```bash
python tools/scaffold.py plugin my-plugin --description "My plugin"
```

### 3. Add to Local Marketplace

In Claude Code, add the local directory as a marketplace:

```bash
/plugin marketplace add ./claude-code-marketplace
```

## Development Workflow

### Quick Iteration Cycle

1. Edit your plugin files
2. Validate changes:
   ```bash
   python tools/validate.py my-plugin
   ```
3. Test in Claude Code:
   ```bash
   /plugin install my-plugin@community-claude-plugins
   ```
4. Restart Claude Code to pick up changes
5. Test your commands/skills
6. Repeat

### Hot Reloading

Claude Code doesn't hot-reload plugins. After changes:

1. Make your edits
2. Restart Claude Code
3. Test the changes

### Testing Commands

After installing, test your commands:

```bash
/my-command arg1 arg2
```

### Testing Skills

Skills are auto-triggered. Test by asking relevant questions:

```
"Help me with [task that should trigger your skill]"
```

### Testing Agents

Invoke your agent by name:

```
"Use the my-agent agent to help with this task"
```

### Testing Hooks

Hooks are triggered automatically. To test:

1. Enable debug logging in your script
2. Perform actions that trigger the hook
3. Check the logs

## Debugging

### Enable Script Logging

Add logging to hook scripts:

```bash
#!/bin/bash
# At the top of your script
LOG_FILE="/tmp/my-hook-debug.log"
exec 2>> "$LOG_FILE"
echo "[$(date)] Hook triggered" >> "$LOG_FILE"

INPUT=$(cat)
echo "[$(date)] Input: $INPUT" >> "$LOG_FILE"
```

Then check the log:

```bash
tail -f /tmp/my-hook-debug.log
```

### Validate JSON Files

```bash
# Validate all JSON in your plugin
python -m json.tool plugins/my-plugin/.claude-plugin/plugin.json
python -m json.tool plugins/my-plugin/hooks/hooks.json
```

### Check YAML Frontmatter

Ensure commands/agents/skills have valid frontmatter:

```yaml
---
name: my-thing
description: What it does
---
```

Must have:
- Start with `---`
- End with `---`
- Valid YAML between

### Validate Entire Plugin

```bash
python tools/validate.py my-plugin

# Check for conflicts too
python tools/validate.py my-plugin --check-conflicts
```

## Testing Export/Import

Test the export functionality:

```bash
# Export your plugin
python tools/export.py plugin my-plugin --output ./test-export

# Export just hooks
python tools/export.py hook --plugin my-plugin --output ./test-export

# Import into a test plugin
python tools/scaffold.py plugin test-import
python tools/import.py hook ./test-export/my-plugin-hooks --plugin test-import
```

## Common Issues

### Plugin Not Appearing

1. Check marketplace is added:
   ```bash
   /plugin marketplace list
   ```

2. Verify plugin.json is valid:
   ```bash
   python -m json.tool plugins/my-plugin/.claude-plugin/plugin.json
   ```

### Command Not Working

1. Check frontmatter has `description`
2. Verify file is `.md` extension
3. Check file is in `commands/` directory
4. Restart Claude Code

### Skill Not Triggering

1. Ensure description includes trigger conditions
2. Verify SKILL.md exists in skill directory
3. Check skill directory name matches

### Hook Not Firing

1. Verify hooks.json is valid JSON
2. Check matcher pattern matches tool name
3. Ensure script is executable: `chmod +x scripts/my-hook.sh`
4. Check script outputs valid JSON
5. Check script exits with code 0

### Script Permission Denied

```bash
chmod +x plugins/my-plugin/scripts/*.sh
```

## Testing Checklist

Before submitting, test:

- [ ] All commands work with various arguments
- [ ] Skills trigger when expected
- [ ] Agents respond appropriately
- [ ] Hooks don't block normal operations
- [ ] Plugin validates without errors
- [ ] No conflicts with existing plugins
- [ ] README is accurate
- [ ] All JSON files are valid

## Useful Commands

```bash
# Validate
python tools/validate.py my-plugin

# Check conflicts
python tools/validate.py my-plugin --check-conflicts

# Generate catalog
python tools/generate_catalog.py

# Export for testing
python tools/export.py plugin my-plugin

# Make scripts executable
chmod +x plugins/my-plugin/scripts/*.sh

# Check JSON syntax
python -m json.tool file.json

# Test hook script manually
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./scripts/my-hook.sh
```

## Next Steps

- Review [Security Guidelines](./security.md)
- Check [API Reference](./api-reference.md)
- [Submit your plugin](./submitting-plugins.md)
