#!/bin/bash
# Network status for tmux status bar — Arch/MacBook version
WIFI=$(cat /sys/class/net/wlan0/operstate 2>/dev/null)

if [ "$WIFI" = "up" ]; then
    SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
    [ -z "$SSID" ] && SSID=$(iwctl station wlan0 show 2>/dev/null | grep "Connected network" | awk '{print $NF}')
    echo "W:${SSID:-on}"
else
    echo "W:off"
fi
