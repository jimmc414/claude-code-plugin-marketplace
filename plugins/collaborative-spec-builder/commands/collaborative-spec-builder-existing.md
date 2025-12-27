---
description: Build an aspirational specification for existing code and identify gaps to address
argument-hint: <feature or component to specify>
allowed-tools: AskUserQuestion, EnterPlanMode, Read, Glob, Grep, Write, TodoWrite
---
# Collaborative Specification Builder (Existing Project)

You are entering a collaborative specification building session for an **existing** project or feature. This process will:

1. Define an **aspirational specification** - what the code SHOULD do
2. Analyze the current implementation against that spec
3. Identify gaps and create actionable tasks to close them

## Important Distinction

Throughout this process, distinguish between:
- **Current behavior**: What the code actually does today
- **Aspirational behavior**: What it should do according to the spec

When discussing behavior, be explicit: "Currently it does X, but the spec requires Y."

## Specification Areas to Cover

Systematically gather information across these areas:

**Intent**
- What problem does this solve? Why does it need to exist?
- What is the broader context? What goals guide decisions?
- What is explicitly out of scope? How will this be used?

**Domain Types / Vocabulary**
- What are the core types involved?
- What do key terms mean precisely?

**Input Contract**
- What inputs should be accepted? Types, formats, valid ranges?

**Output Contract**
- What should be returned? Shape/type of output?

**Preconditions**
- What must be true before execution?
- What should be validated vs. assumed?

**Postconditions**
- What should be guaranteed after successful execution?

**Invariants**
- What must remain true throughout execution?

**Constraints**
- What rules should govern valid behavior? What should be prohibited?

**State Transitions**
- What states can entities be in? What transitions should be legal?

**Side Effects**
- What external state should be modified? What I/O should occur?

**Error Cases**
- What can fail? How should each failure be handled?

**Boundary Conditions**
- Empty inputs, nulls, zeros, max values - what should happen?

**Assumptions**
- What should be assumed true but not explicitly checked?

**Dependencies / Environment** (if relevant)
- Required libraries, services, runtime, configuration?

**Non-functional Requirements** (if relevant)
- Performance, memory, scalability expectations?

**Security** (if relevant)
- Auth requirements, data sensitivity, threat model?

**Concurrency** (if relevant)
- Parallel execution, synchronization, race conditions?

**Examples / Acceptance Criteria**
- Concrete input/output pairs? Critical test cases?

## Phase 1: Specification Gathering (Iterative Q&A)

Begin by understanding what the user wants the code to do through iterative questioning:

1. Use the AskUserQuestion tool to ask clarifying questions
2. You may ask up to 4 questions per round (this is the tool's limit)
3. Focus each round on specific specification areas that are unclear or undefined
4. Frame questions as aspirational: "What SHOULD happen when..." not "What happens when..."
5. IMPORTANT: Always include this option in every question round:
   - Label: "Done - specification is complete"
   - Description: "The specification is sufficiently clear, proceed to gap analysis"
6. After receiving answers, analyze the responses and update your understanding
7. If the user did NOT select "Done", continue asking follow-up questions
8. Repeat until the user selects "Done - specification is complete"

Guidelines for questions:
- Work through specification areas systematically
- Prioritize Intent and core contracts early
- Ask about error cases and boundaries—these are often overlooked
- Build on previous answers with deeper follow-ups
- Flag ambiguities or contradictions you notice
- Skip areas that are clearly not relevant

## Phase 2: Specification Document

Once the user indicates the specification is complete:

1. Write the full **aspirational specification** to a `SPECIFICATION.md` file in the project root (or a location the user specifies)
2. Organize the document by the specification areas above
3. Include only sections that are relevant
4. Clearly label it as the **target state** (aspirational, not current behavior)
5. Highlight any areas that remain ambiguous or assumed with a ⚠️ marker
6. Ask the user to review the document and approve or request changes

## Phase 3: Gap Analysis

After specification approval:

1. Use Read, Glob, and Grep to examine the current implementation
2. Compare current behavior against each specification element
3. Document findings in three categories:
   - **Conforming**: Current code meets the spec
   - **Gaps**: Current code doesn't meet the spec (missing or wrong behavior)
   - **Unknown**: Cannot determine without testing or deeper analysis
4. Append the gap analysis to `SPECIFICATION.md` under a `## Gap Analysis` section
5. Ask the user to review the gap analysis before proceeding

## Phase 4: Task Creation

After gap analysis:

1. Use TodoWrite to create actionable tasks for each gap identified
2. Prioritize tasks by:
   - Severity (security issues, data integrity, crashes first)
   - Dependencies (foundational fixes before dependent ones)
   - Effort (quick wins vs. major refactors)
3. Group related tasks where appropriate
4. Each task should reference the specific spec requirement it addresses

## Phase 5: Planning (Optional)

If the user wants to proceed with implementation:

1. Use EnterPlanMode to transition into plan mode
2. Create a detailed implementation plan addressing the prioritized tasks
3. For each implementation step, reference which spec gap it closes
4. Present the plan for user approval before implementation

## Starting the Session

The user wants to specify: $ARGUMENTS

Begin Phase 1 now. Start by asking clarifying questions focused on Intent and the core contracts. Remember to frame questions as aspirational—what SHOULD the code do?
