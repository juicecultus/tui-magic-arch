#!/bin/bash
# MacBook 12" fn key handler — listens on Apple SPI Keyboard
# Handles: brightness, volume, keyboard backlight
# Runs as a systemd service

KEYBOARD="/dev/input/event4"
BACKLIGHT="/sys/class/backlight/acpi_video0"
KBD_BL="/sys/class/leds/spi::kbd_backlight"
MUTE_FILE="/tmp/.macbook_mute_vol"

vol_beep() {
    # Short beep at current volume level as audible feedback
    speaker-test -t sine -f 880 -l 1 -p 1 >/dev/null 2>&1 &
    sleep 0.08
    kill $! 2>/dev/null
}

refresh_bar() {
    # Force tmux to update status bar instantly
    su - justin -c "tmux refresh-client -S" 2>/dev/null
}

evtest "$KEYBOARD" 2>/dev/null | while read line; do
    # Only act on key press (value 1) or repeat (value 2)
    echo "$line" | grep -qE "value [12]" || continue

    if echo "$line" | grep -q "KEY_BRIGHTNESSDOWN"; then
        cur=$(cat "$BACKLIGHT/brightness")
        new=$((cur - 5))
        [ "$new" -lt 0 ] && new=0
        echo "$new" > "$BACKLIGHT/brightness"
        refresh_bar

    elif echo "$line" | grep -q "KEY_BRIGHTNESSUP"; then
        cur=$(cat "$BACKLIGHT/brightness")
        max=$(cat "$BACKLIGHT/max_brightness")
        new=$((cur + 5))
        [ "$new" -gt "$max" ] && new=$max
        echo "$new" > "$BACKLIGHT/brightness"
        refresh_bar

    elif echo "$line" | grep -q "KEY_KBDILLUMDOWN"; then
        cur=$(cat "$KBD_BL/brightness")
        new=$((cur - 25))
        [ "$new" -lt 0 ] && new=0
        echo "$new" > "$KBD_BL/brightness"
        refresh_bar

    elif echo "$line" | grep -q "KEY_KBDILLUMUP"; then
        cur=$(cat "$KBD_BL/brightness")
        max=$(cat "$KBD_BL/max_brightness")
        new=$((cur + 25))
        [ "$new" -gt "$max" ] && new=$max
        echo "$new" > "$KBD_BL/brightness"
        refresh_bar

    elif echo "$line" | grep -q "KEY_MUTE"; then
        # PCM has no mute switch — toggle by saving/restoring volume
        if [ -f "$MUTE_FILE" ]; then
            saved=$(cat "$MUTE_FILE")
            amixer -q set PCM "${saved}%" 2>/dev/null
            rm -f "$MUTE_FILE"
        else
            cur_vol=$(amixer get PCM 2>/dev/null | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')
            echo "$cur_vol" > "$MUTE_FILE"
            amixer -q set PCM 0% 2>/dev/null
        fi
        refresh_bar

    elif echo "$line" | grep -q "KEY_VOLUMEDOWN"; then
        amixer -q set Master 5%- 2>/dev/null || amixer -q set PCM 5%-
        vol_beep
        refresh_bar

    elif echo "$line" | grep -q "KEY_VOLUMEUP"; then
        amixer -q set Master 5%+ 2>/dev/null || amixer -q set PCM 5%+
        vol_beep
        refresh_bar
    fi
done
