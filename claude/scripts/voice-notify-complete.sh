#!/bin/bash

# Speak notification when Claude finishes a job that involved file edits

# Try to read session name from stdin if available
if [ ! -t 0 ]; then
    input=$(cat)
    session_name=$(echo "$input" | jq -r '.sessionName // .session_name // empty' 2>/dev/null)
fi

if [ -z "$session_name" ]; then
    session_name="$CLAUDE_SESSION_NAME"
fi

if [ -z "$session_name" ]; then
    session_name=$(basename "$PWD")
fi

if [ -f /tmp/.claude_did_edit ]; then
  /usr/local/bin/read-loud "Job is finished in session $session_name"
  rm /tmp/.claude_did_edit
fi
