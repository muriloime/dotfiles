#!/bin/bash

# Auto-run Ruff on Python files after Claude edits them

input=$(cat)
FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" =~ \.py$ ]]; then
  echo "Running Ruff on $FILE_PATH"

  # Try to use uv if available, otherwise fall back to direct ruff
  if command -v uv &> /dev/null && [ -f pyproject.toml ]; then
    # Format the file
    uv run ruff format "$FILE_PATH" 2>/dev/null || ruff format "$FILE_PATH" 2>/dev/null || true
    # Fix any auto-fixable linting issues
    uv run ruff check --fix "$FILE_PATH" 2>/dev/null || ruff check --fix "$FILE_PATH" 2>/dev/null || true
  else
    # Format the file
    ruff format "$FILE_PATH" 2>/dev/null || true
    # Fix any auto-fixable linting issues
    ruff check --fix "$FILE_PATH" 2>/dev/null || true
  fi
fi
