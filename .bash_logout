# .bash_logout: executed by bash(1) when login shell exits.
# vim: set filetype=bash:
# shellcheck shell=bash
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
  [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
