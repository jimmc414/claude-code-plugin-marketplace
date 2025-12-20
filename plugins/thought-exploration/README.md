# Thought Exploration Plugin

A workflow for refining raw thoughts through structured clarification and Socratic examination.

## Overview

This plugin provides a complete thought refinement pipeline:

1. **Clarify** raw, unstructured thoughts (ideal for speech-to-text input)
2. **Challenge** clarified thoughts through rigorous Socratic questioning
3. **Track** position evolution and produce refined insights

## Components

| Type | Name | Description |
|------|------|-------------|
| **Agent** | `explore-thinking` | Orchestrator that guides the full workflow with re-entry support (uses Opus) |
| **Command** | `/clarify-thoughts` | Organize and clarify raw brain dumps |
| **Command** | `/challenge-thoughts` | Socratic exploration of clarified thoughts |

## Usage

### Full Workflow (Recommended)

Use the orchestrator agent for guided experience:

```
"Use the explore-thinking agent to help me think through my API design ideas"
```

The agent will:
- Guide you through thought clarification
- Offer to challenge your thoughts via Socratic dialogue
- Track artifacts and support re-entry

### Re-entry Support

Resume from any point by passing a file:

```
"Use the explore-thinking agent with thoughts_2024-12-19_api-design.md"
```

### Individual Commands

Use commands directly for more control:

```
/clarify-thoughts "I've been thinking about the authentication flow and maybe we should..."

/challenge-thoughts thoughts_2024-12-19_auth-flow.md
```

## Output Files

| File Pattern | Description |
|--------------|-------------|
| `thoughts_DATE_label.md` | Clarified thoughts |
| `thoughts_DATE_label_explored.md` | Explored thoughts with position drift analysis |

## Features

- **Speech-to-text friendly**: Handles messy, unstructured input
- **Iterative clarification**: Uses AskUserQuestion for interactive refinement
- **Rigorous but fair questioning**: Challenges weak points without being contrarian
- **Position tracking**: Summarizes how thinking evolved during exploration
- **Affirmation**: Notes which points held up under scrutiny

## Installation

```bash
/plugin install thought-exploration@community-claude-plugins
```

## License

MIT
