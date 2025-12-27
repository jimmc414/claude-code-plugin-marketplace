# Contributing to Claude Code Plugin Marketplace

Thank you for your interest in contributing! This document provides guidelines for contributing to the marketplace.

## Ways to Contribute

### 1. Submit a Plugin

Create and share your own plugins. See [Creating Plugins](./docs/creating-plugins.md) for a complete guide.

### 2. Improve Existing Plugins

- Fix bugs
- Add features
- Improve documentation
- Enhance examples

### 3. Improve Tooling

- Enhance validation scripts
- Add new export/import features
- Improve scaffolding templates

### 4. Documentation

- Fix typos
- Clarify instructions
- Add examples
- Translate documentation

### 5. Review Plugins

Help review submitted plugins for quality and security.

## Submitting Plugins

### Option 1: Automated (Recommended)

Use the **plugin-publisher** plugin to automatically package and submit your skills, agents, and commands:

```bash
# 1. Add the marketplace
/plugin marketplace add jimmc414/claude-code-plugin-marketplace

# 2. Install the publisher plugin
/plugin install plugin-publisher@jimmc414

# 3. Tell Claude what you want to share
"I want to share my deployment tools with the community"
```

Claude will:
1. Scan your `~/.claude/` for skills, agents, commands, and hooks
2. Let you select which components to include
3. Package them into a properly structured plugin
4. Submit a PR to the marketplace automatically

**No cloning required!** This is the easiest way to contribute.

### Option 2: Manual

For more control, or to contribute improvements to existing plugins:

1. **Fork the Repository**

   Click "Fork" on GitHub to create your copy.

2. **Clone Your Fork**

   ```bash
   git clone https://github.com/your-username/claude-code-plugin-marketplace.git
   cd claude-code-plugin-marketplace
   ```

3. **Create a Branch**

   ```bash
   git checkout -b feature/my-contribution
   ```

4. **Create or Edit Plugins**

   ```bash
   # Scaffold a new plugin
   python tools/scaffold.py plugin my-plugin --description "My plugin"

   # Add components
   python tools/scaffold.py command my-cmd --plugin my-plugin
   python tools/scaffold.py skill my-skill --plugin my-plugin
   python tools/scaffold.py agent my-agent --plugin my-plugin
   ```

5. **Validate**

   ```bash
   python tools/validate.py my-plugin    # Single plugin
   python tools/validate.py --all        # All plugins
   ```

6. **Commit and Push**

   ```bash
   git add .
   git commit -m "Add my-plugin: description of what it does"
   git push origin feature/my-contribution
   ```

7. **Create Pull Request**

   Open a PR on GitHub. The catalog will auto-update when merged.

## Code Standards

### Python Code

- Python 3.11+ compatible
- Use type hints where helpful
- Include docstrings for functions
- Follow PEP 8 style guidelines

### JSON Files

- Valid JSON (test with `python -m json.tool`)
- 2-space indentation
- No trailing commas

### Markdown

- Use GitHub-flavored markdown
- Include code examples
- Keep lines under 100 characters

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Add comments for complex logic
- Make scripts executable (`chmod +x`)

## Plugin Guidelines

### Naming

- Lowercase letters, numbers, hyphens only
- Descriptive but concise
- No generic names like "utils" or "helpers"

### Documentation

- Include README.md with:
  - Description
  - Installation instructions
  - Usage examples
  - Component list

### Testing

- Test all commands locally
- Verify skills trigger correctly
- Ensure hooks don't block operations
- Check for conflicts with existing plugins

### Security

- No hardcoded credentials
- Validate all inputs
- Handle errors gracefully
- Follow [Security Guidelines](./docs/security.md)

## Review Process

### For Plugin Submissions

1. **Automated Checks**
   - JSON validation
   - Plugin structure validation
   - Conflict checking

2. **Manual Review**
   - Code quality
   - Security assessment
   - Documentation completeness
   - Usefulness evaluation

3. **Feedback**
   - Reviewers may request changes
   - Address feedback promptly
   - Ask questions if unclear

4. **Merge**
   - Once approved, PR is merged
   - Catalog is auto-updated
   - Plugin becomes available

### For Other Contributions

- Standard code review process
- At least one maintainer approval
- All tests must pass

## Communication

### Issues

- Use issue templates when available
- Provide detailed descriptions
- Include reproduction steps for bugs
- Label issues appropriately

### Pull Requests

- Use the PR template
- Link related issues
- Describe changes clearly
- Be responsive to feedback

### Discussions

- Use GitHub Discussions for questions
- Be respectful and constructive
- Help others when you can

## Recognition

Contributors are recognized in:
- Plugin author credits
- Changelog mentions
- README contributors section (for significant contributions)

## Questions?

- Open an issue for help
- Check existing documentation
- Review similar plugins for examples

Thank you for contributing to the Claude Code Plugin Marketplace!
