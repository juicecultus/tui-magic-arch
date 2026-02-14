#!/bin/bash
# Restart WiFi after resume from suspend
case $1 in
    post)
        sleep 2
        nmcli radio wifi off
        sleep 1
        nmcli radio wifi on
        sleep 3
        nmcli con up heero 2>/dev/null
        logger "wifi-resume: WiFi restarted after suspend"
        ;;
esac
