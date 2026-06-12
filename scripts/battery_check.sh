#!/bin/bash

# ==========================================
# PARROT OS: CEO BATTERY MONITOR
# ==========================================

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"

# 1. Dependency Check
if ! command -v acpi &> /dev/null; then
    notify-send "BATTERY SCRIPT ERROR" "Please install 'acpi': sudo apt install acpi"
    exit 1
fi

# 2. JARVIS Voice Synthesis Engine
PIPER_DIR="$HOME/.local/piper"
MODEL="$PIPER_DIR/en_GB-alan-medium.onnx"

# BULLETPROOF SPEAK FUNCTION
speak() {
    # Generate audio to RAM (/tmp) to prevent background buffer underruns
    echo "$1" | "$PIPER_DIR/piper" --model "$MODEL" --length_scale 0.85 --output_file /tmp/jarvis_alert.wav 2>/dev/null
    
    # Try PulseAudio first, fallback to direct ALSA if Pulse is locked
    paplay /tmp/jarvis_alert.wav 2>/dev/null || aplay -q /tmp/jarvis_alert.wav 2>/dev/null
}

# 3. State Tracking (Prevents repeating)
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
        WARNED_30=false
        WARNED_10=false
        sleep 60
        continue
    fi

    # --- EMERGENCY SUSPEND (8%) ---
    if [ "$BAT_PER" -le 8 ]; then
        notify-send -u critical "CRITICAL BATTERY ($BAT_PER%)" "EMERGENCY SUSPEND."
        speak "Critical energy failure. Power reserves at $BAT_PER percent. Initiating emergency suspend protocol to preserve core systems. Goodbye sir."
        sleep 2 
        systemctl suspend
        sleep 60 

    # --- CRITICAL PRESSURE (12%) ---
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