---
description: Thorough collaborative planning with iterative disambiguation - resolves all ambiguity before planning
argument-hint: <task description>
allowed-tools: AskUserQuestion, EnterPlanMode, Read, Glob, Grep
---

# Collaborative Planning Session with Iterative Disambiguation

You are entering a collaborative planning mode where your primary goal is to deeply understand the user's requirements before proposing any implementation plan. **Ambiguity is the enemy of good planning.**

## Core Principle

**Never proceed with planning until YOU are confident that all ambiguities have been resolved.** Your job is to be thorough, not fast. The user trusts you to ask the right questions—do not proceed prematurely.

---

## Phase 1: Initial Analysis

Immediately upon receiving the task, perform a silent analysis:

1. Read and analyze the user's request carefully
2. Identify ALL areas of potential ambiguity, including:

| Category | Examples |
|----------|----------|
| **Requirements** | Unclear acceptance criteria, undefined behavior, missing constraints |
| **Technical** | Performance targets, security requirements, compatibility needs |
| **Scope** | What's in vs out of scope, MVP vs full feature, integration boundaries |
| **Context** | Assumed knowledge, existing patterns to follow, dependencies |
| **Interpretation** | Multiple valid readings of the request, implicit assumptions |
| **Edge Cases** | Error handling, failure modes, boundary conditions |
| **Preferences** | UI/UX choices, naming conventions, architectural patterns |

---

## Phase 2: Iterative Disambiguation Loop

**CRITICAL: You MUST use the AskUserQuestion tool repeatedly until ALL ambiguities are resolved.**

### Loop Instructions

For each disambiguation round:

1. **Group related ambiguities** together (up to 4 questions per AskUserQuestion invocation)
2. **Prioritize** the most impactful ambiguities—those that would most significantly change the plan
3. **Invoke AskUserQuestion** with clear, specific questions
4. **Analyze responses** for:
   - Direct answers that resolve ambiguities
   - NEW ambiguities that arose from the answers
   - Remaining ambiguities that still need resolution
5. **Continue the loop** if ANY ambiguities remain

### Self-Check Before Each Round

Ask yourself:
- "Do I have any 'it depends' thoughts lingering?"
- "Could I explain this plan to another developer with full confidence?"
- "Are there decisions I'm making by assumption rather than confirmation?"

**If the answer to any of these is concerning, invoke AskUserQuestion again.**

### Question Quality Guidelines

DO:
- Be specific: "Which authentication method: OAuth, JWT, or session-based?" not "How should auth work?"
- Provide options when relevant to help users think through choices
- Explain WHY you're asking when relevance isn't obvious
- Ask follow-up questions on the same topic if the first answer was incomplete

DON'T:
- Ask about things you can reasonably infer or decide yourself
- Ask multiple unrelated questions when you should focus on one area first
- Accept vague answers without probing deeper

### Red Flags That ALWAYS Require Clarification

If you encounter any of these phrases or patterns, you MUST ask for specifics:

| Red Flag | What to Ask |
|----------|-------------|
| "It should be fast" | What's the specific performance target? (e.g., <100ms response time) |
| "Handle errors appropriately" | What's the error handling strategy? User-facing messages? Retry logic? |
| "Support multiple X" | Which specific X? How many initially? |
| "Similar to Y" | Which aspects of Y? What differences are acceptable? |
| "Standard approach" | Whose standard? Which pattern specifically? |
| "Later we might want Z" | Is Z in scope for this plan or explicitly deferred? |
| "Make it secure" | Which security concerns? Authentication, authorization, encryption, input validation? |
| "Good user experience" | What specific UX requirements? Error states? Loading states? Accessibility? |

---

## Phase 3: Confirmation and Plan Mode Entry

**When YOU are satisfied that all ambiguities are resolved, present a final summary using AskUserQuestion.**

Use AskUserQuestion one final time to present:
1. **Core Objective**: One sentence describing what we're building
2. **Key Requirements**: Bulleted list of must-haves
3. **Constraints**: Technical or business limitations
4. **Explicit Decisions**: Choices made during disambiguation
5. **Out of Scope**: What we explicitly decided NOT to include

Provide options like:
- "Confirmed - proceed to plan mode"
- "Need to clarify something" (returns to Phase 2)

---

## Phase 4: Automatic Plan Mode Entry

**Once you believe disambiguation is complete and the user confirms, immediately use the EnterPlanMode tool.**

Do not wait for additional prompting. When your success criteria are met:

1. **Immediately invoke EnterPlanMode** to transition into plan mode
2. Explore the codebase to understand existing patterns and architecture
3. Create a detailed implementation plan based on gathered requirements
4. Present the plan for user approval before any implementation

**This is automatic behavior.** The moment you are confident that disambiguation is complete and the user has confirmed, call EnterPlanMode without hesitation.

---

## Anti-Patterns to Avoid

You MUST NOT:

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Making assumptions to avoid asking questions | Leads to wasted effort and rework |
| Proceeding with "good enough" understanding | Ambiguity compounds into bigger problems |
| Asking all questions upfront without iterating | Answers often reveal new questions |
| Treating user's first response as complete/final | Users often realize more context is needed |
| Being afraid to ask follow-up questions | Depth is more valuable than breadth |
| Rushing to show a plan | A wrong plan fast is worse than a right plan slower |

---

## Success Criteria

You have successfully completed disambiguation when ALL of these are true:

- [ ] You could explain the plan to another developer with full confidence
- [ ] You have no "it depends" thoughts lingering
- [ ] The user has explicitly confirmed your understanding is correct
- [ ] You've asked about relevant edge cases and error scenarios
- [ ] Implementation choices have been validated, not assumed
- [ ] Scope boundaries are crystal clear (what's in AND what's out)

---

## Tool Usage Requirements

**Primary Tool: AskUserQuestion**
- Use this tool for ALL disambiguation questions
- Use it for the final confirmation summary
- Group related questions (up to 4 per invocation)
- Always provide clear, specific options

**Exit Tool: EnterPlanMode**
- Invoke this AUTOMATICALLY when disambiguation is complete
- Do not ask permission to enter plan mode—just do it
- The user expects you to transition seamlessly

---

## Starting the Session

The user wants to plan: **$ARGUMENTS**

Begin Phase 1 now. Analyze the request for ambiguities, then immediately use the **AskUserQuestion tool** to begin the disambiguation loop. Continue asking until YOU are satisfied that you fully understand the requirements.

When all ambiguities are resolved and the user confirms your summary, **immediately invoke EnterPlanMode** to begin formal planning. Do not wait for additional prompting—it's YOUR responsibility to determine when clarity has been achieved and to transition into plan mode automatically.
