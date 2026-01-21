#!/bin/bash

# --- CONFIGURATION ---
# 1. Point this to your actual read-loud script
READ_LOUD="/usr/local/bin/read-loud" 
# 2. Where to save errors (check this file if it stays silent!)
LOG_FILE="/tmp/tts-debug.log"

# --- MAIN LOGIC ---

# Function to run the TTS in the background safely
run_silent() {
    # We export the PATH here to ensure background processes find 'piper'/'edge-tts'
    export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
    
    # Run read-loud, redirect ALL output to log, and disown the process
    nohup "$READ_LOUD" "$1" > "$LOG_FILE" 2>&1 & disown
}

# 1. Check for blocking flags (-w, --wait)
# If these exist, we MUST wait (run wnormally, no nohup)
if [[ "$*" == *"-w"* ]] || [[ "$*" == *"--wait"* ]]; then
    "$READ_LOUD" "$*"
    exit 0
fi

# 2. Check for "Robot Flags" (pitch, rate, etc.)
# If you want to support robot flags, pass them to real spd-say here.
# For now, we assume you want read-loud for everything else.

# 3. Fire and Forget (Standard Case)
# This is what Claude Code triggers.
run_silent "$*"

# Exit immediately so Claude Code doesn't hang
exit 0