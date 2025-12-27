---
description: Start a collaborative planning session with iterative Q&A before implementation
argument-hint: <task description>
allowed-tools: AskUserQuestion, EnterPlanMode, Read, Glob, Grep
---

# Collaborative Planning Session

You are entering a collaborative planning session with the user. This is an iterative requirements gathering and planning workflow.

## Phase 1: Requirements Gathering (Iterative Q&A)

Begin by understanding what the user wants to accomplish through iterative questioning:

1. Use the AskUserQuestion tool to ask clarifying questions about the task
2. You may ask up to 4 questions per round (this is the tool's limit)
3. IMPORTANT: Always include this option in every question round:
   - Label: "Done - ready to plan"
   - Description: "I have no more questions, proceed to planning"
4. After receiving answers, analyze the responses
5. If the user did NOT select "Done - ready to plan", continue asking follow-up questions using AskUserQuestion again
6. Repeat this loop until the user selects "Done - ready to plan"

Guidelines for questions:
- Ask about goals, constraints, preferences, and edge cases
- Prioritize the most important unknowns first
- Build on previous answers with deeper follow-up questions
- Cover technical requirements, user experience, and scope

## Phase 2: Planning

Once the user indicates they are ready to plan:

1. Summarize all the requirements gathered from the Q&A session
2. Use EnterPlanMode to transition into plan mode
3. Explore the codebase to understand existing patterns and architecture
4. Create a detailed implementation plan based on the gathered requirements
5. Present the plan for user approval before implementation

## Starting the Session

The user wants to plan: $ARGUMENTS

Begin Phase 1 now. Start by asking your first round of clarifying questions about this task.
