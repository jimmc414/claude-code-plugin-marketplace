# Submitting Plugins

This guide explains how to submit your plugin to the marketplace.

## Prerequisites

Before submitting, ensure your plugin:

1. Passes validation: `python tools/validate.py my-plugin`
2. Has a complete README.md
3. Has a LICENSE file
4. Has been tested locally
5. Contains no secrets or sensitive data

## Submission Process

### Option 1: Pull Request (Recommended)

1. **Fork the Repository**

   Fork the marketplace repository on GitHub.

2. **Add Your Plugin**

   Clone your fork and add your plugin:
   ```bash
   git clone https://github.com/your-username/claude-code-marketplace.git
   cd claude-code-marketplace

   # Create your plugin
   python tools/scaffold.py plugin my-plugin
   # ... customize your plugin ...
   ```

3. **Validate**

   ```bash
   python tools/validate.py my-plugin
   python tools/validate.py my-plugin --check-conflicts
   ```

4. **Create Branch and Commit**

   ```bash
   git checkout -b add-my-plugin
   git add plugins/my-plugin
   git commit -m "Add my-plugin: Brief description"
   git push origin add-my-plugin
   ```

5. **Open Pull Request**

   Open a PR on GitHub with:
   - Plugin name and description
   - What components are included
   - Any special requirements
   - Screenshots/examples if applicable

### Option 2: Issue Submission

If you can't submit a PR, open an issue using the plugin submission template:

1. Go to Issues → New Issue
2. Select "Plugin Submission" template
3. Fill in all required fields
4. Provide link to your plugin repository

## Review Process

### Automated Checks

When you submit a PR, automated checks will:

1. Validate plugin.json syntax
2. Check all JSON files are valid
3. Verify required files exist
4. Run the validation script

### Manual Review

A maintainer will review your submission for:

1. **Code Quality**: Clean, readable code
2. **Security**: No malicious code, safe hook scripts
3. **Documentation**: Clear README and instructions
4. **Usefulness**: Plugin provides value to users
5. **Originality**: Not a duplicate of existing plugins

### Verification Badge

After passing review, your plugin will be marked as verified:

```bash
python tools/validate.py my-plugin --mark-verified --reviewer "Reviewer Name"
```

Verified plugins appear with a badge in the catalog.

## Submission Checklist

Use this checklist before submitting:

```
[ ] Plugin passes validation (python tools/validate.py my-plugin)
[ ] No conflicts with existing plugins (--check-conflicts)
[ ] plugin.json has all required fields
[ ] README.md is complete with:
    [ ] Description
    [ ] Installation instructions
    [ ] Usage examples
    [ ] Component list
[ ] LICENSE file is included
[ ] No secrets, credentials, or sensitive data
[ ] Tested locally with Claude Code
[ ] Hook scripts are safe and exit properly
[ ] Commands have clear descriptions
[ ] Skills have trigger conditions in description
```

## After Acceptance

Once your plugin is accepted:

1. It will appear in the catalog
2. Users can install it via `/plugin install`
3. You'll be listed as the author
4. Consider promoting it in relevant communities

## Updating Your Plugin

To update an existing plugin:

1. Fork and make changes
2. Bump the version in plugin.json
3. Submit a PR with changelog
4. Previous version remains available until merged

## Removal Requests

To remove your plugin from the marketplace:

1. Open an issue requesting removal
2. Explain the reason
3. A maintainer will process the request

Note: Removal doesn't affect users who already installed the plugin.

## Questions?

- Check the [Creating Plugins](./creating-plugins.md) guide
- Review the [API Reference](./api-reference.md)
- Open an issue for help
