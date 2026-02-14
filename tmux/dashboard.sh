#!/bin/bash
# Dashboard layout — MacBook 12" 2017 (144x44 at 200% DPI)
# 2-pane vertical split to keep each pane wide enough for btop (80x24 min)

SESSION="dashboard"
tmux kill-session -t "$SESSION" 2>/dev/null

tmux new-session -d -s "$SESSION"

# Left pane: fastfetch + cmatrix below
tmux send-keys -t "$SESSION" 'fastfetch; echo ""; cmatrix -ab -u 6 -C green' Enter

# Right pane: btop (full height)
tmux split-window -h -t "$SESSION" -p 55
tmux send-keys -t "$SESSION" 'btop' Enter

# Focus left pane
tmux select-pane -t "$SESSION:1.1"

tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
