# parallel-workflows

Parallel workflow orchestration using git worktrees for concurrent Claude Code sessions. Split large tasks across multiple workers, coordinate parallel development, and integrate completed work.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install parallel-workflows@community-claude-plugins
```

## Components

### Skills (Auto-triggered)

| Skill | Description | Triggers |
|-------|-------------|----------|
| `parallel-orchestrator` | Manage parallel workstreams, analyze work items, coordinate workers | "parallel", "orchestrator", "split work", "worktrees" |
| `parallel-worker` | Execute focused tasks in a worktree, make checkpoint commits | "worker", "checkpoint", "assigned scope" |
| `parallel-retrospective` | Analyze completed workflows, identify lessons learned | "retrospective", "review", "post-mortem" |

### Agents (Invoke by name)

| Agent | Description | Use Case |
|-------|-------------|----------|
| `parallel-setup` | Create worktrees and launch scripts | "Use the parallel-setup agent to split this into 3 workers" |
| `parallel-monitor` | Check worker status, detect stalls | "Use the parallel-monitor agent to check progress" |
| `parallel-integrate` | Merge branches, resolve conflicts | "Use the parallel-integrate agent to combine the work" |

## How It Works

### Core Concepts

- **Worktree**: Isolated git working directory with its own branch
- **Worker**: A separate Claude Code session executing assigned tasks
- **Checkpoint**: Worker commits indicating progress/status

### Commit Conventions

Workers communicate via commit prefixes:

| Prefix | Meaning |
|--------|---------|
| `[CHECKPOINT]` | Subtask complete, continuing |
| `[BLOCKED:<reason>]` | Cannot proceed |
| `[NEEDS:<worker>/<item>]` | Cross-dependency |
| `[COMPLETE]` | All work finished |

## Usage Examples

### Split a Large Task

```
I need to implement a REST API with 5 endpoints. Use the parallel-setup
agent to split this across workers, ensuring each owns exclusive files.
```

### Monitor Progress

```
Use the parallel-monitor agent to check how the workers are doing
```

### Integrate Results

```
All workers show [COMPLETE]. Use the parallel-integrate agent to
merge everything back to main.
```

### Full Workflow

1. **Setup**: Orchestrator analyzes task, setup agent creates worktrees
2. **Execute**: User launches workers in separate terminals
3. **Monitor**: Monitor agent tracks checkpoint commits
4. **Integrate**: Integrate agent merges branches when complete
5. **Retrospective**: Review what worked and what didn't

## Requirements

- Git (for worktrees)
- Multiple terminal windows (for parallel workers)

## File Scope (Important)

Workers must own **exclusive files** to avoid merge conflicts:

```
CORRECT:
  Worker 1 → api/users.py
  Worker 2 → api/products.py
  Worker 3 → api/orders.py

WRONG (will conflict):
  Worker 1 → main.py
  Worker 2 → main.py
```

If all work must be in one file, use sequential execution instead.

## License

MIT
