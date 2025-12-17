#!/bin/sh

_do_reboot () {
  printf '%s\n' 'Exit window manager...'
  i3-msg exit

  printf '%s\n' 'Waiting for Xserver to fully exit...'
  # See: https://unix.stackexchange.com/a/338862
  while xhost 2>/dev/null 1>/dev/null; do sleep 1; done

  printf '%s\n' 'Rebooting...'
  sudo reboot
}

if [ "$1" = '--ask' ]; then
  if zenity --question --title 'Reboot?' --text 'Reboot?' ; then
    _do_reboot
  else
    printf '%s\n' 'Skipping reboot.'
  fi
else
  _do_reboot
fi
