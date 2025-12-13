# plugin-publisher

Extract your local Claude Code skills, agents, and hooks and publish them to plugin marketplaces with guided assistance.

## The Problem

You've created useful skills and agents in your local `~/.claude/` directory. Sharing them requires:
- Understanding the plugin structure
- Creating proper manifests
- Writing documentation
- Submitting to marketplaces

This plugin automates that entire workflow.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install plugin-publisher@community-claude-plugins
```

## Components

### Skill

| Name | Description |
|------|-------------|
| `plugin-publishing` | Knowledge layer for Claude Code paths, plugin formats, and marketplace requirements |

### Agents

| Agent | Description |
|-------|-------------|
| `plugin-scanner` | Scans your local installation to inventory all skills, agents, commands, and hooks |
| `plugin-packager` | Creates a properly structured plugin from your selected components |
| `plugin-submitter` | Handles GitHub fork/branch/PR workflow to submit to marketplaces |

## Workflow

```
You: "I want to share my skills with the community"
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│                      plugin-scanner                          │
│  • Scans ~/.claude/skills/, agents/, commands/               │
│  • Extracts settings.json for hooks                          │
│  • Detects related components (parallel-* grouping)          │
│  • Presents inventory table                                  │
└─────────────────────────────────────────────────────────────┘
     │ You select: "parallel-orchestrator, parallel-worker"
     ▼
┌─────────────────────────────────────────────────────────────┐
│                     plugin-packager                          │
│  • Asks for plugin name, description, author                 │
│  • Detects and fixes hardcoded paths                         │
│  • Creates plugin structure                                  │
│  • Generates README and plugin.json                          │
│  • Validates the result                                      │
└─────────────────────────────────────────────────────────────┘
     │ Plugin created in plugins/parallel-workflows/
     ▼
┌─────────────────────────────────────────────────────────────┐
│                    plugin-submitter                          │
│  • Forks marketplace repo (if needed)                        │
│  • Creates feature branch                                    │
│  • Commits plugin files                                      │
│  • Creates PR with proper description                        │
│  • Reports PR URL                                            │
└─────────────────────────────────────────────────────────────┘
     │
     ▼
   PR Created → Awaiting Review → Merged → Available to All!
```

## Usage Examples

### Scan Your Installation

```
Use the plugin-scanner agent to see what I have installed
```

Output:
```
## Discovered Components

### Skills (Global: ~/.claude/skills/)
| Name | Description | Related To |
|------|-------------|------------|
| parallel-orchestrator | Manage parallel workstreams | parallel-worker |
| parallel-worker | Execute focused tasks | parallel-orchestrator |
| my-custom-skill | Does something cool | - |

### Agents (Global: ~/.claude/agents/)
| Name | Description |
|------|-------------|
| parallel-setup | Create worktrees for parallel work |

## Suggested Groupings
1. **parallel-workflows**: parallel-orchestrator, parallel-worker, parallel-setup
```

### Package Selected Components

```
Use the plugin-packager agent to create a plugin from parallel-orchestrator, parallel-worker, and parallel-setup
```

The packager will:
1. Confirm your selection
2. Ask for plugin name (suggests: `parallel-workflows`)
3. Ask for description and author
4. Detect any hardcoded paths or secrets
5. Create the plugin structure
6. Generate README and validate

### Submit to Marketplace

```
Use the plugin-submitter agent to submit the parallel-workflows plugin
```

The submitter will:
1. Check `gh` CLI is authenticated
2. Fork the marketplace repo
3. Create a feature branch
4. Commit your plugin
5. Create a pull request
6. Report the PR URL

## What Gets Detected

The scanner finds components in:

| Location | Type |
|----------|------|
| `~/.claude/skills/<name>/SKILL.md` | Skills |
| `~/.claude/agents/<name>.md` | Agents |
| `~/.claude/commands/<name>.md` | Commands |
| `~/.claude/settings.json` → `hooks` | Hooks |
| `.claude/skills/` (project) | Project skills |
| `.claude/agents/` (project) | Project agents |

## Automatic Issue Detection

The packager scans for common issues:

| Issue | Example | Action |
|-------|---------|--------|
| Hardcoded paths | `/home/jim/project` | Prompts for replacement |
| Potential secrets | `api_key = "..."` | Warns and asks to remove |
| Local configs | `localhost:8080` | Suggests generalization |
| Missing frontmatter | No YAML header | Offers to add |

## Prerequisites for Submission

The submitter requires:
- GitHub CLI (`gh`) installed
- Authenticated: `gh auth login`
- Git installed

## Target Marketplaces

Default target: `jimmc414/claude-code-plugin-marketplace`

To submit to a different marketplace:
```
Use plugin-submitter to submit my-plugin to owner/other-marketplace
```

## Complete Example Session

```
You: I want to share my deployment tools with the community

Claude: I'll help you publish your local components. Let me scan your installation first.
[Uses plugin-scanner]

Claude: I found:
- Skills: docker-deploy, k8s-deploy
- Agents: deployer
- Hooks: PostToolUse (deployment logging)

These appear related. Suggested plugin name: "deployment-tools"

Would you like me to package these together?

You: Yes, go ahead

Claude: [Uses plugin-packager]
I'll need some information:
- Plugin name: deployment-tools (suggested) ✓
- Description: Docker and Kubernetes deployment automation
- Author: Your Name
- Category: devops (detected from content) ✓

Creating plugin...
✓ Plugin created at plugins/deployment-tools/
✓ Validation passed

Ready to submit?

You: Yes, submit it

Claude: [Uses plugin-submitter]
✓ Forked jimmc414/claude-code-plugin-marketplace
✓ Created branch: add-deployment-tools
✓ Committed plugin files
✓ Created PR: https://github.com/jimmc414/claude-code-plugin-marketplace/pull/42

Your plugin is now awaiting review!
```

## Troubleshooting

### "No components found"
- Check `~/.claude/` exists
- Verify skills are in `~/.claude/skills/<name>/SKILL.md` format
- Verify agents are in `~/.claude/agents/<name>.md` format

### "gh CLI not found"
```bash
# macOS
brew install gh

# Linux
# See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

### "Not authenticated"
```bash
gh auth login
# Choose: GitHub.com → HTTPS → Browser
```

### "Plugin validation failed"
Review the error messages. Common fixes:
- Add missing `name` or `description` in frontmatter
- Fix JSON syntax errors in plugin.json
- Ensure all referenced scripts exist

## License

MIT
