#!/bin/bash

# Get current date for clipboard
CLIPBOARD_DATE=$(date "+%A %b %d")

# Get human-readable date for JARVIS (e.g., "Friday, June 12")
VOICE_DATE=$(date "+%A, %B %-d")

# Copy to CopyQ (and clipboard)
echo -n "$CLIPBOARD_DATE" | copyq copy -

# Notify
notify-send -t 3000 "$CLIPBOARD_DATE" "Date logged, Mr. Mosses."

# JARVIS Voice Synthesis (Runs in background)
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"
TEXT="Today is $VOICE_DATE, Mr Mosas."

echo "$TEXT" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q &