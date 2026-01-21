#!/bin/bash

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

if [ -n "$session_name" ]; then
    /usr/local/bin/read-loud "$1. Session $session_name"
else
    /usr/local/bin/read-loud "$1"
fi
