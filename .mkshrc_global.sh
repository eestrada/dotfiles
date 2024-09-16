# .mkshrc
# vim: set filetype=sh.ksh.mksh:
# shellcheck shell=ksh
# Emacs stuff
# Local Variables:
# mode: sh
# End:

. "${HOME}/.shrc"

# Custom terminal prompt
PS1='[$(echo -n "`logname`@`hostname`: " ; if [ "${PWD}" -ef "${HOME}" ] ; then echo -n "~" ; else echo -n "$(basename ${PWD})" ; fi ; echo "]")'
export HISTFILE="$HOME/.mksh_history" && export HISTSIZE="32767"

# Trailing character of PS1 determined on whether we are currently root or not
case $(id -u) in
    0) PS1="${PS1}# " ;;
    *) PS1="${PS1}$ " ;;
esac
