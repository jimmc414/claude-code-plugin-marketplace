---
name: deep-research
description: Conducts iterative deep research on any topic using web search, progressive exploration, and structured synthesis. Use when asked for comprehensive research, deep investigation, thorough analysis, or multi-source exploration of any topic. Triggers: research, investigate, deep dive, comprehensive analysis, explore thoroughly, find everything about.
allowed-tools: WebSearch, WebFetch, Write, Read, Glob, Bash
---

# Deep Research Skill

## Overview

This skill conducts systematic, multi-iteration research on any topic. Inspired by OpenAI's Deep Research and open-source implementations, it uses progressive exploration to build comprehensive understanding.

**When to use:** User asks for comprehensive research, investigation, deep analysis, or thorough exploration of a topic requiring multiple sources.

## Research Methodology

### Phase 1: Scope Definition

Before starting research, clarify:

1. **Research Question**: What exactly needs to be answered?
2. **Key Aspects**: What facets of the topic should be explored?
3. **Parameters**: Set depth and breadth based on complexity
   - Simple topic: depth=2, breadth=3
   - Moderate topic: depth=3, breadth=4 (default)
   - Complex topic: depth=4-5, breadth=5-6

4. **Create Research Directory**:
   ```
   ./research/[topic-slug]/
   ├── findings.md      # Accumulated findings per iteration
   ├── sources.md       # All sources with URLs
   └── report.md        # Final synthesized report
   ```

### Phase 2: Iterative Research Loop

For each iteration (1 to depth):

#### Step 1: Generate Search Queries

Create targeted search queries based on:
- Original research question
- Current knowledge gaps (from previous iterations)
- Unexplored angles discovered in findings
- Contradictions requiring resolution

**Query Generation Guidelines:**
- Make queries specific, not generic
- Vary approach: definitional, comparative, recent news, expert sources
- Build on previous learnings - don't repeat covered ground
- Target entities, metrics, dates mentioned in findings
- Include domain-specific terminology discovered

Generate `breadth` queries per iteration.

#### Step 2: Execute Searches

For each query:
1. Use `WebSearch` to find relevant sources
2. Review search results for relevance and quality
3. For the most promising 2-3 results per query, use `WebFetch` to get full content

**Source Quality Signals:**
- Authoritative domains (.gov, .edu, major publications)
- Recent publication dates for current topics
- Expert authors or organizational sources
- Primary sources over aggregators

#### Step 3: Extract Findings

From each source, extract:
- **Key Facts**: Concrete, verifiable information
- **Data Points**: Numbers, metrics, statistics with context
- **Entities**: People, organizations, products, places mentioned
- **Dates/Timeline**: When things happened or will happen
- **Quotes**: Direct statements from experts or officials
- **Claims**: Assertions that may need verification

**Append to findings.md:**
```markdown
## Iteration [N] - [Date/Time]

### Query: "[search query]"

**Source: [Title]** ([URL])
- Finding 1
- Finding 2
- Key quote: "..."

**Source: [Title]** ([URL])
- Finding 1
...
```

**Update sources.md:**
```markdown
[N]. [Title] - [URL] (accessed [date])
```

#### Step 4: Gap Analysis

After processing all queries in an iteration, assess:

1. **Unanswered Questions**: What aspects remain unaddressed?
2. **Weak Areas**: Single-source or low-confidence information?
3. **Contradictions**: Conflicting claims needing resolution?
4. **Emerging Angles**: New questions raised by findings?
5. **Completeness Score**: 1-10, how well is the question answered?

**Decision Logic:**
- If completeness < 7 AND depth remaining → CONTINUE
- If completeness >= 8 OR depth exhausted → PROCEED TO SYNTHESIS
- If new searches aren't adding value (diminishing returns) → PROCEED TO SYNTHESIS

#### Step 5: Iterate or Proceed

If continuing:
- Use gap analysis to inform next iteration's queries
- Focus on weak areas and unanswered questions
- Reduce breadth slightly for more targeted searches

If proceeding to synthesis:
- Move to Phase 3

### Phase 3: Synthesis

#### Step 1: Organize Findings

Read all accumulated findings from findings.md and organize by:
- Logical themes/subtopics (NOT by iteration order)
- Chronological order for historical topics
- Categories relevant to the research question

#### Step 2: Reconcile Information

- Identify consensus across multiple sources
- Flag disputed or contradictory claims
- Note confidence levels based on source quality and agreement
- Distinguish facts from opinions/speculation

#### Step 3: Write Report

Create report.md with this structure:

```markdown
# Research Report: [Topic]

**Generated**: [Date]
**Research Depth**: [N] iterations
**Sources Consulted**: [Count]

---

## Executive Summary

[2-3 paragraphs summarizing key findings, main conclusions, and critical insights]

---

## Key Findings

### [Subtopic 1]

[Synthesized findings with inline citations like [1], [2]]

### [Subtopic 2]

[Synthesized findings]

[Additional sections as needed]

---

## Analysis

[Synthesis of patterns, implications, and insights that emerge from the findings]

---

## Limitations & Gaps

- [What couldn't be determined]
- [Conflicting information that wasn't resolved]
- [Areas requiring further research]

---

## Sources

1. [Title] - [URL]
2. [Title] - [URL]
...
```

## Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| depth | 3 | 1-5 | Number of research iterations |
| breadth | 4 | 2-8 | Queries per iteration |
| focus | none | string | Optional focus areas to prioritize |

## Usage Examples

### Basic Research
```
"Use deep research to investigate the current state of quantum computing"
```

### Configured Research
```
"Research autonomous vehicle regulations with depth=4 and breadth=5, focusing on US federal policy"
```

### Comparative Research
```
"Deep research comparing React, Vue, and Svelte for enterprise applications"
```

## Implementation Notes

### Context Management

To avoid context overflow on deep research:
1. Save findings to files after each iteration
2. Read from files when synthesizing
3. Summarize previous iterations rather than carrying full context
4. Use the files as the source of truth

### Progress Updates

After each iteration, provide a brief update:
```
Iteration 2/3 complete:
- Executed 4 queries
- Found 12 new findings
- Key discovery: [brief insight]
- Gaps remaining: [brief list]
- Next focus: [what iteration 3 will target]
```

### Quality Checks

Throughout research:
- Verify claims across multiple sources when possible
- Flag single-source claims with lower confidence
- Note recency of sources (important for current events)
- Prefer primary sources over secondary coverage
- Watch for circular sourcing (multiple articles citing same original)

### Source Tracking

Maintain rigorous citation:
- Every factual claim needs a source number
- Record full URL for each source
- Note access date for web sources
- Include source title for readability

## Error Handling

- If WebSearch returns no results: try alternative query formulations
- If WebFetch fails on a URL: note in findings, continue with other sources
- If a topic has very limited sources: note this as a limitation
- If sources heavily conflict: present both perspectives, don't force resolution

## Output Structure

```
./research/[topic-slug]/
├── findings.md          # Raw findings from each iteration
│                        # Append-only during research
├── sources.md           # Numbered list of all sources
│                        # Updated after each search
└── report.md            # Final synthesized report
                         # Created in Phase 3
```

All files are markdown for easy reading and future reference.
