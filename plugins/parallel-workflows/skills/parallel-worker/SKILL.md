---
name: parallel-worker
description: "Execute focused implementation tasks in a parallel workflow. Use when: working on assigned files in a worktree, making checkpoint commits, signaling dependencies or blockers, completing orchestrator-assigned tasks. Triggers: worker, checkpoint, worktree, assigned scope, commit prefix, parallel task."
---

# Parallel Workflow Worker

You are a focused implementer in a parallel workflow coordinated by an orchestrator. You work exclusively within your assigned scope and communicate status through git commits. You never communicate directly with other workers—git is your only coordination mechanism.

## Your Role

- Execute tasks assigned in your kickoff prompt
- Stay strictly within assigned file/directory boundaries
- Commit progress using standardized prefixes
- Signal blockers and dependencies through commits
- Let the orchestrator handle coordination

## Commit Prefix Conventions

**You MUST use these prefixes on every commit:**

| Prefix | When to Use | Example |
|--------|-------------|---------|
| `[CHECKPOINT]` | Completed a subtask, continuing work | `[CHECKPOINT] Add user model with validation` |
| `[BLOCKED:<reason>]` | Cannot proceed, waiting for something | `[BLOCKED:missing-api-spec] Need endpoint definitions from task-1` |
| `[NEEDS:task-X/<item>]` | Need output from another worker | `[NEEDS:task-2/UserModel] Require User model for foreign key` |
| `[COMPLETE]` | All assigned tasks finished | `[COMPLETE] Analytics API endpoints implemented` |

### Commit Message Format

```
[PREFIX] Short description

- Detail 1
- Detail 2

Files changed:
- path/to/file1.py
- path/to/file2.py
```

---

## Kickoff Protocol

When you receive a kickoff prompt from the orchestrator:

### 1. Verify Your Environment

```bash
# Confirm you're in the correct worktree
pwd
# Should be: .../worktrees/task-<id>-<description>/

# Verify correct branch
git branch
# Should show: * work/task-<id>-<description>

# Verify branch is clean
git status
```

### 2. Understand Your Assignment

From the kickoff prompt, identify:
- Your task ID (e.g., task-1, task-2)
- Your assigned scope (files/directories you may modify)
- Your specific tasks
- Expected checkpoints
- Any dependencies on other workers

### 3. Begin Work

Only after verification, start on your first task.

---

## Scope Discipline

### Golden Rule

**You may ONLY modify files within your assigned scope.**

### Before Editing Any File

Ask yourself:
1. Is this file within my assigned directories?
2. If not, do I absolutely need to modify it?

### When You Discover Out-of-Scope Needs

If you need to modify a file outside your scope:

1. **Stop** - Do not modify the file
2. **Document** - Note what you need and why
3. **Commit** - Use `[NEEDS:task-X/<item>]` prefix
4. **Continue** - Work on other tasks if possible

Example:
```bash
git add <your-files>
git commit -m "[NEEDS:task-2/UserModel] Cannot create UserAnalytics relation without User model

Need the User model from task-2 to establish foreign key relationship.
Will continue with other endpoints that don't require this relation.

Blocked on:
- UserAnalyticsHistory endpoint (needs User FK)

Continuing with:
- SystemAnalytics endpoint (no User dependency)"
```

### Boundary Files

If multiple workers might touch the same file (e.g., `__init__.py`, `config.py`):
- Check your kickoff prompt for guidance
- If unclear, commit your changes separately and note the potential conflict
- The orchestrator will handle merge conflicts

**Common shared files - avoid modifying unless you're Worker 1:**

| File | Recommendation |
|------|----------------|
| `__init__.py` | Worker 1 creates with all exports. Others do NOT modify. |
| `requirements.txt` | Document needs in commit message, don't modify directly. |
| Config files | Assigned to one worker only. |

**If you need to add an export to `__init__.py`**: Don't modify the file. Instead, document it in your `[COMPLETE]` commit message. The integration phase will handle adding exports.

---

## Commit Workflow

### Before EVERY Commit Sequence

```bash
# ALWAYS verify branch first
git branch

# Expected output:
# * work/task-<id>-<description>

# If you see "main" or wrong branch, STOP and fix:
git checkout work/task-<id>-<description>
```

### Making a Checkpoint Commit

```bash
# Verify branch
git branch

# Stage your changes
git add <specific-files>
# Or for all changes in scope:
git add path/to/your/scope/

# Commit with prefix
git commit -m "[CHECKPOINT] <description>

<details about what was completed>

Files changed:
- list files"

# Push to remote
git push origin work/task-<id>-<description>
```

### Checkpoint Granularity

Commit at these points:
- When specified in kickoff prompt
- After completing a logical unit of work
- Before starting a different subtask
- When you've been working for 30+ minutes without a commit

---

## Status Signaling

### [CHECKPOINT] - Progress

Use for normal progress:

```bash
git commit -m "[CHECKPOINT] Implement user validation logic

Added:
- Email format validation
- Password strength checker
- Username uniqueness check

Files changed:
- models/user.py
- utils/validators.py"
```

### [BLOCKED:\<reason\>] - Cannot Proceed

Use when you cannot continue ANY tasks:

```bash
git commit -m "[BLOCKED:external-api-down] Cannot test payment integration

The Stripe sandbox API is returning 503 errors.
All remaining tasks require payment API access.

Completed before blocking:
- Payment model structure
- Local validation logic

Blocked on:
- API integration tests
- Webhook handlers"
```

### [NEEDS:task-X/\<item\>] - Cross-Dependency

Use when you need another worker's output:

```bash
git commit -m "[NEEDS:task-1/api-endpoints] Cannot implement API client without endpoint specs

Need the following from task-1:
- GET /api/analytics/summary endpoint
- POST /api/analytics/events endpoint

Can continue with:
- UI components that don't require API calls
- Mock data structures"
```

### [COMPLETE] - All Done

Use only when ALL assigned tasks are finished:

```bash
git commit -m "[COMPLETE] Analytics dashboard frontend implemented

Summary of changes:
- Dashboard layout component
- Real-time chart widgets
- Data fetching hooks
- Unit tests for all components

All assigned tasks completed successfully.

Integration notes:
- Requires API endpoints from task-1 to be merged first
- CSS uses CSS modules, no global styles affected

Files changed:
- templates/analytics/dashboard.html
- static/js/analytics/*.js
- static/css/analytics/*.css
- tests/frontend/test_analytics.js"
```

### CRITICAL: [COMPLETE] Is Mandatory

**Your final commit MUST have the `[COMPLETE]` prefix.** The orchestrator detects completion by searching for this prefix in git log.

If your last working commit was `[CHECKPOINT]` and there's nothing new to add:

```bash
# Amend the checkpoint to complete (preferred)
git commit --amend -m "[COMPLETE] <same description>

Summary of all work completed:
- <list accomplishments>"
```

**Never leave your branch without a `[COMPLETE]` commit when you're done.** Even if `git status` shows "nothing to commit", your work isn't properly signaled until there's a `[COMPLETE]` commit.

---

## Completion Protocol

When you finish all tasks:

### 1. Final Verification

```bash
# Ensure all changes committed
git status
# Should show: nothing to commit, working tree clean

# Verify on correct branch
git branch

# Review your commits
git log --oneline -10
```

### 2. Create Complete Commit

Your final `[COMPLETE]` commit should include:

- Summary of all changes made
- List of all files modified
- Any issues encountered
- Recommendations for integration
- Dependencies on other workers (if any)

### 3. Push Final State

```bash
git push origin work/task-<id>-<description>
```

### 4. Do Not Proceed Further

After pushing `[COMPLETE]`:
- Do not make additional changes
- Do not attempt to merge
- The orchestrator will handle integration

---

## Safety Checks

### Quick Branch Verification

Run this before ANY git operation:

```bash
# One-liner to verify and warn
[ "$(git branch --show-current)" = "work/task-<id>-<description>" ] || echo "WARNING: Wrong branch!"
```

### Full Safety Check

```bash
# Verify worktree location
echo "Worktree: $(pwd)"

# Verify branch
echo "Branch: $(git branch --show-current)"

# Verify remote tracking
git status -sb

# Check for uncommitted changes
git status --short
```

### Recovery: Wrong Branch

If you accidentally committed to the wrong branch:

```bash
# Note the commit hash
git log --oneline -1
# e.g., abc1234

# Switch to correct branch
git checkout work/task-<id>-<description>

# Cherry-pick the commit
git cherry-pick abc1234

# Go back and remove from wrong branch
git checkout <wrong-branch>
git reset --hard HEAD^
```

**Important:** If you committed to `main`, alert the user immediately. Do not force-push.

---

## Quick Reference

```bash
# Verify branch (do this constantly)
git branch

# Stage and commit checkpoint
git add <files> && git commit -m "[CHECKPOINT] <desc>"

# Push to remote
git push origin work/task-<id>-<description>

# Check what you've done
git log --oneline -5

# See uncommitted changes
git status

# See what files you've modified
git diff --name-only

# Verify you're in worktree
pwd  # Should contain "worktrees/"
```

---

## Common Patterns

### Starting Fresh

```bash
cd worktrees/task-<id>-<description>
git branch  # Verify
# Start coding...
```

### After Long Work Session

```bash
git branch  # Verify
git add <files>
git commit -m "[CHECKPOINT] Progress on <feature>

<details>"
git push origin work/task-<id>-<description>
```

### Hitting a Dependency

```bash
git add <completed-work>
git commit -m "[NEEDS:task-X/<item>] <what you need>

<context about the dependency>

Continuing with other tasks..."
git push origin work/task-<id>-<description>
# Continue with non-blocked tasks
```

### Finishing Up

```bash
git branch  # Final verify
git add <remaining>
git commit -m "[COMPLETE] <summary>

<full details for orchestrator>"
git push origin work/task-<id>-<description>
# STOP - orchestrator will handle merge
```

---

## Related

This skill is designed to work with kickoff prompts generated by the **parallel-orchestrator** skill. The orchestrator coordinates multiple workers and handles integration of all branches.
