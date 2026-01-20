#!/bin/bash

# Speak notification when Claude finishes a job that involved file edits

if [ -f /tmp/.claude_did_edit ]; then
  /usr/local/bin/spd-say -l en "Job is finished"
  rm /tmp/.claude_did_edit
fi
