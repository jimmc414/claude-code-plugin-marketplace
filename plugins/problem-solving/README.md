# Problem Solving Plugin

A structured workflow for diagnosing problems and generating solutions with clear recommendations.

## Overview

This plugin enforces a disciplined problem-solving approach:

1. **Clarify** the problem thoroughly before proposing solutions
2. **Generate** multiple solution options with pros, cons, and tradeoffs
3. **Recommend** a specific solution with clear rationale

## Components

| Type | Name | Description |
|------|------|-------------|
| **Agent** | `solve-issue` | Orchestrator that guides the full workflow with re-entry support (uses Opus) |
| **Command** | `/clarify-problem` | Characterize a problem without jumping to solutions |
| **Command** | `/solve-problem` | Generate 5 solutions with decision matrix and recommendation |

## Usage

### Full Workflow (Recommended)

Use the orchestrator agent for guided experience:

```
"Use the solve-issue agent to help me figure out why the API keeps timing out"
```

The agent will:
- Guide you through problem clarification (symptoms, context, timeline)
- Offer to generate solutions with full analysis
- Track artifacts and support re-entry

### Re-entry Support

Resume from any point by passing a file:

```
"Use the solve-issue agent with problem_2024-12-19_api-timeout.md"
```

### Individual Commands

Use commands directly for more control:

```
/clarify-problem "The authentication is failing intermittently and I think it might be..."

/solve-problem problem_2024-12-19_auth-failure.md
```

## Output Files

| File Pattern | Description |
|--------------|-------------|
| `problem_DATE_label.md` | Clarified problem statement with symptoms and context |
| `solution_DATE_label.md` | Solution analysis with decision matrix and recommendation |

## Features

### Problem Clarification
- Separates symptoms from root cause
- Gathers context, timeline, and what's been tried
- Does NOT propose solutions (disciplined separation)

### Solution Generation
- 5 distinct approaches with full analysis per solution:
  - Pros/Cons
  - Risk assessment
  - Reversibility
  - Dependencies & prerequisites
  - Success criteria
  - Failure modes
  - Effort estimate
- Decision matrix for comparison
- Clear recommendation with rationale
- Hybrid solution support
- Regeneration if needed

## Installation

```bash
/plugin install problem-solving@community-claude-plugins
```

## License

MIT
