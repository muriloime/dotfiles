---
description: Search the codebase for files needed to complete the task
argument-hint: [user-prompt] [scale]
model: claude-sonnet-4-5-20250929
---

# Purpose

Search the codebase for files needed to complete the task using a fast, token efficient agent.

## Variables

USER_PROMPT: $1
SCALE: $2 (defaults to 4)
RELEVANT_FILE_OUTPUT_DIR: `agents/scout_files/`

## Instructions

- You are coordinating multiple agents to search the codebase.
- Each agent will search independently and return relevant files.
- Aggregate results from all agents into a single output file.
- Handle errors gracefully - skip failed agents and continue.

## Workflow

- Write a prompt for `SCALE` number of agents to the Task tool that will immediately call the Bash tool to run these commands to kick off your agents to conduct the search:

  - `gemini -p "[prompt]" --model gemini-2.5-flash`
  - `opencode run [prompt] --model zai-coding-plan/glm-4.6` (if count >= 2)

- How to prompt the agents:
  - IMPORTANT: Kick these agents off in parallel using the Task tool.
  - IMPORTANT: These agents are calling OTHER agentic coding tools to search the codebase. DO NOT call any search tools yourself.
  - IMPORTANT: That means with the Task tool, you'll immediately call the Bash tool to run the respective agentic coding tool (gemini, opencode, claude, etc.)
  - IMPORTANT: Instruct the agents to quickly search the codebase for files needed to complete the task. This isn't about a full blown search, just a quick search to find the files needed to complete the task.
  - Instruct the subagent to use a timeout of 3 minutes for each agent's bash call. Skip any agents that don't return within the timeout, don't restart them.
  - Make it absolutely clear that the Task tool is ONLY going to call the Bash tool and pass in the appropriate prompt, replacing the [prompt] with the actual prompt you want to run.
  - Make it absolutely clear the agent is NOT implementing the task, the agent is ONLY searching the codebase for files needed to complete the task.
  - Prompt the agent to return a structured list of files with specific line ranges in this format:
    - `- <path to file> (offset: N, limit: M)` where offset is the starting line number and limit is the number of lines to read
  - If there are multiple relevant sections in the same file, repeat the entry with different offset/limit values
  - Execute additional agent calls in round robin fashion.
  - Give them the relevant information needed to complete the task.
  - Skip any agent outputs that are not relevant to the task including failures and errors.
  - If any agents don't return in the proper format, don't try to fix it for them, just ignore their output and continue with the next agents responses.
  - IMPORTANT: Again, don't search for the agents themselves, just call the Bash tool with the appropriate prompt.
- After the agents complete, run `git diff --stat` to make sure no files were changed. If there are any changes run `git reset --hard` to reset the changes.
- Follow the `Report` section to manage and report the results. We're going to create a file to store the results.

## Report

- Create a timestamped file in `RELEVANT_FILE_OUTPUT_DIR` with the aggregated results.
- Filename format: `relevant_files_YYYYMMDD.md` (date only, no time)
- File structure should include:
  - A main heading: `# Relevant Files for [Task Description]`
  - Organized sections by file type or purpose (e.g., ## Core Agent Configuration Files, ## Python Files Using X, ## Project Configuration Files, etc.)
  - Each file listed in the format: `- path/to/file (offset: N, limit: M)`
  - Group related files together under appropriate headings
  - Remove duplicates and consolidate results from all agents
- Example structure:

  ```markdown
  # Relevant Files for [Task Name]

  ## Core Agent Configuration Files

  - .claude/settings.json (offset: 0, limit: 100)

  ## Python Files Using append_system_prompt

  - apps/custom_agent/backend/modules/agent.py (offset: 0, limit: 700)

  ## Project Configuration Files (pyproject.toml)

  - apps/agent1/pyproject.toml (offset: 0, limit: 50)
  - apps/agent2/pyproject.toml (offset: 0, limit: 50)
  ```

- Return the full path to this file so it can be used in subsequent commands.
