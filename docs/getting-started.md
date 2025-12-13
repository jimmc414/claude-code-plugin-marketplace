# Getting Started with the Claude Code Plugin Marketplace

Welcome to the community-maintained Claude Code plugin marketplace. This guide will help you install plugins and get started.

## Prerequisites

- Claude Code CLI installed and configured
- Internet access for downloading plugins

## Adding the Marketplace

Add this marketplace to your Claude Code installation:

```bash
/plugin marketplace add yourname/claude-code-marketplace
```

You can also add it via HTTPS URL:

```bash
/plugin marketplace add https://github.com/yourname/claude-code-marketplace.git
```

## Browsing Plugins

Open the interactive plugin browser:

```bash
/plugin
```

This will show you all available plugins from added marketplaces.

## Installing a Plugin

Install a specific plugin:

```bash
/plugin install example-deployment@community-claude-plugins
```

The format is: `plugin-name@marketplace-name`

## Listing Installed Plugins

View all plugins currently installed:

```bash
/plugin list
```

## Uninstalling a Plugin

Remove a plugin you no longer need:

```bash
/plugin uninstall example-deployment
```

## Updating Plugins

Update all plugins to their latest versions:

```bash
/plugin update
```

Or update a specific plugin:

```bash
/plugin update example-deployment
```

## Using Plugin Features

### Slash Commands

After installing a plugin, its slash commands become available:

```bash
/deploy staging
/status prod
```

### Agent Skills

Skills are automatically available to Claude and will be used when relevant to your tasks.

### Agents

Invoke specialized agents by name:

```
Use the deployer agent to deploy to staging
```

## Troubleshooting

### Plugin Not Found

Make sure the marketplace is added:
```bash
/plugin marketplace list
```

### Commands Not Working

Try restarting Claude Code after installing plugins:
```bash
# Exit and restart claude
```

### Validation Errors

Check if the plugin passes validation:
```bash
python tools/validate.py plugin-name
```

## Getting Help

- Check the [API Reference](./api-reference.md) for detailed schemas
- See [Creating Plugins](./creating-plugins.md) to build your own
- Submit issues on GitHub

## Next Steps

- Browse the [plugin catalog](../catalog.json)
- [Create your own plugin](./creating-plugins.md)
- [Submit a plugin](./submitting-plugins.md) to the marketplace
