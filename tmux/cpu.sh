#!/bin/sh
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
echo "CPU:${cpu}%"
