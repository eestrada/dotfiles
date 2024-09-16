# .kshrc
# vim: set filetype=sh.ksh:
# shellcheck shell=ksh
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# Source global definitions
if [ -f /etc/kshrc ]; then
    . /etc/kshrc
fi

# Source general shrc definitions
. "${HOME}/.shrc"

# User specific aliases and functions
