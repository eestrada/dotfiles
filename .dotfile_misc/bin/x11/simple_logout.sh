#!/bin/sh

_do_logout () {
  printf '%s\n' 'Logging out...'
  # TODO: make this smarter to work with more window managers than i3.
  i3-msg exit
}

if [ "$1" = '--ask' ]; then
  if zenity --question --title 'Logout?' --text 'Logout?' ; then
    _do_logout
  else
    printf '%s\n' 'Skipping logout.'
  fi
else
  _do_logout
fi
