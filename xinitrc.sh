#!/bin/sh

# Source our environment. For example, this makes sure applications like dmenu
# see our customized PATH pointing to executables in our home directory, and so
# on. Otherwise we just get the basic default PATH set up by the system.
. $HOME/.profile

# FIXME: set "XDG_CURRENT_DESKTOP" variable
# https://www.reddit.com/r/i3wm/comments/6in8m1/did_you_know_xdg_current_desktop/
# NOTE: force certain XDG based applications to think we are in XFCE so they look and behave more nicely.
export XDG_CURRENT_DESKTOP=XFCE

sysresources=/usr/local/etc/X11/xinit/.Xresources
sysmodmap=/usr/local/etc/X11/xinit/.Xmodmap
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
xinitrclocal=$HOME/.xinitrc_local.sh

DEFAULT_SESSION="i3"
SESSION=${1:-i3}

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

# TODO: instead of this case statement, use an if statement to set `SESSION`
#  higher in the file and just return this case statement to a simple call
#  to exec.
# start the window manager passed into the script
case "$SESSION" in
    default) exec "$DEFAULT_SESSION" ;;
    *) exec "$SESSION" ;;
esac

