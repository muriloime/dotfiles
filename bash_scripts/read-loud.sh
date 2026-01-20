#!/bin/bash

# Define text to read
text="$*"

# Install pipx if not available
if ! command -v pipx &> /dev/null; then
  echo "pipx not found, installing..."
  python3 -m pip install --user pipx
  python3 -m pipx ensurepath
  export PATH="$HOME/.local/bin:$PATH"
fi

# Check dependencies
if ! command -v pipx &> /dev/null; then echo "Error: pipx is required."; exit 1; fi

# --- LEVEL 1: EDGE-TTS (Online, Best Quality) ---

# Auto-install edge-tts or mpv if missing
if ! command -v edge-playback &> /dev/null; then echo "Installing edge-tts..."; pipx install edge-tts; fi
if ! command -v mpv &> /dev/null; then echo "Installing mpv..."; sudo apt install -y mpv; fi

# Try speaking. If successful (exit code 0), exit. 
if edge-playback --text "$text" > /dev/null 2>&1; then
    exit 0
fi

# --- LEVEL 2: PIPER (Offline, Good Quality) ---
model_dir="$HOME/.local/share/piper_voices"
model_file="en_US-lessac-medium.onnx"
model_path="$model_dir/$model_file"

# Auto-install piper if missing
if ! command -v piper &> /dev/null; then echo "Installing piper..."; pipx install piper-tts; fi

# Download model if missing
if [ ! -f "$model_path" ]; then
    echo "Downloading offline voice model ($model_file)..."
    mkdir -p "$model_dir"
    wget -q -O "$model_path" "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx"
    wget -q -O "$model_path.json" "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json"
fi

# Try piper. 
echo "$text" | piper --model "$model_path" --output-raw 2>/dev/null | aplay -q -r 22050 -f S16_LE -t raw - 2>/dev/null

if [ $? -eq 0 ]; then
    exit 0
fi

# --- LEVEL 3: SYSTEM FALLBACK (spd-say) ---
echo "Network and Piper failed, using system fallback."
/usr/bin/spd-say "$text"
