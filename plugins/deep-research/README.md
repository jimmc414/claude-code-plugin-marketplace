# deep-research

Iterative deep research with progressive exploration and structured synthesis. Inspired by OpenAI's Deep Research and open-source implementations (dzhng/deep-research, huggingface/smolagents).

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install deep-research@jimmc414
```

## What It Does

When you ask for comprehensive research on a topic, this skill:

1. **Scopes the research** - Clarifies the question, sets depth/breadth parameters
2. **Iterates through research loops** - Generates targeted queries, executes searches, extracts findings
3. **Tracks everything** - Saves findings and sources to files as it goes
4. **Synthesizes a report** - Combines all findings into a structured, cited report

## Usage

```
"Use deep research to investigate [topic]"
"Research [topic] with depth=4 and breadth=5"
"Deep dive into [topic], focusing on [specific aspects]"
```

## Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| depth | 3 | 1-5 | Number of research iterations |
| breadth | 4 | 2-8 | Queries per iteration |
| focus | none | string | Optional focus areas to prioritize |

## Output Structure

Creates a research directory with:

```
./research/[topic-slug]/
├── findings.md    # Raw findings from each iteration
├── sources.md     # All sources with URLs
└── report.md      # Final synthesized report
```

## Components

| Type | Name | Description |
|------|------|-------------|
| **Skill** | `deep-research` | Core research methodology with iterative loops |

### Supporting Prompts

- `prompts/query-generation.md` - How to create targeted search queries
- `prompts/gap-analysis.md` - Assess completeness, decide continue/stop
- `prompts/synthesis.md` - Final report synthesis guidelines

## Key Features

- **Progressive exploration**: Each iteration builds on previous findings
- **Gap analysis**: Identifies what's still unknown after each round
- **Source tracking**: Every claim links to a source URL
- **Context management**: Saves to files to avoid context overflow
- **Structured output**: Reports follow consistent format with citations

## Triggers

The skill activates when you ask for:
- Comprehensive research
- Deep investigation
- Thorough analysis
- Multi-source exploration

## License

MIT
