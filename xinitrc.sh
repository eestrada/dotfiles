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

# start the window manager passed into the script
exec $1
