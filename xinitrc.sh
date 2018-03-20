#!/bin/sh

sysresources=/usr/local/etc/X11/xinit/.Xresources
sysmodmap=/usr/local/etc/X11/xinit/.Xmodmap
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

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

XDG_CURRENT_DESKTOP="XFCE";
export XDG_CURRENT_DESKTOP
# start some nice programs

# We use xscreensaver both to lock the screen, but also for its basic power
# management functionality.
xscreensaver -no-splash &

# Make sure the basic home directory file hierarchy exists.
xdg-user-dirs-update &

# Have numlock on at start up
numlockx on

# Make sure we get pop up notifications in FreeBSD.
# dunst a is lightweight notification utility. It is also desktop environment
# and toolkit independent.  Score!
dunst &

# start the best window manager in the world
exec i3
