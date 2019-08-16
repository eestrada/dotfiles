#!/bin/sh
export SHELL="/bin/sh"
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

# We'll just run this on everybody's Xorg session to make sure we don't miss anyone.
_users="$(who | cut -w -f1 | sort --unique)"

# On all calls we pass DISPLAY, otherwise these commands fail to run, since
# they are X commands and expect a display to be passed.

# For some reason this first call "wakes up" xrandr. If we don't do this call,
# the second one won't work.
echo $_users | DISPLAY="unix:0.0" xargs -J %s -L 1 sudo -u %s --shell -- xrandr -q

# even though we reference HDMI1, if it is disconnected xrandr does the rught
# thing because of the --auto flag and disables it in X.
echo $_users | DISPLAY="unix:0.0" xargs -J %s -L 1 sudo -u %s --shell -- xrandr --output eDP1 --auto --pos 0x0 --output HDMI1 --auto --right-of eDP1

# Let all logged in users know that something changed.
echo $_users | DISPLAY="unix:0.0" xargs -J %s -L 1 sudo -u %s --shell -- notify-send 'Auto adjusted for monitor change' 'Use the xrandr CLI tool to query new state or make adjustments'

