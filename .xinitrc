#!/bin/sh

DEFAULT_SESSION="i3"
SESSION=${1:-${DEFAULT_SESSION}}

# Source our environment. For example, this makes sure applications like dmenu
# see our customized PATH pointing to executables in our home directory, and so
# on. Otherwise we just get the basic default PATH set up by the system.
. "$HOME/.xprofile"

# start the window manager passed into the script or the default window manager if none was passed in.
exec "$SESSION"
