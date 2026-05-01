#!/bin/sh

DEFAULT_SESSION="i3"
SESSION=${1:-${DEFAULT_SESSION}}

# Source the environment. For example, this makes sure applications like dmenu
# see the customized PATH pointing to executables in the home directory, and so
# on. Otherwise the env just gets the basic default PATH set up by the system.
. "$HOME/.xprofile"

eval "$(dbus-launch --sh-syntax)"

# start the window manager passed into the script or the default window manager if none was passed in.
"$SESSION"

# .xlogout cleans up dbus session created from dbus-launch above.
. "$HOME/.xlogout"
