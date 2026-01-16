#!/bin/bash

# Auto-run Prettier on JS/TS files after Claude edits them

input=$(cat)
FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" =~ \.(js|jsx|ts|tsx|json|css|scss|md)$ ]]; then
  echo "Running Prettier on $FILE_PATH"

  # Try to use project's prettier if available, otherwise use global
  if [ -f node_modules/.bin/prettier ]; then
    node_modules/.bin/prettier --write "$FILE_PATH" 2>/dev/null || true
  elif command -v prettier &> /dev/null; then
    prettier --write "$FILE_PATH" 2>/dev/null || true
  else
    npx -y prettier --write "$FILE_PATH" 2>/dev/null || true
  fi
fi
