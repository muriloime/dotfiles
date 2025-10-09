---
allowed-tools: Read, Write, Edit, Glob, Grep, MultiEdit
description: Creates a concise engineering implementation plan based on user requirements and saves it to specs directory
argument-hint: [user-prompt] [documentation urls] [relevant files]
model: claude-sonnet-4-5-20250929
---

# Quick Plan

Create a detailed implementation plan based on the user's requirements provided through the `USER_PROMPT` variable. Analyze the request, pull in the documentation, think through the implementation approach, and save a comprehensive specification document to `PLAN_OUTPUT_DIRECTORY/<name-of-plan>.md` that can be used as a blueprint for actual development work. Follow the `Instructions` and work through the `Workflow` to create the plan.

## Variables

USER_PROMPT: $1
DOCUMENTATION_URLS: $2
RELEVANT_FILES_COLLECTION: $3
PLAN_OUTPUT_DIRECTORY: `specs/`
DOCUMENTATION_OUTPUT_DIRECTORY: `ai_docs/`

## Instructions

- IMPORTANT: If no `USER_PROMPT`, `DOCUMENTATION_URLS`, or `RELEVANT_FILES_COLLECTION` is provided, stop and ask the user to provide them.
- READ the `RELEVANT_FILES_COLLECTION` file which contains a structured bullet point list of files with line ranges in this format: `- <path to file> (offset: N, limit: M)`
- Carefully analyze the user's requirements provided in the USER_PROMPT variable
- With Task, in parallel, spawn subagents to gather documentation:
  - Use the `webfetch_agent` to scrape each DOCUMENTATION_URLS
  - Use the `context7_prompt_agent` to retrieve documentation for relevant libraries and tools explicitly mentioned in the USER_PROMPT
  - Use the `context7_code_agent` to analyze code snippets from RELEVANT_FILES_COLLECTION and retrieve documentation for libraries identified in the actual code
  - Instruct the subagents to save each piece of documentation to `DOCUMENTATION_OUTPUT_DIRECTORY/<name-of-documentation>.md`
  - Instruct the subagents to return the path to each piece of documentation for future reference
  - Then collect the paths to each piece of documentation for future reference
- Think deeply (ultrathink) about the best approach to implement the requested functionality or solve the problem
- READ the files listed in the `RELEVANT_FILES_COLLECTION` using the specified offset and limit values to help you understand the codebase and implement the plan.
- Structure your plan as a comprehensive markdown document with clear sections
- Create a descriptive kebab-case filename based on the plan's main topic
- Save the plan to `PLAN_OUTPUT_DIRECTORY/<filename>.md`

## Workflow

1. Analyze Requirements - THINK HARD and parse the USER_PROMPT to understand the core problem and desired outcome
2. Scrape Documentation - With Task, in parallel, spawn documentation gathering agents:
   - Spawn `webfetch_agent` tasks for each DOCUMENTATION_URLS
   - Spawn `context7_prompt_agent` task to retrieve documentation for libraries mentioned in USER_PROMPT
   - Spawn `context7_code_agent` task to analyze code from RELEVANT_FILES_COLLECTION and retrieve relevant documentation
   - Collect all documentation paths for reference
3. Design Solution - Develop technical approach including architecture decisions and implementation strategy
4. Document Plan - Structure a comprehensive markdown document with problem statement, implementation steps, and testing approach
5. Generate Filename - Create a descriptive kebab-case filename based on the plan's main topic
6. Save & Report - Follow the `Report` section to write the plan to `PLAN_OUTPUT_DIRECTORY/<filename>.md` and provide a summary of key components

## Report

After creating the plan:

- Save the plan document to `PLAN_OUTPUT_DIRECTORY/<filename>.md`
- The plan should include:
  - **Problem Statement**: Clear description of what needs to be built/solved
  - **Requirements Analysis**: Breakdown of the USER_PROMPT into specific requirements
  - **Architecture Overview**: High-level technical approach and design decisions
  - **Implementation Steps**: Detailed step-by-step implementation plan
  - **File Changes**: List of files that need to be created/modified based on RELEVANT_FILES_COLLECTION
  - **Testing Approach**: How to verify the implementation works correctly
  - **Edge Cases & Considerations**: Potential issues and how to handle them
- Provide a concise summary of:
  - The plan filename and location
  - Key implementation steps (3-5 bullet points)
  - Main technical decisions
  - Estimated complexity
- Return the full path to the plan file so it can be used in subsequent commands
