# Collaborative Planning Plugin

Collaborative planning commands that ensure thorough understanding of requirements before implementation through structured, iterative Q&A sessions.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install collaborative-planning@jimmc414
```

## Commands

### `/collaborative-plan <task>`

A simple collaborative planning workflow:

1. **Requirements Gathering**: Iterative Q&A to understand what you want
2. **Planning**: Enters plan mode with gathered requirements

Best for: Quick planning sessions where you want some back-and-forth before diving in.

**Example:**
```
/collaborative-plan add user authentication to the app
```

### `/disambiguate-plan <task>`

A thorough disambiguation-focused planning workflow:

1. **Initial Analysis**: Identifies all potential ambiguities
2. **Iterative Disambiguation**: Resolves every "it depends" before proceeding
3. **Confirmation Summary**: Presents understanding for approval
4. **Automatic Plan Mode Entry**: Transitions seamlessly to planning

Best for: Complex features where getting requirements wrong would be costly.

**Example:**
```
/disambiguate-plan implement a real-time notification system
```

## When to Use Each

| Command | Best For |
|---------|----------|
| `/collaborative-plan` | Simpler tasks, when you want flexibility in the Q&A |
| `/disambiguate-plan` | Complex features, when ambiguity could lead to wasted effort |

## How It Works

Both commands use the `AskUserQuestion` tool to gather requirements iteratively:

1. Claude asks up to 4 questions per round
2. You answer or select "Done - ready to plan"
3. Claude either asks follow-up questions or proceeds to planning
4. Once ready, Claude enters plan mode and creates an implementation plan

The key difference:
- **collaborative-plan**: You decide when you're ready to plan
- **disambiguate-plan**: Claude ensures all ambiguities are resolved before proceeding

## Philosophy

> "A wrong plan fast is worse than a right plan slower."

These commands embody the principle that investing time upfront in understanding requirements prevents costly rework later. They force both you and Claude to think through edge cases, constraints, and implicit assumptions before writing any code.

## License

MIT
