#!/bin/bash

# Auto-run RuboCop on Ruby files after Claude edits them

input=$(cat)
FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" =~ \.(rb|rake)$|Rakefile$|Gemfile$ ]]; then
  echo "Running RuboCop on $FILE_PATH"

  # Ensure we're using a Ruby version that has rubocop installed
  export RBENV_VERSION=3.4.7

  # Use bundle exec if Gemfile exists, otherwise run rubocop directly
  if [ -f Gemfile ]; then
    bundle exec rubocop --autocorrect "$FILE_PATH" 2>/dev/null || true
  else
    rubocop --autocorrect "$FILE_PATH" 2>/dev/null || true
  fi
fi
