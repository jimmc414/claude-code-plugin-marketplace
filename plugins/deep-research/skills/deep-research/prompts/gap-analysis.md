# Gap Analysis Prompt

## Context

You have completed iteration {iteration} of {total_iterations} researching:

**Original Research Question:**
{question}

**Current Accumulated Findings:**
{findings}

## Task

Analyze the current state of research and identify gaps.

## Analysis Framework

### 1. Unanswered Questions

What aspects of the original research question remain unaddressed?

- List specific questions that haven't been answered
- Note which parts of the user's query lack coverage
- Identify implicit questions raised by the topic

### 2. Weak Areas

Where is the evidence thin or unreliable?

- Single-source claims (only found in one place)
- Outdated information (may no longer be accurate)
- Vague or unsubstantiated claims
- Missing quantitative data where expected
- Lack of primary sources

### 3. Contradictions

Are there conflicting claims that need resolution?

- Note specific contradictions found
- Identify which sources conflict
- Flag claims that seem suspicious or need verification

### 4. Emerging Angles

What new questions or directions have emerged from the findings?

- Unexpected connections discovered
- Related topics that seem important
- Deeper aspects worth exploring
- Follow-up questions raised by key findings

### 5. Completeness Assessment

Rate overall research completeness: **[1-10]**

- 1-3: Major gaps, core questions unanswered
- 4-6: Moderate coverage, significant gaps remain
- 7-8: Good coverage, minor gaps
- 9-10: Comprehensive, ready for synthesis

## Output Format

```
## Gap Analysis - Iteration {iteration}

### Unanswered Questions
1. [question]
2. [question]

### Weak Areas
1. [area] - [why it's weak]
2. [area] - [why it's weak]

### Contradictions
1. [claim A] vs [claim B] - needs resolution
2. ...

### Emerging Angles
1. [new direction to explore]
2. ...

### Completeness Score: [N]/10

### Recommendation: [CONTINUE / PROCEED TO SYNTHESIS]

### If Continuing, Priority Focus:
1. [highest priority gap]
2. [second priority]
3. [third priority]
```

## Decision Criteria

**CONTINUE** if:
- Completeness < 7 AND iterations remain
- Critical questions are unanswered
- New searches would likely add significant value

**PROCEED TO SYNTHESIS** if:
- Completeness >= 8
- Iterations exhausted (depth reached)
- Diminishing returns (last iteration added little new)
- Topic is sufficiently covered for the user's needs
