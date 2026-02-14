#!/bin/sh
mem=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
used=$(free -m | awk '/Mem:/ {print $3}')
echo "RAM:${used}M(${mem}%)"
