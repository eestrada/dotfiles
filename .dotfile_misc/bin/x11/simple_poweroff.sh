#!/bin/sh

if zenity --question --title 'Poweroff?' --text 'Poweroff?' ; then
  printf '%s\n' 'Exit window manager...'
  i3-msg exit

  printf '%s\n' 'Waiting for Xserver to fully exit...'
  # See: https://unix.stackexchange.com/a/338862
  while xhost 2>/dev/null 1>/dev/null; do sleep 1; done

  printf '%s\n' 'Powering off...'
  sudo poweroff
else
  printf '%s\n' 'Skipping poweroff.'
fi
