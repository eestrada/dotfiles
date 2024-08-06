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
  for _file_path in "$@"; do
    if [ -f "${_file_path}" ]; then
        . "${_file_path}"
    fi
  done
  _file_path=;
}

# Source global definitions
source_files /etc/profile

# Set any custom variables

remove_duplicate_paths ()
{
  _arg_path="$1"
  # Remove duplicate entries
  IFS=':'
  old_PATH="${_arg_path}:"
  _arg_path=''
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
    SYSPATH=${PATH}${SYSPATH+:$SYSPATH}

    # Vanilla path vars
    PATH=${HOME}/go/bin;
    PATH=${PATH}:${HOME}/.rbenv/bin:${HOME}/bin:${HOME}/sbin:${HOME}/games;
    PATH=${PATH}:${HOME}/local/bin:${HOME}/local/sbin:${HOME}/local/games;
    PATH=${PATH}:${HOME}/usr/bin:${HOME}/usr/sbin:${HOME}/usr/games;
    PATH=${PATH}:${HOME}/usr/local/bin:${HOME}/usr/local/sbin:${HOME}/usr/local/games;
    PATH=${PATH}:${HOME}/.usr/bin:${HOME}/.usr/sbin:${HOME}/.usr/games;
    PATH=${PATH}:${HOME}/.usr/local/bin:${HOME}/.usr/local/sbin:${HOME}/.usr/local/games;
    PATH=${PATH}:${HOME}/.local/bin:${HOME}/.local/sbin:${HOME}/.local/games;

    # Add linux homebrew after home directories, but before system directories.
    PATH=${PATH}:/home/linuxbrew/.linuxbrew/bin;

    PATH=${PATH}:/usr/local/bin:/usr/local/sbin:/usr/local/games;
    PATH=${PATH}:/usr/bin:/usr/sbin:/usr/games;
    PATH=${PATH}:/bin:/sbin;
    PATH=${PATH}:${SYSPATH}

    # Add dotfiles repo if possible
    if [ -e "${HOME}/dev/dotfiles/.dotfile_misc/bin" ]; then
      PATH=${HOME}/dev/dotfiles/.dotfile_misc/bin:${PATH}
    fi

    PATH=$(remove_duplicate_paths "$PATH")
    export PATH;
    unset SYSPATH;
}

set_manpath ()
{
    if [ -z "$MANPATH" ]; then
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
    [ -z "${TEMP}" ] && export TEMP="/tmp";
    if $(which nvim >/dev/null 2>&1);
    then
        export EDITOR="nvim";
    elif $(which vim >/dev/null 2>&1);
    then
        export EDITOR="vim";
    else
        export EDITOR="vi";
    fi

    if $(which nvim >/dev/null 2>&1);
    then
        export VISUAL="nvim";
    elif $(which vim >/dev/null 2>&1);
    then
        export VISUAL="vim";
    else
        export VISUAL=${EDITOR};
    fi

    export PAGER="less";
    export LESS='-IMRXF';
    export GPG_TTY="$(tty)";

    # Used to set up ssh environment
    SSH_ENV="${HOME}/.ssh/environment";

    xdg_config_home_default="${HOME}/.config"
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$xdg_config_home_default}"
    unset xdg_config_home_default
}

_start_ssh_agent ()
{
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}";
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null;
}

_ps_all ()
{
    if [ $(uname -s) = "FreeBSD" ] || [ $(uname -s) = "Darwin" ]; then
        ps -avxw;
    else
        ps -ef;
    fi
}

_ssh_agent_isnt_running ()
{
    if [ -z "${SSH_AGENT_PID}" ] || [ -z "$(_ps_all | grep "${SSH_AGENT_PID}" | grep -v grep | grep ssh-agent)" ]; then
      return 0
    else
      return 1
    fi
}

run_ssh_agent ()
{
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if _ssh_agent_isnt_running; then
        # if ${SSH_AGENT_PID} is not properly set, we might be able to load one
        # from ${SSH_ENV} if it is set.
        if [ -f "${SSH_ENV}" ]; then
            . "${SSH_ENV}" > /dev/null;
        else
            # If we can't find SSH_ENV, we can probably assume that we have
            # never set up the environment on this machine before so lets add
            # some useful values to the ssh config.
            cat >> "${HOME}/.ssh/config" << EOF
# .ssh/config
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# We don't need to directly add ssh keys in our ~/.profile anymore. This can all
# be done here in the ssh config.

# The config below will automatically decrypt keyfiles using credentials stored
# in the Apple Keychain and will add key files to the agent on demand.
# Config ideas sourced from these stackexchange questions:
# * https://apple.stackexchange.com/a/250572/365333
# * https://unix.stackexchange.com/q/269121/28898

Host *
	# UseKeychain yes
	AddKeysToAgent yes
EOF
        fi

        # if there was no SSH_ENV to source or the SSH_ENV is stale/incorrect,
        # then start the ssh agent and set a fresh SSH_ENV
        if _ssh_agent_isnt_running; then
            _start_ssh_agent;
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
_shname=""


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
run_ssh_agent

# Add homebrew variables for Apple Silicon CPUs. 64-bit Intel CPUs have homebrew
# installed elsewhere.
[ -x "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Run again after adding homebrew so that we can pick up nvim as the defaul editor.
custvars

type rbenv >/dev/null 2>&1 && [ -z "${RBENV_SHELL}" ] && eval "$(rbenv init - $(basename "${SHELL}"))"
