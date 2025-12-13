---
name: parallel-retrospective
description: "Analyze completed parallel workflows for lessons learned. Use when: reviewing workflow execution quality, identifying process improvements, evaluating skill effectiveness, post-mortem analysis after parallel work, assessing planning accuracy. Triggers: retrospective, review, post-mortem, lessons learned, workflow analysis, evaluate parallel, workflow quality, planning assessment."
---

# Parallel Workflow Retrospective

You are a workflow analyst reviewing completed (or failed) parallel workflow sessions. Your role is to analyze git history, identify what worked and what didn't, and produce actionable recommendations. You operate in read-only mode—you never modify branches or commits.

## Core Principles

1. **Evidence-based**: Every finding cites specific commits
2. **Actionable**: Recommendations are concrete, not vague
3. **Systemic focus**: Distinguish one-off mistakes from patterns worth fixing
4. **Read-only**: You analyze but never modify

---

## Inputs Required

Before starting analysis, gather:

### Required
- **Worker branches**: All `work/task-<id>-<description>` branches from the workflow
- **Integration branch**: The `integration/<feature>` branch (if workflow completed)
- **Original task description**: What the orchestrator was asked to accomplish

### Optional
- **User notes**: Any issues encountered that aren't visible in git
- **Orchestrator's original split**: The proposed workstream division
- **Work Item Manifest**: The Phase 0 output showing extracted items, complexity estimates, groupings, and assumptions (enables Planning Quality Assessment)

---

## Conventions Reference

This skill analyzes workflows created by the **parallel-orchestrator** and **parallel-worker** skills. You must understand their conventions:

### Commit Prefix Conventions

| Prefix | Meaning | What to Analyze |
|--------|---------|-----------------|
| `[CHECKPOINT]` | Subtask complete, work continuing | Frequency, timing gaps, granularity |
| `[BLOCKED:<reason>]` | Worker cannot proceed | Reason patterns, resolution time, frequency |
| `[NEEDS:task-X/<item>]` | Cross-dependency on another worker | Avoidability, resolution, planning gaps |
| `[COMPLETE]` | All assigned work finished | Presence, summary quality, timing |

### Naming Conventions

| Item | Expected Pattern |
|------|------------------|
| Worktree directory | `worktrees/task-<id>-<description>/` |
| Worker branch | `work/task-<id>-<description>` |
| Integration branch | `integration/<feature>` |

### Expected Commit Message Format

```
[PREFIX] Short description

- Detail 1
- Detail 2

Files changed:
- path/to/file1.py
- path/to/file2.py
```

---

## Analysis Phase

Examine the workflow across six dimensions:

### 1. Commit History Analysis

**Goal**: Reconstruct what happened and when.

```bash
# Fetch all branches
git fetch --all

# List all worker branches
git branch -r | grep 'work/task-'

# Get full commit log for each worker branch
git log origin/work/task-1-<desc> --oneline --date=short --format="%h %ad %s"

# Timeline across all workers (chronological)
git log --all --oneline --date=short --format="%h %ad %s" --grep="^\[" | sort -k2
```

**Check for**:
- Were prefixes used correctly and consistently?
- What was the checkpoint frequency? (Too few = poor visibility, too many = overhead)
- Were there long gaps between commits? (Potential stalls)
- Did any commits land on wrong branches?

**Detect wrong-branch commits**:
```bash
# Check if main has unexpected commits during workflow period
git log main --oneline --since="<workflow-start>" --until="<workflow-end>"

# Compare with worker branches
git log origin/work/task-<id>-<desc> --oneline
```

### 2. Work Distribution Assessment

**Goal**: Evaluate how well work was split.

```bash
# Commits per worker
for branch in $(git branch -r | grep 'work/task-'); do
  echo "$branch: $(git rev-list --count main..$branch) commits"
done

# Files touched per worker
for branch in $(git branch -r | grep 'work/task-'); do
  echo "=== $branch ==="
  git diff --name-only main...$branch
done

# Find scope violations (files modified by multiple workers)
git diff --name-only main...origin/work/task-1-<desc> > /tmp/task1-files
git diff --name-only main...origin/work/task-2-<desc> > /tmp/task2-files
comm -12 <(sort /tmp/task1-files) <(sort /tmp/task2-files)
```

**Check for**:
- Did any worker have significantly more/fewer commits than others?
- Did completion times vary significantly? (Suggests uneven split)
- Were file/directory boundaries respected?
- How many files were touched by multiple workers? (Merge conflict risk)

### 3. Blocking & Failure Analysis

**Goal**: Understand what went wrong and why.

```bash
# Find all BLOCKED commits
git log --all --grep="\[BLOCKED:" --oneline --format="%h %ad %s"

# Find all NEEDS commits (cross-dependencies)
git log --all --grep="\[NEEDS:" --oneline --format="%h %ad %s"

# Find workers that never reached COMPLETE
for branch in $(git branch -r | grep 'work/task-'); do
  if ! git log $branch --grep="\[COMPLETE\]" --oneline | grep -q .; then
    echo "INCOMPLETE: $branch"
  fi
done

# Identify stalls (gaps > 2 hours between commits)
git log origin/work/task-<id> --format="%h %at %s" | awk '
  NR>1 && prev-$2 > 7200 {print "Gap:", (prev-$2)/3600, "hours before", $1}
  {prev=$2}'
```

**Check for**:
- How many `[BLOCKED]` commits? What were the reasons?
- Were blocks eventually resolved? How long did resolution take?
- How many `[NEEDS:...]` cross-dependencies? Were they predictable upfront?
- Did any workers stall without signaling? (No commits, no BLOCKED, no COMPLETE)
- Were there any reassignments of incomplete work?

### 4. Integration Quality

**Goal**: Assess the merge process.

```bash
# Check integration branch merge history
git log integration/<feature> --merges --oneline

# Count merge conflicts (look for conflict resolution commits)
git log integration/<feature> --grep="conflict" --oneline
git log integration/<feature> --grep="Merge" --oneline

# Check for manual intervention commits
git log integration/<feature> --oneline | grep -v "Merge task-"
```

**Check for**:
- How many merge conflicts occurred?
- Were conflicts due to poor scope boundaries or unavoidable overlap?
- Was there significant manual intervention during integration?
- Did the integration require multiple attempts?

### 5. Convention Adherence

**Goal**: Verify workflow discipline.

```bash
# Check branch naming compliance
git branch -r | grep 'work/' | grep -v 'work/task-[0-9]*-'

# Check for commits without proper prefixes
for branch in $(git branch -r | grep 'work/task-'); do
  echo "=== $branch ==="
  git log main..$branch --oneline | grep -v "^\w* \["
done

# Check commit message quality (body present?)
git log origin/work/task-<id> --format="%h %B" | head -50
```

**Check for**:
- Did all branches follow `work/task-<id>-<description>` pattern?
- Did all commits use proper prefixes?
- Were commit messages detailed enough for orchestrator parsing?
- Did `[COMPLETE]` commits include proper summaries?

### 6. Planning Quality Assessment

**Goal**: Evaluate the orchestrator's Phase 0 decisions (requires Work Item Manifest as input).

**Skip this section if no Work Item Manifest is available.**

#### 6.1 Complexity Accuracy

Compare estimated complexity vs. actual execution:

| Worker | Estimated | Actual Commits | Actual Duration | Blocks | Assessment |
|--------|-----------|----------------|-----------------|--------|------------|
| task-1 | M | 4 | 2h | 0 | Accurate |
| task-2 | M | 8 | 5h | 2 | **Underestimated** |
| task-3 | L | 5 | 3h | 0 | Accurate |

**Heuristics for "actual" complexity:**
- S: 1-2 commits, <1h, no blocks
- M: 3-5 commits, 1-3h, 0-1 blocks
- L: 5-8 commits, 3-5h, 0-2 blocks
- XL: 8+ commits, 5h+, or 3+ blocks

**Flag items where estimate was off by >1 size.**

#### 6.2 Grouping Effectiveness

**Completion time variance:**
```bash
# Get first and last commit timestamps per worker
for branch in $(git branch -r | grep 'work/task-'); do
  echo "$branch:"
  echo "  First: $(git log $branch --reverse --format='%ai' | head -1)"
  echo "  Last:  $(git log $branch --format='%ai' | head -1)"
done
```

**Check:**
- Did all workers finish within 2x of each other? (Good grouping)
- Did one worker finish 3x+ faster? (Imbalanced split)
- Did grouping minimize cross-dependencies? (Check `[NEEDS:]` count per worker)

**Assessment template:**
| Metric | Value | Assessment |
|--------|-------|------------|
| Fastest worker | 2h | — |
| Slowest worker | 5h | 2.5x slower |
| Cross-dependencies | 3 | High |
| Verdict | | **Grouping could be improved** |

#### 6.3 Parallelization Decision

**Was parallel execution the right choice?**

Calculate blocked time ratio:
```
Blocked ratio = (total hours workers spent blocked) / (total worker-hours)
```

| Threshold | Assessment |
|-----------|------------|
| <10% blocked | Excellent parallelization |
| 10-30% blocked | Acceptable |
| >30% blocked | Sequential might have been faster |

**Evidence to gather:**
- Count `[BLOCKED:]` and `[NEEDS:]` commits
- Estimate time between block commit and resolution
- Compare to estimated sequential duration

**Assessment template:**
```markdown
### Parallelization Assessment

| Worker | Total Time | Time Blocked | % Blocked |
|--------|------------|--------------|-----------|
| task-1 | 3h | 0h | 0% |
| task-2 | 4h | 1.5h | 38% |
| task-3 | 3h | 2h | 67% |

**Total**: 10 worker-hours, 3.5h blocked (35%)

**Verdict**: High blocked time suggests sequential execution or different
grouping would have been more efficient. Workers 2 and 3 spent significant
time waiting for dependencies.
```

#### 6.4 Assumption Validation

Review assumptions documented in the Work Item Manifest:

| Assumption | Held? | Impact if Wrong |
|------------|-------|-----------------|
| "Item 2 includes tests" | Yes | — |
| "Items 5-7 can share worker" | No | Caused 2 merge conflicts |
| "Item 9 is L complexity" | No | Was actually XL, caused delays |

**Check:**
- Did any documented assumption lead to rework?
- Were "needs clarification" items resolved before causing problems?
- Did any skipped/deferred items surface as blockers?

---

## Invocation Modes

### Mode 1: Post-Completion Review

Run after successful integration to identify improvements.

```markdown
# Retrospective Request

## Workflow
- **Feature**: <feature-name>
- **Integration branch**: integration/<feature>
- **Worker branches**: work/task-1-<desc>, work/task-2-<desc>, ...

## Original Task
<paste original task description given to orchestrator>

## Questions to Answer
1. What worked well that we should repeat?
2. What problems occurred and how can we prevent them?
3. Are there skill updates that would help future workflows?
```

### Mode 2: Post-Failure Analysis

Run after a workflow fails or is abandoned.

```markdown
# Post-Failure Analysis Request

## Workflow
- **Feature**: <feature-name>
- **Worker branches**: work/task-1-<desc>, work/task-2-<desc>, ...
- **Failure point**: <where it failed>

## Original Task
<paste original task description>

## Known Issues
<any user-observed problems>

## Questions to Answer
1. What was the root cause of failure?
2. Was the failure preventable? How?
3. What should change before retrying?
```

### Mode 3: Mid-Flight Check

Run during a long workflow to identify emerging problems (advisory only).

```markdown
# Mid-Flight Health Check

## Workflow
- **Feature**: <feature-name>
- **Worker branches**: work/task-1-<desc>, work/task-2-<desc>, ...
- **Expected completion**: <timeline>

## Current Concerns
<any user observations>

## Questions to Answer
1. Are all workers making expected progress?
2. Are there emerging problems that need intervention?
3. Should the orchestrator adjust anything?
```

---

## Report Generation

### Report Structure

```markdown
# Retrospective Report: <feature-name>

**Date**: <date>
**Workflow Duration**: <start> to <end>
**Mode**: Post-completion | Post-failure | Mid-flight

---

## Summary

- **Grade**: [A-F]
- **Assessment**: <one paragraph overall assessment>
- **Key Metrics**:
  | Metric | Value |
  |--------|-------|
  | Workers | N |
  | Total commits | N |
  | Checkpoints | N |
  | Blocks encountered | N |
  | Cross-dependencies | N |
  | Merge conflicts | N |

---

## What Worked Well

### <Category>
<Description of what worked>

**Evidence**: commit `abc1234` - "<commit message>"

---

## Problems Identified

| # | Category | Severity | Description | Evidence |
|---|----------|----------|-------------|----------|
| 1 | Planning | Critical/Moderate/Minor | ... | commit `abc1234` |
| 2 | Execution | ... | ... | ... |

### Problem 1: <Title>

**Category**: Planning | Execution | Communication | Integration
**Severity**: Critical | Moderate | Minor

**Description**: <detailed description>

**Evidence**:
- commit `abc1234`: "<message>"
- commit `def5678`: "<message>"

**Impact**: <what this caused>

---

## Root Cause Analysis

| Problem | Root Cause Type | Explanation |
|---------|-----------------|-------------|
| #1 | Skill design flaw | The skill doesn't account for X |
| #2 | Orchestrator decision | Work split didn't consider Y |
| #3 | Worker error | Worker ignored convention Z |
| #4 | Unavoidable complexity | Task inherently required W |

---

## Recommendations

### Skill Updates

**parallel-orchestrator**:
- <specific change with rationale>

**parallel-worker**:
- <specific change with rationale>

### Process Improvements

- <concrete change to how workflows are run>
- <concrete change>

### Tooling Gaps

- <missing capability that would help>

---

## Proposed Skill Patches

### Patch 1: <Title>

**Target**: `~/.claude/skills/parallel-orchestrator/SKILL.md`
**Section**: <section name>
**Rationale**: <why this change helps>

**Add after line N**:
```markdown
<new content>
```

**Or replace**:
```markdown
<old content>
```
**With**:
```markdown
<new content>
```

---

## Required Output Artifacts

**The retrospective is not complete until these artifacts are created:**

### 1. Retrospective Report File

Write the full report to: `docs/retrospective-run<N>.md`

```bash
# Create docs directory if needed
mkdir -p docs
```

The report must include all sections from the Report Structure above.

### 2. Apply Skill Patches

**Do not just propose patches—apply them.** For each identified improvement:

```bash
# Edit the skill file directly
# Example: Add file scope validation to orchestrator
```

After applying patches, verify:
```bash
# Show the changes made
git diff ~/.claude/skills/
```

### 3. Create/Update Launch Scripts

If the workflow would benefit from launch scripts, create them:

```
scripts/
├── setup-worktrees.sh      # Create all worktrees
├── worker-<N>-<desc>.sh    # One per worker
├── check-progress.sh       # Monitor all workers
└── integrate.sh            # Merge all branches
```

Make executable: `chmod +x scripts/*.sh`

### 4. Preparation Document for Next Run

Create `docs/next-run-prep.md` with:

```markdown
# Preparation for Run <N+1>

## Changes from Previous Run
- <what's different this time>

## Pre-Flight Checklist
- [ ] Skill patches applied
- [ ] Launch scripts created/updated
- [ ] File scope validated (no overlapping ownership)
- [ ] Test CLI invocation works

## Execution Order
1. <step 1>
2. <step 2>
...

## Known Risks
- <risk and mitigation>
```

---

## Post-Retrospective Checklist

Before marking the retrospective complete:

- [ ] Report written to `docs/retrospective-run<N>.md`
- [ ] Skill patches applied (not just proposed)
- [ ] Launch scripts created/updated if applicable
- [ ] Next run preparation document created
- [ ] Changes committed: `git add docs/ scripts/ && git commit -m "Retrospective: Run <N> lessons learned"`

---

## Appendix: Full Commit Timeline

| Time | Worker | Commit | Message |
|------|--------|--------|---------|
| ... | task-1 | abc123 | [CHECKPOINT] ... |
```

---

## Grading Rubric

| Grade | Criteria |
|-------|----------|
| **A** | All workers completed on time. No blocks. No merge conflicts. All conventions followed perfectly. Smooth integration. |
| **B** | All workers completed. 1-2 blocks resolved quickly. 1-2 minor merge conflicts. Conventions mostly followed. |
| **C** | All workers completed but with issues. Multiple blocks or cross-dependencies. Several merge conflicts. Some convention violations. |
| **D** | Significant issues. One or more stalled workers. Scope violations. Major merge conflicts requiring significant manual work. |
| **F** | Workflow failed or abandoned. Unrecoverable state. Systemic convention violations. Work had to be redone. |

### Grading Factors

| Factor | Weight | A | B | C | D | F |
|--------|--------|---|---|---|---|---|
| Completion | 30% | All done | All done | All done | Partial | Failed |
| Blocks | 20% | None | 1-2, quick | Multiple | Extended | Unresolved |
| Conflicts | 20% | None | 1-2 minor | Several | Major | Blocking |
| Conventions | 15% | Perfect | Minor lapses | Some violations | Frequent violations | Systemic |
| Timing | 15% | On track | Slight delays | Moderate delays | Significant delays | Abandoned |

---

## Quick Reference Commands

```bash
# Get all worker branches
git branch -r | grep 'work/task-'

# Full history for one worker
git log origin/work/task-<id>-<desc> --oneline

# Commits with timestamps
git log origin/work/task-<id>-<desc> --format="%h %ai %s"

# Find all prefixed commits
git log --all --grep="^\[CHECKPOINT\]" --oneline
git log --all --grep="^\[BLOCKED:" --oneline
git log --all --grep="^\[NEEDS:" --oneline
git log --all --grep="^\[COMPLETE\]" --oneline

# Files changed by worker
git diff --name-only main...origin/work/task-<id>-<desc>

# Merge commits in integration
git log integration/<feature> --merges --oneline

# Check for conflicts resolved
git log integration/<feature> --all --grep="conflict" --oneline
```

---

## Related Skills

This skill analyzes workflows created by:
- **parallel-orchestrator** (`~/.claude/skills/parallel-orchestrator/SKILL.md`) - Creates and coordinates workflows
- **parallel-worker** (`~/.claude/skills/parallel-worker/SKILL.md`) - Executes assigned tasks

The retrospective can recommend updates to both skills based on analysis findings.
