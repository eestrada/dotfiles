# .profile - Bourne Shell startup script for login shells
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:
#
# see also sh(1), environ(7).
#

# These are normally set through /etc/login.conf.  You may override them here
# if wanted.
# PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin; export PATH
# BLOCKSIZE=K;  export BLOCKSIZE

# Setting TERM is normally done through /etc/ttys.  Do only override
# if you're sure that you'll never log in via telnet or xterm or a
# serial line.
# TERM=xterm;   export TERM

source_files ()
{
  for fpath in "$@"; do
    if [ -f "${fpath}" ]; then
        . "${fpath}"
    fi
  done
  fpath=;
}

# Source global definitions
source_files /etc/profile

# Set any custom variables

remove_duplicate_paths ()
{
  _arg_path="$1"
  # Remove duplicate entries
  IFS=:
  old_PATH=$_arg_path:; _arg_path=
  while [ -n "$old_PATH" ]; do
    x=${old_PATH%%:*}       # the first remaining entry
    case ${_arg_path}: in
      *:${x}:*) :;;         # already there
      *) _arg_path=$_arg_path:$x;;    # not there yet
    esac
    old_PATH=${old_PATH#*:}
  done
  _arg_path=${_arg_path#:}
  printf '%s\n' "${_arg_path}"
  IFS= ; old_PATH= ; x= ; _arg_path= ;
}

refreshpath ()
{

    # must be calculated before the PATH is modified.
    _sysname="$(uname -s)"

    # Modify PATH now that env vars are set
    SYSPATH=${PATH}:${SYSPATH}

    # Vanilla path vars
    PATH=${HOME}/go/bin;
    PATH=${PATH}:${HOME}/.rbenv/bin:${HOME}/bin:${HOME}/sbin:${HOME}/games;
    PATH=${PATH}:${HOME}/local/bin:${HOME}/local/sbin:${HOME}/local/games;
    PATH=${PATH}:${HOME}/usr/bin:${HOME}/usr/sbin:${HOME}/usr/games;
    PATH=${PATH}:${HOME}/usr/local/bin:${HOME}/usr/local/sbin:${HOME}/usr/local/games;
    PATH=${PATH}:${HOME}/.usr/bin:${HOME}/.usr/sbin:${HOME}/.usr/games;
    PATH=${PATH}:${HOME}/.usr/local/bin:${HOME}/.usr/local/sbin:${HOME}/.usr/local/games;
    PATH=${PATH}:${HOME}/.local/bin:${HOME}/.local/sbin:${HOME}/.local/games;

    if [ "${_sysname}" = "Darwin" ] ; then
      # path for Apple Silicon CPUs. 64-bit Intel CPUs have homebrew installed elsewhere.
      PATH=${PATH}:/opt/homebrew/bin;
    fi
    _sysname=""


    PATH=${PATH}:/usr/local/bin:/usr/local/sbin:/usr/local/games;
    PATH=${PATH}:/usr/bin:/usr/sbin:/usr/games;
    PATH=${PATH}:/bin:/sbin;
    PATH=${PATH}:${SYSPATH}

    # dotfiles repo is *usually* in root of home directory
    if [ -e "${HOME}/dotfiles/bin" ]; then
      PATH=${HOME}/dotfiles/bin:${PATH}
    fi

    PATH=$(remove_duplicate_paths "$PATH")
    export PATH;
}

set_manpath ()
{
    if [ -z $MANPATH ]; then
        oldman=$(manpath)
    else
        oldman=$MANPATH
    fi
    MANPATH="${HOME}/.usr/local/man:${HOME}/.local/man:${HOME}/local/man:${HOME}/man:${oldman}";
    MANPATH=$(remove_duplicate_paths "$MANPATH")
    export MANPATH;
    unset oldman;
}

# TODO: build and export environment variables for XDG_DATA_HOME,
# XDG_DATA_DIRS, and possibly other XDG related environment variables that
# matter to applications. See the guts of i3-dmenu-desktop for some more info
# on the subject.

custvars ()
{
    # Environment Variables to unset
    unset SSH_ASKPASS; # Don't pop up gui password window for SSH

    # Environment variables to declare
    export TEMP="/tmp";
    if $(which vim >/dev/null 2>&1);
    then
        export EDITOR="vim";
    else
        export EDITOR="vi";
    fi

    if $(which vim >/dev/null 2>&1);
    then
        export VISUAL="vim";
    else
        export VISUAL=${EDITOR};
    fi

    export PAGER="less";
    export LESS='-IMRXF';
    export GPG_TTY="$(tty)";

    SSH_ENV="${HOME}/.ssh/environment";    # Used to set up ssh environment
}

add_all_keys ()
{
    # Add default key
    ssh-add -q >/dev/null 2>&1;
    # Add any private keys that have corresponding public keys
    cd "${HOME}";
    ssh-add -q $(ls .ssh/ | awk '/\.pub$/' | sed 's/^\(.*\)\.pub/.ssh\/\1/') >/dev/null 2>&1;
    cd - >/dev/null 2>&1;
}


# start the ssh-agent
start_agent ()
{
    # echo "Initializing new SSH agent..." 1>&2;
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}";
    # echo "succeeded" 1>&2;
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null;
    add_all_keys
}

# test for identities
test_identities ()
{
    # test whether standard identities have been added to the agent already
    ssh-add -l | grep "The agent has no identities" > /dev/null;
    if [ $? -eq 0 ]; then
        ssh-add -q
        # ${SSH_AUTH_SOCK} broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

_ps_all ()
{
    if [ $(uname -s) = "FreeBSD" ] || [ $(uname -s) = "Darwin" ]; then
        ps -avxw;
    else
        ps -ef;
    fi
}

run_ssh ()
{
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if [ -n "${SSH_AGENT_PID}" ]; then
        _ps_all | grep "${SSH_AGENT_PID}" | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
            test_identities;
        fi
    # if ${SSH_AGENT_PID} is not properly set, we might be able to load one from
    # ${SSH_ENV}
    else
        if [ -f "${SSH_ENV}" ]; then
            . "${SSH_ENV}" > /dev/null;
        fi

        _ps_all | grep "${SSH_AGENT_PID}" | grep -v grep | grep ssh-agent > /dev/null;
        if [ $? -eq 0 ]; then
            test_identities;
        else
            start_agent;
        fi
    fi
}

# Values for EDITOR and PAGER are just defaults since they should be overridden
# in the call to custvars futher down in this init script.
export EDITOR="vi";
export PAGER="more";

export ENV="$HOME/.shrc";
for _shname in "zsh" "bash" "mksh" "ksh"; do
  if [ "$(basename ${SHELL})" = "${_shname}" ]; then
    export ENV="${HOME}/.${_shname}rc";
    break;
  fi
done
_shname=


# Use hardware acceleration for video decoding/encoding
export LIBVA_DRIVER_NAME=iHD

# This is the most de-facto portable way I have found so far to check if the
# shell we are in is interactive.
case $- in
  *i*) _interactive_shell="1";;
  *) ;;
esac

[ -n ${_interactive_shell} ] && [ $(uname -s) = "FreeBSD" ] && [ -x /usr/bin/fortune ] && /usr/bin/fortune freebsd-tips && echo

refreshpath
set_manpath
custvars
run_ssh

source_files "${HOME}/.profile_local.sh" "${HOME}/.profile-local.sh" "${HOME}/.profile_local"

type rbenv >/dev/null && [ -z "${RBENV_SHELL}" ] && eval "$(rbenv init - $(basename "${SHELL}"))"
