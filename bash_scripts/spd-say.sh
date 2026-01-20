#!/bin/bash

# Define paths
REAL_SPD_SAY="/usr/bin/spd-say"
READ_LOUD="read-loud"

# Check if the first argument starts with a hyphen (indicating a flag like -w, -r, etc.)
if [[ "$1" == -* ]]; then
    # Flags detected! 
    # System scripts might rely on this specific behavior, so we use the original.
    "$REAL_SPD_SAY" "$@"
else
    # No flags detected, just text.
    # Use the high-quality voice.
    "$READ_LOUD" "$*"
fi
