#!/bin/sh
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
    status=$(cat /sys/class/power_supply/BAT0/status)
    # Use charge_now/charge_full for actual % (kernel capacity uses design max)
    charge_now=$(cat /sys/class/power_supply/BAT0/charge_now 2>/dev/null)
    charge_full=$(cat /sys/class/power_supply/BAT0/charge_full 2>/dev/null)
    if [ -n "$charge_now" ] && [ -n "$charge_full" ] && [ "$charge_full" -gt 0 ]; then
        cap=$((charge_now * 100 / charge_full))
    else
        cap=$(cat /sys/class/power_supply/BAT0/capacity)
    fi
    case "$status" in
        Charging)    icon="+" ;;
        Discharging) icon="-" ;;
        Full)        icon="=" ;;
        *)           icon="=" ;;
    esac
    # Estimate time remaining
    TIME=""
    cur=$(cat /sys/class/power_supply/BAT0/current_avg 2>/dev/null)
    if [ -n "$cur" ] && [ "$cur" -gt 0 ]; then
        if [ "$status" = "Discharging" ]; then
            mins=$((charge_now * 60 / cur))
        elif [ "$status" = "Charging" ]; then
            remain=$((charge_full - charge_now))
            mins=$((remain * 60 / cur))
        else
            mins=""
        fi
        if [ -n "$mins" ] && [ "$mins" -gt 0 ]; then
            h=$((mins / 60))
            m=$((mins % 60))
            TIME="${h}h$(printf '%02d' $m)"
        fi
    fi
    if [ -n "$TIME" ]; then
        echo "BAT:${icon}${cap}%(${TIME})"
    else
        echo "BAT:${icon}${cap}%"
    fi
else
    echo "AC"
fi
