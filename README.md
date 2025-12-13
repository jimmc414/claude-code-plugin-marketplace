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

## Share Your Skills with the Community

Have skills, agents, or hooks you want to share? The **plugin-publisher** plugin automates the entire contribution workflow:

```bash
# Install the publisher
/plugin install plugin-publisher@community-claude-plugins
```

Then just ask Claude:
```
"I want to share my skills with the community"
```

Claude will:
1. **Scan** your `~/.claude/` installation for components
2. **Package** your selected skills/agents/hooks into a plugin
3. **Submit** a PR to the marketplace automatically

No need to understand plugin structure, manifests, or GitHub workflows - it's all handled for you.

See [plugin-publisher](#plugin-publisher) below for details.

---

## Available Plugins

### plugin-publisher
**Category:** utilities | **Version:** 1.0.0

Extract local skills, agents, and hooks and publish them to plugin marketplaces with guided assistance.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `plugin-publishing` | Knowledge layer for Claude Code paths, plugin formats, marketplace requirements |
| **Agent** | `plugin-scanner` | Scans local installation to inventory all skills, agents, commands, hooks |
| **Agent** | `plugin-packager` | Creates plugin structure from selected components, generates metadata |
| **Agent** | `plugin-submitter` | Handles GitHub fork/branch/PR workflow to submit to marketplaces |

**Workflow:**
```
Scan Installation → Select Components → Package Plugin → Submit PR
```

```bash
/plugin install plugin-publisher@community-claude-plugins
```

---

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

### adversarial-testing
**Category:** testing | **Version:** 1.0.0

Adversarial test generation that finds real bugs by inverting the reward structure. Instead of rewarding passing tests, rewards tests that fail (and prove a bug exists).

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `adversarial-analysis` | Calculate realism bounds (3-sigma), extract contracts, identify vulnerability surfaces |
| **Skill** | `adversarial-patterns` | Library of attack vectors + anti-patterns to reject (gaming detection) |
| **Agent** | `adversarial-orchestrator` | Coordinates workflow, max 3 iterations, parses validator results |
| **Agent** | `adversarial-generator` | Creates candidate tests with documented hypotheses |
| **Agent** | `adversarial-validator` | 4-phase quality gate: static → dynamic → oracle → mutation |

**Key Features:**
- 3-sigma constraint prevents reward hacking with extreme inputs
- Oracle verification ensures failing tests reveal real bugs
- Mutation testing validates passing tests are strong enough
- Subtle gaming detection (ghost imports, dead asserts, tautologies)

```bash
/plugin install adversarial-testing@community-claude-plugins
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

## Contributing Your Own Plugins

### The Easy Way: Use plugin-publisher

Install the plugin-publisher and let Claude do the work:

```bash
/plugin install plugin-publisher@community-claude-plugins
```

Then:
```
"Help me share my deployment tools with the community"
```

Claude will scan your installation, package your components, and submit a PR.

### The Manual Way: Use the Python Tools

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

**Option 1: Automated (Recommended)**
1. Install plugin-publisher: `/plugin install plugin-publisher@community-claude-plugins`
2. Tell Claude: "I want to share my skills"
3. Follow the guided workflow

**Option 2: Manual**
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
