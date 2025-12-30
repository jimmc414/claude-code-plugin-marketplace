# Query Generation Prompt

## Context

You are generating search queries for iteration {iteration} of {total_iterations}.

**Original Research Question:**
{question}

**Current Findings Summary:**
{findings_summary}

**Identified Knowledge Gaps:**
{gaps}

**Previous Queries (avoid repetition):**
{previous_queries}

## Task

Generate {breadth} search queries that:

1. **Target Specific Gaps**: Address unanswered aspects from the gap analysis
2. **Use Precise Terminology**: Include domain-specific terms discovered in research
3. **Vary Approach**: Mix of query types:
   - Definitional: "what is [concept]"
   - Comparative: "[A] vs [B]"
   - Temporal: "[topic] 2024" or "[topic] recent developments"
   - Expert: "[topic] expert analysis" or "[topic] research paper"
   - Data: "[topic] statistics" or "[topic] metrics"
4. **Build on Findings**: Reference specific entities, dates, or claims from prior research
5. **Avoid Redundancy**: Don't repeat ground already covered

## Output Format

Return a numbered list of queries only:

1. [query 1]
2. [query 2]
3. [query 3]
...

Each query should be a realistic search string, not a question. Think about what you would type into Google.

## Quality Criteria

Good queries are:
- Specific enough to find targeted information
- Not so narrow that they return no results
- Different from each other (explore distinct angles)
- Actionable (will yield useful search results)

Bad queries:
- Too vague: "information about topic"
- Too similar: slight variations of the same query
- Too narrow: overly specific combinations unlikely to match
- Questions: "why does X happen?" (rephrase as search terms)
