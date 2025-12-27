---
description: Start a collaborative specification building session with iterative Q&A before implementation
argument-hint: <task description>
allowed-tools: AskUserQuestion, EnterPlanMode, Read, Glob, Grep, Write
---
# Collaborative Specification Builder

You are entering a collaborative specification building session with the user. This is an iterative process to define an unambiguous specification before implementation.

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
- What inputs are accepted? Types, formats, valid ranges?

**Output Contract**
- What is returned? Shape/type of output?

**Preconditions**
- What must be true before execution?
- What is validated vs. assumed?

**Postconditions**
- What is guaranteed after successful execution?

**Invariants**
- What must remain true throughout execution?

**Constraints**
- What rules govern valid behavior? What is prohibited?

**State Transitions**
- What states can entities be in? What transitions are legal?

**Side Effects**
- What external state is modified? What I/O occurs?

**Error Cases**
- What can fail? How should each failure be handled?

**Boundary Conditions**
- Empty inputs, nulls, zeros, max values?

**Assumptions**
- What is assumed true but not explicitly checked?

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

Begin by understanding what the user wants to build through iterative questioning:

1. Use the AskUserQuestion tool to ask clarifying questions
2. You may ask up to 4 questions per round (this is the tool's limit)
3. Focus each round on specific specification areas that are unclear or undefined
4. IMPORTANT: Always include this option in every question round:
   - Label: "Done - specification is complete"
   - Description: "The specification is sufficiently clear, proceed to planning"
5. After receiving answers, analyze the responses and update your understanding
6. If the user did NOT select "Done", continue asking follow-up questions
7. Repeat until the user selects "Done - specification is complete"

Guidelines for questions:
- Work through specification areas systematically
- Prioritize Intent and core contracts early
- Ask about error cases and boundaries—these are often overlooked
- Build on previous answers with deeper follow-ups
- Flag ambiguities or contradictions you notice
- Skip areas that are clearly not relevant to the task

## Phase 2: Specification Document

Once the user indicates the specification is complete:

1. Write the full specification to a `SPECIFICATION.md` file in the project root (or a location the user specifies)
2. Organize the document by the specification areas above
3. Include only sections that are relevant to the task
4. Highlight any areas that remain ambiguous or assumed with a ⚠️ marker
5. Ask the user to review the document and approve or request changes

## Phase 3: Planning and Implementation

After specification approval:

1. Use EnterPlanMode to transition into plan mode
2. Explore the codebase to understand existing patterns and architecture
3. Create a detailed implementation plan that satisfies the specification
4. For each implementation step, reference which specification elements it addresses
5. Present the plan for user approval before implementation

## Starting the Session

The user wants to build: $ARGUMENTS

Begin Phase 1 now. Start by asking clarifying questions focused on Intent and the core contracts for this task.
