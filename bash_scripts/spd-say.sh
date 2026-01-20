#!/bin/bash

REAL_SPD_SAY="/usr/bin/spd-say"
READ_LOUD="/usr/local/bin/read-loud"

# 1. Check for the "Wait" flag (-w or --wait)
# If the app EXPLICITLY asks to wait, we must block.
if [[ "$*" == *"-w"* ]] || [[ "$*" == *"--wait"* ]]; then
    if [[ "$1" == -* ]]; then
         # Complex flags + Wait -> Use Robot
         "$REAL_SPD_SAY" "$@"
    else
         # Text + Wait -> Use Human (Blocking)
         "$READ_LOUD" "$*"
    fi
    exit 0
fi

# 2. Check for other complex flags (like -p pitch, -r rate)
# Apps using these need the robot, but usually expect immediate exit.
if [[ "$1" == -* ]]; then
    "$REAL_SPD_SAY" "$@"
    exit 0
fi

# 3. Default: Just Text (Fire and Forget)
# We run read-loud in the background using nohup so Claude doesn't wait.
nohup "$READ_LOUD" "$*" >/dev/null 2>&1 &
exit 0