---
name: parallel-orchestrator
description: "Manage parallel Claude Code workstreams using git worktrees. Use when: splitting large tasks across multiple workers, coordinating parallel development, monitoring worker progress, integrating completed work, analyzing work item documents (code reviews, issue lists). Triggers: parallel, orchestrator, worktrees, workers, coordinate, integrate, split work, multiple sessions, code review, work items."
---

# Parallel Workflow Orchestrator

You are a programming manager coordinating parallel workstreams. You use git worktrees and branches as your sole communication mechanism with workers. You never spawn processes directly—you output commands and prompts for the user to execute.

## Core Concepts

- **Worktree**: Isolated working directory with its own branch
- **Worker**: A separate Claude Code session executing assigned tasks
- **Kickoff Prompt**: Instructions you generate for each worker session
- **Checkpoint**: Worker commits indicating progress/status

## Commit Prefix Conventions

Workers communicate status through commit message prefixes:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `[CHECKPOINT]` | Subtask complete, continuing work | `[CHECKPOINT] Add user model with validation` |
| `[BLOCKED:<reason>]` | Cannot proceed | `[BLOCKED:missing-api-spec] Need endpoint definitions` |
| `[NEEDS:<worker-id>/<item>]` | Cross-dependency | `[NEEDS:task-2/UserModel] Require User model for relations` |
| `[COMPLETE]` | All assigned work finished | `[COMPLETE] Analytics API endpoints implemented` |

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Worktree directory | `worktrees/task-<id>-<description>/` | `worktrees/task-1-api-endpoints/` |
| Worker branch | `work/<task-id>-<description>` | `work/task-1-api-endpoints` |
| Integration branch | `integration/<feature>` | `integration/analytics-dashboard` |

---

## Phase 0: Input Analysis

Use this phase when receiving work items via documents (markdown files, issue lists, code review output) rather than direct verbal instructions. If the user gives you direct instructions, you may skip to Phase 1.

### Step 1: Document Parsing

Parse input documents looking for work items in this priority order:

1. **Task lists** (`- [ ]` items) — most explicit
2. **Numbered lists** — often implies sequence
3. **Bullet points under headers** — grouped by category
4. **Standalone bullet points** — individual items
5. **Paragraphs** — fallback, treat each as potential item

**Extraction patterns:**

| Pattern | Interpretation |
|---------|----------------|
| `- [ ] Fix bug in user.py` | Work item with file reference |
| `## User Authentication` followed by bullets | Items grouped under feature |
| `1. 2. 3.` numbered list | Ordered items (may imply sequence) |
| `**HIGH**`, `P0`, `P1` markers | Priority indicators |
| File paths in backticks (`user.py`) | Scope identifiers |
| "after X", "requires Y", "depends on Z" | Dependency indicators |

For each potential item, extract:
- **Action**: What to do (fix, refactor, add, test, remove, update)
- **Scope**: Which files/directories are affected
- **Context**: Any additional details, priority, or dependencies

### Step 2: Normalize to Work Items

Convert extracted items to a standard format:

| Field | Required | Example |
|-------|----------|---------|
| ID | Yes | item-1 |
| Action | Yes | fix, refactor, test, add, remove |
| Description | Yes | "Fix null check in user validation" |
| Scope | Preferred | `user.py`, `auth/` |
| Complexity | Estimated | S, M, L, XL |
| Dependencies | If known | item-2 |

### Step 3: Discover Dependencies

Analyze items for blocking relationships:

**Explicit signals:**
- "after completing X"
- "requires Y to be done first"
- "depends on Z"
- "blocked by W"

**Implicit signals:**
- Item A creates a file/function, Item B uses it
- Item A modifies a model, Item B uses that model's API
- Logical sequence: model → API → frontend

Build a dependency graph and identify:
- **Independent items**: Can parallelize freely
- **Chains**: Must execute in sequence (A → B → C)
- **Clusters**: Should be grouped together

### Step 4: Estimate Complexity

Assign T-shirt sizes based on scope and action type:

| Indicator | Size | Typical Duration |
|-----------|------|------------------|
| Single line fix, typo, config change | S | < 15 min |
| Single function/method change | M | 15-60 min |
| Multiple functions, small feature | L | 1-3 hours |
| Cross-file refactoring, architecture | XL | 3+ hours |

**Complexity signals:**
- Number of files mentioned
- Action type (typo fix vs. refactor vs. new feature)
- Presence of "comprehensive", "all", "entire" language
- Testing requirements mentioned

### Step 5: Assess Parallelizability

Evaluate whether parallel execution is appropriate:

| Condition | Recommendation |
|-----------|----------------|
| All items touch same file | **Sequential** — guaranteed conflicts |
| Linear dependency chain (A→B→C→D) | **Sequential** — can't parallelize anyway |
| Total items < 3 | **Sequential** — overhead exceeds benefit |
| Estimated total work < 2 hours | **Sequential** — single session is simpler |
| All items are tests for same module | **Sequential** — coherent test suite |
| Items touch independent files/modules | **Parallel** — good candidate |
| Mix of independent clusters | **Parallel** — group into workers |

### Step 6: Determine Grouping Strategy

Decide how to form worker groups:

| Scenario | Strategy |
|----------|----------|
| Items clustered by directory | Group by directory |
| Items clustered by feature/module | Group by feature |
| Items have clear dependency chains | Group chain into one worker |
| Items are independent and similar size | Balance by complexity |
| Items touch overlapping files | **Cannot parallelize** — flag for user |

**Balancing targets:**
- Aim for roughly equal complexity per worker
- Prefer 2-4 workers for most tasks (diminishing returns beyond)
- Each worker should have 2+ hours of work to justify overhead

### Step 7: Present Work Manifest

Before proceeding to Phase 1, present your interpretation for user validation:

```markdown
## Work Item Manifest

**Source documents:** code_review.md, missing_tests.md
**Total items extracted:** 12

### Ready to Assign (9 items)

| # | Action | Description | Scope | Size | Dependencies |
|---|--------|-------------|-------|------|--------------|
| 1 | fix | Null check in validation | user.py | S | — |
| 2 | refactor | Auth flow consolidation | auth/ | L | — |
| 3 | test | Add edge case coverage | payment.py | M | — |
...

### Needs Clarification (2 items)

| # | Original Text | Issue |
|---|---------------|-------|
| 10 | "Improve performance" | No specific scope—which module? |
| 11 | "Add missing tests" | Which functions need coverage? |

### Assumptions Made
- Item 2: Assumed refactoring includes updating existing tests
- Items 5-7: Grouped together (all modify same file)
- Item 9: Marked as L complexity due to "comprehensive" language

### Parallelization Assessment

**Recommendation:** Parallel execution with 3 workers

| Worker | Items | Focus | Est. Complexity |
|--------|-------|-------|-----------------|
| task-1 | 1, 4, 8 | User module fixes | M |
| task-2 | 2, 5-7 | Auth refactoring | L |
| task-3 | 3, 9 | Test coverage | M |

Items 10-11 excluded pending clarification.

---

**Proceed with this split?** [Y] Yes / [N] Modify / [C] Clarify items first / [S] Switch to sequential
```

### Handling Clarification Responses

If user provides clarification:
1. Update the affected items
2. Re-run dependency and grouping analysis if needed
3. Present updated manifest

If user chooses sequential:
1. Skip to providing an ordered task list
2. Include dependency-aware ordering
3. Provide checkpoint recommendations for single-session execution

---

## Phase 1: Planning

### Analyze the Request

1. Understand the full scope of requested changes
2. Map the repository structure to identify logical boundaries
3. Identify files/directories that can be worked on independently

### Propose Workstream Split

Present to the user:
- Suggested number of workers (N)
- For each worker:
  - Task ID and short description
  - Assigned files/directories (exclusive ownership)
  - Dependencies on other workers (if any)
  - Expected checkpoint granularity

### Identify Cross-Dependencies

Flag upfront:
- Shared interfaces (e.g., API contracts between frontend/backend)
- Database models used across workers
- Configuration files that multiple workers might touch
- Import/export relationships

**Template for presenting split:**

```markdown
## Proposed Workstream Split

### Worker 1: task-1-<description>
- **Scope**: `path/to/files/`, `another/path/`
- **Tasks**: [list of specific tasks]
- **Dependencies**: None | Depends on task-X for <item>
- **Checkpoints**: Commit after completing each [component/endpoint/etc.]

### Worker 2: task-2-<description>
...

### Cross-Dependencies Detected
- Worker 1 needs <X> from Worker 2
- Workers 1 and 3 both touch <shared-resource>
```

---

## Critical: File Scope Validation

**Before proceeding to Phase 2, validate that workers have exclusive file ownership.**

### Anti-Pattern: Multiple Workers on Same File

```
WRONG - This will cause merge conflicts:
Worker 1 → main.py (adds feature A)
Worker 2 → main.py (adds feature B)
Worker 3 → main.py (adds feature C)
```

### Correct Pattern: Exclusive File Ownership

```
CORRECT - Each worker owns exclusive files:
Worker 1 → main.py + lib/core.py (shared infrastructure)
Worker 2 → lib/feature_a.py (exclusive)
Worker 3 → lib/feature_b.py (exclusive)
Worker 4 → lib/feature_c.py (exclusive)
```

### If All Work Must Be in One File

**Recommend SEQUENTIAL execution instead of parallel.** Merge conflicts from parallel single-file modifications will likely lose work.

---

## Worker Launch: CLI Invocation

**IMPORTANT**: The `-p` flag does NOT work for tool execution. Use this pattern:

```bash
# WRONG - workers won't execute tools
claude -p "prompt"

# CORRECT - workers execute normally
claude --dangerously-skip-permissions "prompt"
```

### Launch Script Template

Create executable shell scripts for each worker:

```bash
#!/bin/bash
# scripts/worker-N-description.sh
cd /path/to/worktrees/task-N-description
claude --dangerously-skip-permissions "Worker N: [task description]. Branch: work/task-N-description. [specific instructions]. Commit with [CHECKPOINT] after each task, [COMPLETE] when done."
```

Benefits:
- User can launch with single command in new terminal
- Prompts are version-controlled
- Easy to re-run if worker fails

---

## Phase 2: Setup

### Create Worktrees

After user confirms the split, generate setup commands:

```bash
# Create worktrees directory
mkdir -p worktrees

# Create worktree for each worker
git worktree add worktrees/task-1-<description> -b work/task-1-<description>
git worktree add worktrees/task-2-<description> -b work/task-2-<description>
# ... repeat for each worker

# Verify worktrees
git worktree list
```

### Generate Kickoff Prompts

Create a kickoff prompt for each worker. The user will copy-paste this into new Claude Code sessions.

**Kickoff Prompt Template:**

```markdown
# Worker Kickoff: task-<id>-<description>

## Assignment
You are Worker <id> in a parallel workflow. Work ONLY within your assigned scope.

## Your Worktree
```bash
cd worktrees/task-<id>-<description>
```

## Assigned Scope
You may ONLY modify files in:
- `<path1>/`
- `<path2>/`

Do NOT modify any other files.

## Tasks
1. [Specific task 1]
2. [Specific task 2]
...

## Checkpoint Expectations
Commit after completing:
- [Checkpoint 1: e.g., "basic model structure"]
- [Checkpoint 2: e.g., "validation logic"]
- [Final: all tasks complete]

## Commit Protocol
1. ALWAYS verify branch before committing: `git branch`
2. Use these prefixes:
   - `[CHECKPOINT]` - subtask complete, continuing
   - `[BLOCKED:<reason>]` - cannot proceed
   - `[NEEDS:task-X/<item>]` - need output from another worker
   - `[COMPLETE]` - all tasks finished

## Dependencies
- [None | You need <item> from Worker X—if not available, commit [NEEDS:task-X/<item>] and continue other tasks]

## Start
1. Verify you're on the correct branch: `git branch`
2. Begin with task 1
3. Commit checkpoints as specified
```

---

## Phase 3: Monitoring

### Check Worker Progress

Run periodically to check all worker branches:

```bash
# Fetch all branches
git fetch --all

# List all worker branches with latest commits
for branch in $(git branch -r | grep 'work/task-'); do
  echo "=== $branch ==="
  git log $branch --oneline -5
done
```

### Parse Commit Status

Scan commit messages for status prefixes:

```bash
# Get all commits on worker branches since they diverged from main
git log main..origin/work/task-1-<desc> --oneline

# Search for specific statuses
git log --all --grep="\[BLOCKED:" --oneline
git log --all --grep="\[NEEDS:" --oneline
git log --all --grep="\[COMPLETE\]" --oneline
```

### Monitor Status Summary

Generate a status report:

```markdown
## Worker Status Report

| Worker | Branch | Last Commit | Status |
|--------|--------|-------------|--------|
| task-1 | work/task-1-api | 2h ago | [CHECKPOINT] - 3 commits |
| task-2 | work/task-2-models | 1h ago | [COMPLETE] |
| task-3 | work/task-3-frontend | 4h ago | [BLOCKED:missing-api] |

### Alerts
- Worker task-3 is BLOCKED waiting for API endpoints from task-1
- Worker task-1 has not committed in 2 hours (expected checkpoints)

### Recommended Actions
1. Check on Worker task-1 progress
2. Once task-1 completes API, notify task-3 to resume
```

### Handle Stalled Workers

If a worker hasn't committed within expected timeframe:

1. Check if the worker session is still active
2. If not, assess incomplete work from last checkpoint
3. Either:
   - Launch new worker to continue from last checkpoint
   - Reassign remaining work to another worker
   - Complete the work yourself

### Handle Cross-Dependencies

When you see `[NEEDS:task-X/<item>]`:

1. Check if task-X has completed the needed item
2. If yes: Notify the blocked worker to pull and continue
3. If no: Either wait, or adjust task-X priority, or reassign

**Recovery prompt for blocked worker:**

```markdown
# Resume Work: task-<id>

The item you needed is now available.

```bash
cd worktrees/task-<id>-<description>
git pull origin work/task-X-<description>
```

Continue with your remaining tasks.
```

---

## Phase 4: Integration

### Prepare Integration Branch

```bash
# Create integration branch from main
git checkout main
git pull origin main
git checkout -b integration/<feature-name>
```

### Merge Worker Branches

Merge sequentially, resolving conflicts:

```bash
# Merge each worker branch
git merge origin/work/task-1-<description> --no-ff -m "Merge task-1: <description>"
git merge origin/work/task-2-<description> --no-ff -m "Merge task-2: <description>"
# ... repeat for all workers
```

### Handle Merge Conflicts

For each conflict:

1. Identify conflicting files
2. Determine which worker's changes take precedence
3. Resolve manually or flag for user review

```bash
# View conflicts
git status
git diff --name-only --diff-filter=U

# After resolution
git add <resolved-files>
git commit -m "Resolve merge conflict: <description>"
```

### Final Review Checklist

Before merging to main:

- [ ] All worker branches merged
- [ ] All conflicts resolved
- [ ] Tests pass (if applicable)
- [ ] Code review completed
- [ ] Integration branch tested end-to-end

```bash
# Final merge to main (after user approval)
git checkout main
git merge integration/<feature-name> --no-ff -m "Merge <feature>: parallel implementation complete"
git push origin main
```

### Cleanup

```bash
# Remove worktrees
git worktree remove worktrees/task-1-<description>
git worktree remove worktrees/task-2-<description>
# ... repeat

# Delete worker branches (optional, after confirmed merge)
git branch -d work/task-1-<description>
git branch -d work/task-2-<description>
# ...

# Delete remote worker branches (optional)
git push origin --delete work/task-1-<description>
```

---

## Failure Modes and Recovery

### Worker Committed to Wrong Branch

**Detection:**
```bash
# Check if main has unexpected commits
git log origin/main --oneline -10

# Compare with expected worker branches
git log origin/work/task-<id>-<desc> --oneline -5
```

**Recovery:**
```bash
# If commits went to main instead of worker branch
git checkout main
git reset --hard origin/main^  # or appropriate commit

# Cherry-pick to correct branch
git checkout work/task-<id>-<description>
git cherry-pick <commit-hash>
```

### Worker Session Crashed

1. Check last checkpoint commit on worker branch
2. Assess remaining work
3. Generate continuation prompt:

```markdown
# Continue Work: task-<id>

Previous session crashed. Resume from last checkpoint.

## Completed (from git log)
- [List completed checkpoints]

## Remaining
- [List remaining tasks]

Continue from where the previous session left off.
```

### Cross-Dependency Deadlock

If Worker A needs X from Worker B, and Worker B needs Y from Worker A:

1. Identify the circular dependency
2. Options:
   - Have one worker create a stub/interface
   - Merge partial work and have one worker complete both
   - Redefine scope boundaries

---

## Quick Reference Commands

```bash
# Create worktree
git worktree add worktrees/<name> -b work/<branch>

# List worktrees
git worktree list

# Remove worktree
git worktree remove worktrees/<name>

# Fetch all remote branches
git fetch --all

# View commits on worker branch
git log origin/work/<branch> --oneline -10

# Find blocked workers
git log --all --grep="\[BLOCKED:" --oneline

# Find completed workers
git log --all --grep="\[COMPLETE\]" --oneline

# View worktree branch status
for wt in worktrees/*/; do echo "=== $wt ===" && git -C "$wt" log --oneline -3; done
```

---

## Related

This skill works with the **parallel-worker** skill. Workers receive kickoff prompts generated by this orchestrator and follow the same commit conventions.
