#!/bin/bash

# Get current time for clipboard (24h or format of your choice)
CLIPBOARD_TIME=$(date "+%H:%M:%S")

# Get human-readable time for JARVIS (12-hour format e.g., "9 15 PM")
VOICE_TIME=$(date "+%-I %M %p") 

# Copy to CopyQ (and system clipboard) without a newline
echo -n "$CLIPBOARD_TIME" | copyq copy -

# Send visual notification
notify-send -t 3000 "$CLIPBOARD_TIME" "Time logged, Mr. Mosses."

# JARVIS Voice Synthesis (Runs in background so the script exits instantly)
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"
TEXT="The current time is $VOICE_TIME sir."

echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q &