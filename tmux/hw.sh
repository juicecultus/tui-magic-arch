#!/bin/bash
# Hardware status for tmux status bar — MacBook 12" Arch
# Shows: display brightness, volume, keyboard backlight

# Display brightness (0-90 → percentage) — use actual_brightness for auto-sensor
BRI=$(cat /sys/class/backlight/acpi_video0/actual_brightness 2>/dev/null)
MAX_BRI=$(cat /sys/class/backlight/acpi_video0/max_brightness 2>/dev/null)
if [ -n "$BRI" ] && [ -n "$MAX_BRI" ] && [ "$MAX_BRI" -gt 0 ]; then
    BRI_PCT=$((BRI * 100 / MAX_BRI))
    D="DISP:${BRI_PCT}%"
else
    D="DISP:?"
fi

# Volume (try Master first, fall back to PCM for MacBook)
MIXER=$(amixer get Master 2>/dev/null || amixer get PCM 2>/dev/null)
VOL=$(echo "$MIXER" | grep -oP '\[\d+%\]' | head -1 | tr -d '[]')
MUTE=$(echo "$MIXER" | grep -oP '\[o(n|ff)\]' | head -1 | tr -d '[]')
if [ "$MUTE" = "off" ]; then
    V="VOL:M"
elif [ -n "$VOL" ]; then
    V="VOL:${VOL}"
else
    V="VOL:"
fi

# Keyboard backlight (0-255 → percentage)
KBD=$(cat /sys/class/leds/spi::kbd_backlight/brightness 2>/dev/null)
MAX_KBD=$(cat /sys/class/leds/spi::kbd_backlight/max_brightness 2>/dev/null)
if [ -n "$KBD" ] && [ -n "$MAX_KBD" ] && [ "$MAX_KBD" -gt 0 ]; then
    KBD_PCT=$((KBD * 100 / MAX_KBD))
    K="KBD:${KBD_PCT}%"
else
    K=""
fi

# Update screensaver timeout based on power source (2min battery / 5min AC)
# Uses file cache to avoid tmux commands that reset the idle timer
BAT_ST=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
LOCK_CACHE="/tmp/.tmux_lock_state"
if [ "$BAT_ST" = "Discharging" ]; then
    LOCK_T=120
else
    LOCK_T=300
fi
PREV=$(cat "$LOCK_CACHE" 2>/dev/null)
if [ "$PREV" != "$LOCK_T" ]; then
    echo "$LOCK_T" > "$LOCK_CACHE"
    tmux set-option -g lock-after-time "$LOCK_T" 2>/dev/null
fi

echo "$D $V $K"
