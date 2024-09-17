#!/bin/sh

# Source our environment. For example, this makes sure applications like dmenu
# see our customized PATH pointing to executables in our home directory, and so
# on. Otherwise we just get the basic default PATH set up by the system.
. "$HOME/.profile"

# force certain XDG based applications to think we are in XFCE so they look and behave more nicely.
# https://www.reddit.com/r/i3wm/comments/6in8m1/did_you_know_xdg_current_desktop/
export XDG_CURRENT_DESKTOP=XFCE

sysresources=/usr/local/etc/X11/xinit/.Xresources
sysmodmap=/usr/local/etc/X11/xinit/.Xmodmap
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
xinitrclocal=$HOME/.xinitrc_local.sh

DEFAULT_SESSION="i3"
SESSION=${1:-${DEFAULT_SESSION}}

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -f "$xinitrclocal" ]; then
    # shellcheck disable=SC1090 # Allow sourcing non-constant.
    . "$xinitrclocal"
fi

# start some nice programs

# set the background to pure black
xsetroot -solid black &

# We use xscreensaver both to lock the screen and for its basic power
# management functionality.
xscreensaver -no-splash &

# Make sure the basic home directory file hierarchy exists.
xdg-user-dirs-update &

# Have numlock on at start up
numlockx on &

# Make sure we get OSD notifications in FreeBSD.
# dunst a is lightweight notification utility. It is also desktop environment
# and toolkit independent.  Score!
# install from sysutils/dunst on FreeBSD
dunst &

# dsbmixer is a mixer for bsd. In situations where keyboard keys for turning
# up/down/off do not work, having this mixer in the tray is pretty critical.
# The `-i` flag ensures the mixer does not show a window on startup, only a
# status tray icon.
dsbmixer -i &

# start the window manager passed into the script or the default window manager if none was passed in.
exec "$SESSION"
