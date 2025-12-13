# doc-linter

Validate documentation by simulating a developer with zero project knowledge.

## The Problem

Documentation rot is universal. Developers write setup instructions when they create a project, then modify the code without updating the docs. The curse of knowledge makes this invisible—the original author's environment already works, so they never re-run the setup.

The result: new team members waste hours debugging missing steps, undocumented environment variables, and outdated commands. The only way to catch this is to simulate a fresh user who knows nothing except what the README says.

## The Solution

An agent that:
- Is **forbidden from reading source code** (cannot cheat by inspecting implementation)
- Can **only read documentation files** (README, CONTRIBUTING, docs/)
- Has **shell access** to execute commands
- **Reports failures as documentation bugs**, not code bugs

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install doc-linter@community-claude-plugins
```

## Components

| Type | Name | Description |
|------|------|-------------|
| **Agent** | `new-hire` | Simulates a developer with zero project knowledge |
| **Skill** | `documentation-testing` | Heuristics for identifying documentation gaps |

## Usage

### Full Documentation Audit

```bash
claude --agent new-hire "Onboard yourself to this repository from scratch"
```

### Test Specific Section

```bash
claude --agent new-hire "Follow only the 'Local Development' section of the README"
```

### Post-Change Verification

```bash
claude --agent new-hire "Verify the setup instructions still work after recent changes to docker-compose.yml"
```

## How It Works

### Agent Constraints

The `new-hire` agent operates under strict constraints:

| Allowed | Disallowed |
|---------|------------|
| `Bash` - Execute shell commands | `Grep` - No searching source code |
| `Read` - Read documentation files | `Glob` - No finding files by pattern |
| | `Write` - Cannot fix anything |

### Allowed Files

The agent can only read:
- `README.md`, `README.*`
- `CONTRIBUTING.md`
- `docs/**`
- `.env.example`
- `package.json`, `requirements.txt`, `Makefile`, `docker-compose.yml`
- `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`

### The Process

1. **Read** the README completely
2. **Identify** all documented setup steps
3. **Execute** each step exactly as written
4. **Report** failures as documentation bugs

## Output Format

The agent produces a Documentation Health Report:

```markdown
# Documentation Health Report

## Summary
| Metric | Count |
|--------|-------|
| Total steps | 8 |
| Passed | 5 |
| Ambiguous | 1 |
| Failed | 2 |
| Missing sections | 1 |

## Steps That Failed (Documentation Bugs)

### Bug 1: Missing Node Version
- **Step:** "Run npm install"
- **Command:** `npm install`
- **Result:** `ERESOLVE peer dependency conflict`
- **Fix:** Add "Requires Node.js 18+" to prerequisites

### Bug 2: Undocumented Database Setup
- **Step:** "Start the development server"
- **Command:** `npm run dev`
- **Result:** `Error: relation "users" does not exist`
- **Fix:** Add step "Run `npm run migrate` before starting"
```

## What Counts as a Documentation Bug

| Scenario | Bug Type |
|----------|----------|
| Step says "install dependencies" with no command | Missing: specific command |
| Step assumes Docker is installed | Missing: prerequisite |
| Environment variable used but not documented | Missing: .env instructions |
| Command in README doesn't match actual file | Outdated: needs update |
| Step order causes failures | Incorrect: wrong sequence |
| Works on Linux but not macOS | Incomplete: platform notes |

## CI Integration

### Pre-flight for Accurate Testing

For the most accurate results, run in a clean environment:

```bash
# Clear caches and build artifacts
rm -rf node_modules .venv __pycache__ .cache dist build

# Unset project-specific environment variables
unset $(env | grep -E "^(API_|DB_|AWS_|SECRET_)" | cut -d= -f1)
```

### Recommended CI Triggers

Run documentation validation:
- **Nightly** on the main branch
- **On PRs** that modify documentation files
- **On PRs** that modify setup-related files (Dockerfile, package.json, requirements.txt) without modifying documentation

### GitHub Actions Example

```yaml
name: Documentation Validation

on:
  schedule:
    - cron: '0 0 * * *'  # Nightly
  pull_request:
    paths:
      - 'README.md'
      - 'docs/**'
      - 'package.json'
      - 'requirements.txt'
      - 'Dockerfile'
      - 'docker-compose.yml'

jobs:
  validate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run documentation validation
        run: |
          claude --agent new-hire "Onboard yourself to this repository"
```

## Skill: documentation-testing

The `documentation-testing` skill provides heuristics for identifying:

### Missing Prerequisites
- Node.js, Python, Docker versions
- Database systems (PostgreSQL, Redis, MongoDB)
- Cloud CLIs (aws, gcloud, az)
- Build tools (make, cmake)

### Missing Environment Configuration
- Pattern detection for `process.env.XXX`, `os.getenv()`, etc.
- `.env.example` file presence
- Config file templates

### Incomplete Setup Steps
- Database creation and migrations
- Service dependencies (starting Redis before app)
- SSL/TLS setup for local HTTPS
- Git hooks configuration

### Platform-Specific Gaps
- Shell command differences (`sed -i` variants)
- Package manager differences (apt vs brew)
- Path separator issues

## Example Session

```
User: Validate the documentation for this project

Claude: Let me read the README first.
[Reads README.md]

The README documents these setup steps:
1. Clone the repository
2. Install dependencies
3. Set up environment variables
4. Start the development server

Executing step 2: "Install dependencies"
$ npm install

npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! peer dep missing: react@^17.0.0

## FAIL: Install dependencies

**STEP:** Install dependencies
**COMMAND:** `npm install`
**RESULT:** Peer dependency conflict error
**DOCUMENTATION BUG:**
- Missing: Node.js version requirement (need 18+)
- Missing: Instructions to handle peer conflicts (--legacy-peer-deps)

Continuing to step 3...
```

## Philosophy

The agent embodies these principles:

1. **No Improvisation** - If instructions are unclear, fail the step
2. **No Domain Knowledge** - Don't assume knowledge of npm vs pip
3. **Document, Don't Fix** - Report bugs, don't patch around them
4. **Test the Docs, Not the Code** - The README is the contract

## License

MIT
