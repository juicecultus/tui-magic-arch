#!/bin/bash
# Dashboard layout — MacBook 12" split view with fastfetch, btop, cava/cmatrix

SESSION="dashboard"
tmux kill-session -t "$SESSION" 2>/dev/null

tmux new-session -d -s "$SESSION"

# Top-left: fastfetch + shell
tmux send-keys -t "$SESSION" 'fastfetch && echo "" && echo "Type commands here..."' Enter

# Top-right: btop
tmux split-window -h -t "$SESSION"
tmux send-keys -t "$SESSION" 'btop' Enter

# Bottom-left: cmatrix accent
tmux select-pane -t "$SESSION:1.1"
tmux split-window -v -t "$SESSION" -p 35
tmux send-keys -t "$SESSION" 'cmatrix -ab -u 6 -C green' Enter

# Bottom-right: cava (if audio available) or tty-clock
tmux select-pane -t "$SESSION:1.3"
tmux split-window -v -t "$SESSION" -p 35
tmux send-keys -t "$SESSION" 'cava 2>/dev/null || tty-clock -scC 2' Enter

# Balance and focus
tmux select-layout -t "$SESSION" tiled
tmux select-pane -t "$SESSION:1.1"

tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
