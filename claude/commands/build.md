---
description: Build the codebase based on the plan
argument-hint: [path-to-plan]
allowed-tools: Read, Write, Bash
model: claude-sonnet-4-5-20250929
---

# Build

Follow the `Workflow` to implement the `PATH_TO_PLAN` then `Report` the completed work.

## Variables

PATH_TO_PLAN: $ARGUMENTS

## Workflow

- If no `PATH_TO_PLAN` is provided, STOP immediately and ask the user to provide it.
- Read the plan at `PATH_TO_PLAN`. Think hard about the plan and implement it into the codebase.
- Spawn the `build_agent` using the Task tool to implement the plan.
- The build_agent will read the plan, analyze it, and implement all the changes into the codebase.
- Wait for the build_agent to complete and return its report.

## Report

- Summarize the work you've just done in a concise bullet point list.
- Report the files and total lines changed with `git diff --stat`
