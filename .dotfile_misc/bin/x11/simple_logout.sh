#!/bin/sh

if zenity --question --title 'Logout?' --text 'Logout?' ; then
  printf '%s\n' 'Logging out...'
  # TODO: make this smarter to work with more window managers than i3.
  i3-msg exit
else
  printf '%s\n' 'Skipping logout.'
fi
