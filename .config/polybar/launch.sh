#!/bin/bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Wait until all polybars have closed
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
polybar --reload mybar 2>&1 | tee -a /tmp/polybar.log & disown

# Multiple polybars isn't working for me yet:
# https://www.reddit.com/r/i3wm/comments/m2t4mf/configure_polybar_for_2_monitors/

# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar --reload mybar &
# done

# echo "Polybar launched..."
