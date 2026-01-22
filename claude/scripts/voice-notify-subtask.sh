#!/bin/bash

# Announce when a subtask is started (task marked as in_progress)

input=$(cat)

# Extract todos array and check for in_progress tasks
in_progress_task=$(echo "$input" | jq -r '.tool_input.todos[]? | select(.status == "in_progress") | .activeForm' | head -1)

# Only announce if a task is in progress and we're already working (flag exists)
if [ -n "$in_progress_task" ] && [ -f /tmp/.claude_did_edit ]; then
  /usr/local/bin/read-loud "$in_progress_task"
fi
