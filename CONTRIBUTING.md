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

## Getting Started

1. **Fork the Repository**

   Click "Fork" on GitHub to create your copy.

2. **Clone Your Fork**

   ```bash
   git clone https://github.com/your-username/claude-code-marketplace.git
   cd claude-code-marketplace
   ```

3. **Create a Branch**

   ```bash
   git checkout -b feature/my-contribution
   ```

4. **Make Changes**

   Edit files, add plugins, improve code.

5. **Test Changes**

   ```bash
   # Validate all plugins
   python tools/validate.py --all

   # Check JSON syntax
   find . -name "*.json" -exec python -m json.tool {} \; > /dev/null
   ```

6. **Commit Changes**

   ```bash
   git add .
   git commit -m "Description of changes"
   ```

7. **Push and Create PR**

   ```bash
   git push origin feature/my-contribution
   ```

   Then open a Pull Request on GitHub.

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
