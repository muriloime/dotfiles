#!/bin/bash

# --- 1. ENVIRONMENT REPAIR (The Fix) ---
# Hooks run in a stripped environment. We must manually restore Audio & Path access.

# Fix Path (so we can find piper/edge-tts/mpv)
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Fix Audio (Crucial: Tell tools where the PulseAudio/PipeWire socket is)
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# --- 2. CONFIGURATION ---
SINGLE_VOICE_MODE=true

speak_logic() {
    local text="$1"

    # Kill previous audio if requestedw
    if [ "$SINGLE_VOICE_MODE" = true ]; then
        pkill -f "edge-playback" 2>/dev/null
        pkill -f "piper" 2>/dev/null
        pkill -f "aplay" 2>/dev/null
    fi

    # Install pipx if missing (Headless check)
    if ! command -v pipx &> /dev/null; then
        python3 -m pip install --user pipx >/dev/null 2>&1
        python3 -m pipx ensurepath >/dev/null 2>&1
    fi

    # --- LEVEL 1: EDGE-TTS (Online) ---
    if ! command -v edge-playback &> /dev/null; then pipx install edge-tts >/dev/null 2>&1; fi
    if ! command -v mpv &> /dev/null; then sudo apt install -y mpv >/dev/null 2>&1; fi

    # Check for internet (fast ping)
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        if edge-playback --text "$text" > /dev/null 2>&1; then
            return 0
        fi
    fi

    # --- LEVEL 2: PIPER (Offline) ---
    local model_dir="$HOME/.local/share/piper_voices"
    local model_path="$model_dir/en_US-lessac-medium.onnx"

    if ! command -v piper &> /dev/null; then pipx install piper-tts >/dev/null 2>&1; fi

    if [ ! -f "$model_path" ]; then
        mkdir -p "$model_dir"
        wget -q -O "$model_path" "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx"
        wget -q -O "$model_path.json" "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json"
    fi

    # Play using aplay (Native ALSA/Pulse wrapper)
    if echo "$text" | piper --model "$model_path" --output-raw 2>/dev/null | aplay -q -r 22050 -f S16_LE -t raw - 2>/dev/null; then
        return 0
    fi

    # --- LEVEL 3: FALLBACK ---
    /usr/bin/spd-say "$text"
}

# --- 3. EXECUTION MODE ---

# If wait flag is present, run in foreground
if [[ "$*" == *"-w"* ]] || [[ "$*" == *"--wait"* ]]; then
    speak_logic "$*"
else
    # Fire and Forget:
    # 1. setsid: Detaches from the terminal session entirely (fixes the hang)
    # 2. >/dev/null: Closes IO streams (fixes the hang)
    if command -v setsid >/dev/null 2>&1; then
        setsid bash -c "$(declare -f speak_logic); speak_logic '$*'" >/dev/null 2>&1 &
    else
        ( speak_logic "$*" ) >/dev/null 2>&1 & disown
    fi
    exit 0
fi