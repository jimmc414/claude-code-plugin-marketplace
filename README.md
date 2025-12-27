# Claude Code Plugin Marketplace

A community-maintained marketplace for Claude Code plugins, skills, agents, and hooks.

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add jimmc414/claude-code-plugin-marketplace

# Install a plugin
/plugin install <plugin-name>@jimmc414
```

---

## Available Plugins (11)

| Plugin | Category | Description |
|--------|----------|-------------|
| [norvig-patterns](#norvig-patterns) | development | 54 elegant coding patterns from Peter Norvig's pytudes |
| [thought-exploration](#thought-exploration) | productivity | Clarify thoughts via Socratic dialogue |
| [problem-solving](#problem-solving) | productivity | Problem diagnosis and solution generation workflow |
| [collaborative-planning](#collaborative-planning) | productivity | Iterative Q&A planning before implementation |
| [collaborative-spec-builder](#collaborative-spec-builder) | development | Build specifications through structured questioning |
| [plugin-publisher](#plugin-publisher) | utilities | Extract and publish local skills to marketplaces |
| [parallel-workflows](#parallel-workflows) | development | Git worktree orchestration for concurrent sessions |
| [local-llm](#local-llm) | development | Manage local Ollama LLM models |
| [adversarial-testing](#adversarial-testing) | testing | Find real bugs with adversarial test generation |
| [doc-linter](#doc-linter) | testing | Validate docs by simulating a zero-knowledge developer |
| [error-therapist](#error-therapist) | development | Rewrite cryptic error messages to be helpful |

---

## Plugin Details

### norvig-patterns
**Category:** development | **Version:** 1.0.0

54 elegant coding patterns derived from Peter Norvig's pytudes repository. Automatically guides Claude to write cleaner, more Pythonic code.

| Category | Skills | Examples |
|----------|--------|----------|
| Problem-Solving | 8 | `solve-grid-maze`, `find-shortest-path`, `solve-constraint-puzzle` |
| Data Structures | 6 | `use-sparse-set`, `use-counter-frequency`, `build-priority-queue` |
| Algorithm Optimization | 5 | `cache-recursive-calls`, `use-generator-lazy`, `propagate-then-search` |
| Code Structure | 5 | `refactor-decompose-function`, `write-docstring-first`, `compose-small-helpers` |
| Functional Programming | 5 | `pass-function-as-arg`, `apply-decorator-wrap`, `capture-state-closure` |
| Metaprogramming | 5 | `build-expression-tree`, `dispatch-on-structure`, `overload-operators-dsl` |
| Parsing | 4 | `parse-extract-input`, `tokenize-then-parse`, `validate-before-process` |
| Testing | 5 | `verify-with-inline-tests`, `benchmark-before-optimize`, `test-with-examples` |
| Error Handling | 4 | `handle-edge-cases`, `return-none-for-failure`, `catch-expected-errors` |
| Visualization | 4 | `display-grid-state`, `format-statistics-table`, `time-and-report` |
| State Machines | 3 | `use-class-for-state`, `stack-based-backtrack`, `frontier-based-explore` |

```bash
/plugin install norvig-patterns@jimmc414
```

---

### thought-exploration
**Category:** productivity | **Version:** 1.0.0

Structured thinking workflows for clarifying thoughts and challenging assumptions through Socratic dialogue.

| Type | Name | Description |
|------|------|-------------|
| **Command** | `/clarify-thoughts` | Transform vague ideas into clear, structured thoughts |
| **Command** | `/challenge-thoughts` | Socratic examination to stress-test your thinking |
| **Agent** | `explore-thinking` | Orchestrates the full thought exploration workflow |

```bash
/plugin install thought-exploration@jimmc414
```

---

### problem-solving
**Category:** productivity | **Version:** 1.0.0

Problem diagnosis and solution generation workflow. Separates problem clarification from solution generation for better outcomes.

| Type | Name | Description |
|------|------|-------------|
| **Command** | `/clarify-problem` | Iteratively clarify and define the problem |
| **Command** | `/solve-problem` | Generate solutions for a well-defined problem |
| **Agent** | `solve-issue` | Guides through problem clarification and solution generation |

```bash
/plugin install problem-solving@jimmc414
```

---

### collaborative-planning
**Category:** productivity | **Version:** 1.0.0

Collaborative planning commands with iterative requirements gathering through structured Q&A sessions.

| Type | Name | Description |
|------|------|-------------|
| **Command** | `/collaborative-plan` | Simple iterative Q&A planning - you decide when ready |
| **Command** | `/disambiguate-plan` | Thorough disambiguation - resolves all ambiguity before proceeding |

```bash
/plugin install collaborative-planning@jimmc414
```

---

### collaborative-spec-builder
**Category:** development | **Version:** 1.0.0

Collaborative specification building with iterative Q&A before implementation. Define unambiguous specifications through structured questioning.

| Type | Name | Description |
|------|------|-------------|
| **Command** | `/collaborative-spec-builder` | Build spec for new implementations via iterative Q&A |
| **Command** | `/collaborative-spec-builder-existing` | Build aspirational spec for existing code, identify gaps |

```bash
/plugin install collaborative-spec-builder@jimmc414
```

---

### plugin-publisher
**Category:** utilities | **Version:** 1.0.0

Extract local skills, agents, and hooks and publish them to plugin marketplaces with guided assistance.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `plugin-publishing` | Knowledge layer for Claude Code paths, plugin formats |
| **Agent** | `plugin-scanner` | Scans local installation to inventory components |
| **Agent** | `plugin-packager` | Creates plugin structure from selected components |
| **Agent** | `plugin-submitter` | Handles GitHub fork/branch/PR workflow |

```bash
/plugin install plugin-publisher@jimmc414
```

---

### parallel-workflows
**Category:** development | **Version:** 1.0.0

Parallel workflow orchestration using git worktrees for concurrent Claude Code sessions.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `parallel-orchestrator` | Manage parallel workstreams, coordinate workers |
| **Skill** | `parallel-worker` | Execute focused tasks in a worktree |
| **Skill** | `parallel-retrospective` | Analyze completed workflows, identify lessons |
| **Agent** | `parallel-setup` | Create worktrees and launch scripts |
| **Agent** | `parallel-monitor` | Check worker status, detect stalls |
| **Agent** | `parallel-integrate` | Merge branches, resolve conflicts |

```bash
/plugin install parallel-workflows@jimmc414
```

---

### local-llm
**Category:** development | **Version:** 1.0.0

Manage local Ollama LLM models for development and testing.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `local-llm` | Comprehensive Ollama management - models, VRAM, API |
| **Agent** | `llm-setup` | Auto-detect hardware, install Ollama, recommend models |

**Includes:** 5 ready-to-use Modelfile templates (fast, reasoning, code-generation, json-output, analysis)

```bash
/plugin install local-llm@jimmc414
```

---

### adversarial-testing
**Category:** testing | **Version:** 1.0.0

Adversarial test generation that finds real bugs by inverting the reward structure.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `adversarial-analysis` | Calculate realism bounds, extract contracts |
| **Skill** | `adversarial-patterns` | Library of attack vectors + anti-patterns |
| **Agent** | `adversarial-orchestrator` | Coordinates workflow, max 3 iterations |
| **Agent** | `adversarial-generator` | Creates candidate tests with hypotheses |
| **Agent** | `adversarial-validator` | 4-phase quality gate: static → dynamic → oracle → mutation |

```bash
/plugin install adversarial-testing@jimmc414
```

---

### doc-linter
**Category:** testing | **Version:** 1.0.0

Validate documentation by simulating a developer with zero project knowledge.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `documentation-testing` | Heuristics for identifying broken documentation |
| **Agent** | `new-hire` | Blindfolded validator that can only read docs, not source |

```bash
/plugin install doc-linter@jimmc414
```

---

### error-therapist
**Category:** development | **Version:** 1.0.0

Audit and rewrite error messages to be helpful and actionable.

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `error-ux` | Principles for writing helpful error messages |
| **Agent** | `therapist` | Scans code for error patterns, suggests rewrites |

```bash
/plugin install error-therapist@jimmc414
```

---

## Contributing

### The Easy Way: Use plugin-publisher

```bash
/plugin install plugin-publisher@jimmc414
# Then tell Claude: "I want to share my skills with the community"
```

### The Manual Way

```bash
git clone https://github.com/jimmc414/claude-code-plugin-marketplace.git
cd claude-code-plugin-marketplace
python tools/scaffold.py plugin my-plugin --description "My plugin"
python tools/validate.py my-plugin
# Submit a PR
```

See [Creating Plugins](./docs/creating-plugins.md) for the full guide.

## Tools

| Tool | Description |
|------|-------------|
| `scaffold.py` | Create new plugins and components |
| `validate.py` | Validate plugin structure and syntax |
| `export.py` | Export plugins or individual components |
| `import.py` | Import plugins from zip files or URLs |
| `generate_catalog.py` | Generate the plugin catalog |

## Documentation

- [Getting Started](./docs/getting-started.md) - Install and use plugins
- [Creating Plugins](./docs/creating-plugins.md) - Build your own plugins
- [Submitting Plugins](./docs/submitting-plugins.md) - Contribute to the marketplace
- [API Reference](./docs/api-reference.md) - Complete schema documentation

## License

MIT - See [LICENSE](./LICENSE)
