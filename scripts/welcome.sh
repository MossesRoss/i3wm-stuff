#!/bin/bash

PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

echo "You're welcome sir." | \
"$PIPER_DIR/piper" \
--model "$MODEL" \
--length_scale 0.80 \
--output_raw 2>/dev/null | \
aplay -r 22050 -f S16_LE -t raw -q &