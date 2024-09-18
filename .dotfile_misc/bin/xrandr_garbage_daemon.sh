#!/bin/sh

# This daemon is garbage. Use it anyway because you don't have much choice since devd refuses to match your entry in devd.conf.

# NOTE: we don't want to hog resources, so renice ourselves

renice 20 $$

hdmi1_state ()
{
    xrandr -q | grep HDMI1 | cut -w -f2
}

_prev="$(hdmi1_state)"

while sleep 2
do
    if [ "$(hdmi1_state)" '!=' "${_prev}" ]; then
        _prev=$(hdmi1_state)
        xrandr -q >/dev/null
        xrandr --output eDP1 --auto --pos 0x0 --output HDMI1 --auto --right-of eDP1
    fi
done

