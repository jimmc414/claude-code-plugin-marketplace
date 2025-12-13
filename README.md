# Claude Code Plugin Marketplace

A community-maintained marketplace for Claude Code plugins, skills, agents, and hooks.

## Quick Start

### Add the Marketplace

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
```

### Browse Plugins

```bash
/plugin
```

### Install a Plugin

```bash
/plugin install parallel-workflows@community-claude-plugins
```

---

## Available Plugins

### parallel-workflows
**Category:** development | **Version:** 1.0.0

Parallel workflow orchestration using git worktrees for concurrent Claude Code sessions.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `parallel-orchestrator` | Manage parallel workstreams, analyze work items, coordinate workers |
| **Skill** | `parallel-worker` | Execute focused tasks in a worktree, make checkpoint commits |
| **Skill** | `parallel-retrospective` | Analyze completed workflows, identify lessons learned |
| **Agent** | `parallel-setup` | Create worktrees and launch scripts for parallel work |
| **Agent** | `parallel-monitor` | Check worker status, detect stalls, find blocked workers |
| **Agent** | `parallel-integrate` | Merge branches, resolve conflicts, finalize integration |

```bash
/plugin install parallel-workflows@community-claude-plugins
```

---

### local-llm
**Category:** development | **Version:** 1.0.0

Manage local Ollama LLM models for development and testing.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `local-llm` | Comprehensive Ollama management - models, VRAM, Modelfiles, API integration |
| **Agent** | `llm-setup` | Auto-detect hardware, install Ollama, recommend and pull models |

**Includes:** 5 ready-to-use Modelfile templates (fast, reasoning, code-generation, json-output, analysis)

```bash
/plugin install local-llm@community-claude-plugins
```

---

### example-deployment
**Category:** devops | **Version:** 1.0.0

Deployment automation tools for Docker, Kubernetes, and cloud platforms.

| Type | Name | Description |
|------|------|-------------|
| **Command** | `/deploy` | Deploy application to specified environment |
| **Command** | `/status` | Check deployment status for an environment |
| **Skill** | `docker-deploy` | Docker deployment automation |
| **Agent** | `deployer` | Autonomous deployment agent for complex multi-step deployments |
| **Hook** | `PostToolUse` | Logs deployment-related commands for audit trail |

```bash
/plugin install example-deployment@community-claude-plugins
```

---

## Features

This marketplace provides:

- **Slash Commands**: User-invoked shortcuts (e.g., `/deploy`, `/status`)
- **Agent Skills**: Model-invoked capabilities that Claude uses automatically
- **Specialized Agents**: Task-focused agents for complex operations
- **Hooks**: Event-driven automation for tool calls and prompts
- **Import/Export Tools**: Share and reuse components across projects

## Creating Plugins

Want to contribute a plugin? Start here:

```bash
# Clone the repository
git clone https://github.com/jimmc414/claude-code-plugin-marketplace.git
cd claude-code-plugin-marketplace

# Scaffold a new plugin
python tools/scaffold.py plugin my-plugin --description "My plugin"

# Add components
python tools/scaffold.py command my-cmd --plugin my-plugin
python tools/scaffold.py skill my-skill --plugin my-plugin
python tools/scaffold.py agent my-agent --plugin my-plugin

# Validate
python tools/validate.py my-plugin

# Submit a PR!
```

See [Creating Plugins](./docs/creating-plugins.md) for the full guide.

## Tools

| Tool | Description |
|------|-------------|
| `scaffold.py` | Create new plugins and components |
| `validate.py` | Validate plugin structure and syntax |
| `export.py` | Export plugins, skills, agents, commands, or hooks |
| `import.py` | Import plugins from zip files or URLs |
| `generate_catalog.py` | Generate the plugin catalog |

## Documentation

- [Getting Started](./docs/getting-started.md) - Install and use plugins
- [Creating Plugins](./docs/creating-plugins.md) - Build your own plugins
- [Submitting Plugins](./docs/submitting-plugins.md) - Contribute to the marketplace
- [API Reference](./docs/api-reference.md) - Complete schema documentation
- [Local Development](./docs/local-development.md) - Test plugins locally
- [Security Guidelines](./docs/security.md) - Best practices for security
- [CLAUDE.md](./CLAUDE.md) - Operator cheatsheet for AI assistants

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                 # Slash commands
│   └── my-command.md
├── agents/                   # Specialized agents
│   └── my-agent.md
├── skills/                   # Agent skills
│   └── my-skill/
│       └── SKILL.md
├── hooks/                    # Event hooks
│   └── hooks.json
├── scripts/                  # Hook scripts
│   └── my-hook.sh
└── README.md
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Quick Contribution Steps

1. Fork the repository
2. Create your plugin or improvement
3. Run validation: `python tools/validate.py --all`
4. Submit a pull request

## Verification

Plugins that pass manual review receive a **verified** badge. Look for verified plugins for extra confidence.

## License

This marketplace and included plugins are licensed under MIT unless otherwise specified. See [LICENSE](./LICENSE).

## Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Plugin System Guide](https://docs.anthropic.com/claude-code/plugins)
- [Report Issues](https://github.com/jimmc414/claude-code-plugin-marketplace/issues)
