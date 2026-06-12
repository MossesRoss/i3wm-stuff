#!/bin/bash

# 1. Dependency Check
if ! command -v acpi &> /dev/null; then
    notify-send "BATTERY SCRIPT ERROR" "Please install 'acpi': sudo apt install acpi"
    exit 1
fi

# 2. JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# Function to speak text safely
speak() {
    # Suppress output and run synchronously so it finishes before suspend
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw -q
}

# 3. State Tracking (Prevents JARVIS from repeating himself every 30 seconds)
WARNED_30=false
WARNED_10=false

# 4. Startup Confirmation
notify-send "Battery Monitor Active" "Heuristics online."

while true; do
    BAT_PER=$(acpi -b | grep -oP '\d+(?=%)' | sort -n | head -1)
    IS_DISCHARGING=$(acpi -b | grep "Discharging")

    # Safety: If ACPI failed to return a number
    if [[ -z "$BAT_PER" ]]; then
        sleep 30
        continue
    fi

    # Grid Connected Check
    if [[ -z "$IS_DISCHARGING" ]]; then
        # Reset warning flags when plugged in
        WARNED_30=false
        WARNED_10=false
        sleep 60
        continue
    fi

    # --- EMERGENCY SUSPEND (8%) ---
    if [ "$BAT_PER" -le 8 ]; then
        notify-send -u critical "CRITICAL BATTERY ($BAT_PER%)" "EMERGENCY SUSPEND."
        speak "Critical energy failure. Power reserves at $BAT_PER percent. Initiating emergency suspend protocol to preserve core systems. Goodbye sir."
        sleep 1 
        systemctl suspend
        sleep 60 

    # --- CRITICAL PRESSURE (10%) ---
    elif [ "$BAT_PER" -le 12 ] && [ "$WARNED_10" = false ]; then
        notify-send -u critical "⚠️ CRITICAL PRESSURE: $BAT_PER%" "Connect charger immediately."
        speak "Sir, I must strongly advise connecting to the main grid immediately. Core energy cells are critical at $BAT_PER percent. System shutdown is imminent."
        WARNED_10=true
        sleep 30

    # --- LOW WARNING (30%) ---
    elif [ "$BAT_PER" -le 30 ] && [ "$WARNED_30" = false ]; then
        notify-send -u normal "🔋 Battery at $BAT_PER%" "Find power source."
        speak "Pardon the interruption, Mr Mosas. Internal power reserves have dropped to $BAT_PER percent."
        WARNED_30=true
        sleep 60

    else
        # Standard polling interval
        sleep 30
    fi
done