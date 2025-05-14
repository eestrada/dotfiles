# .profile - Bourne Shell startup script for login shells
# vim: set filetype=sh:
# shellcheck shell=sh
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

source_files() {
  for _file_path in "$@"; do
    if [ -f "${_file_path}" ]; then
      # shellcheck disable=SC1090 # Allow sourcing non-constant.
      . "${_file_path}"
    fi
  done
  _file_path=
}

# Source global definitions
source_files /etc/profile

# Set any custom variables

remove_duplicate_paths() {
  _arg_path="$1"
  # Remove duplicate entries
  IFS=':'
  old_PATH="${_arg_path}:"
  _arg_path=''
  while [ -n "$old_PATH" ]; do
    x=${old_PATH%%:*} # the first remaining entry
    case ${_arg_path}: in
    *:${x}:*) : ;;                # already there
    *) _arg_path=$_arg_path:$x ;; # not there yet
    esac
    old_PATH=${old_PATH#*:}
  done
  _arg_path=${_arg_path#:}
  printf '%s\n' "${_arg_path}"
  IFS=
  old_PATH=
  x=
  _arg_path=
}

refreshpath() {
  # must be calculated before the PATH is modified.
  _sysname="$(uname -s)"

  # Modify PATH now that env vars are set
  SYSPATH=${PATH}${SYSPATH+:$SYSPATH}

  # Vanilla path vars
  # Home dirs
  PATH=${HOME}/go/bin
  PATH=${PATH}:${HOME}/bin:${HOME}/sbin:${HOME}/games
  PATH=${PATH}:${HOME}/local/bin:${HOME}/local/sbin:${HOME}/local/games
  PATH=${PATH}:${HOME}/usr/bin:${HOME}/usr/sbin:${HOME}/usr/games
  PATH=${PATH}:${HOME}/usr/local/bin:${HOME}/usr/local/sbin:${HOME}/usr/local/games
  PATH=${PATH}:${HOME}/.usr/bin:${HOME}/.usr/sbin:${HOME}/.usr/games
  PATH=${PATH}:${HOME}/.usr/local/bin:${HOME}/.usr/local/sbin:${HOME}/.usr/local/games
  PATH=${PATH}:${HOME}/.local/bin:${HOME}/.local/sbin:${HOME}/.local/games

  if [ -n "$ANDROID_HOME" ]; then
    PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator
    PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
  fi

  # System dirs
  PATH=${PATH}:/usr/local/bin:/usr/local/sbin:/usr/local/games
  PATH=${PATH}:/usr/bin:/usr/sbin:/usr/games
  PATH=${PATH}:/bin:/sbin
  PATH=${PATH}:${SYSPATH}

  # Add dotfiles repo if possible
  if [ -e "${HOME}/.dotfile_misc/bin" ]; then
    PATH=${HOME}/.dotfile_misc/bin:${PATH}
  fi

  export PATH
  unset SYSPATH
}

set_manpath() {
  if [ -z "$MANPATH" ]; then
    oldman=$(manpath)
  else
    oldman=$MANPATH
  fi
  MANPATH="${HOME}/.usr/local/man:${HOME}/.local/man:${HOME}/local/man:${HOME}/man:${oldman}"
  MANPATH=$(remove_duplicate_paths "$MANPATH")
  export MANPATH
  unset oldman
}

# TODO: build and export environment variables for XDG_DATA_HOME,
# XDG_DATA_DIRS, and possibly other XDG related environment variables that
# matter to applications. See the guts of i3-dmenu-desktop for some more info
# on the subject.

custvars() {
  # Environment Variables to unset
  unset SSH_ASKPASS # Don't pop up gui password window for SSH

  # Environment variables to declare
  [ -z "${TEMP}" ] && export TEMP="/tmp"
  if which nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
  elif which vim >/dev/null 2>&1; then
    export EDITOR="vim"
  else
    export EDITOR="vi"
  fi

  if which nvim >/dev/null 2>&1; then
    export VISUAL="nvim"
  elif which vim >/dev/null 2>&1; then
    export VISUAL="vim"
  else
    export VISUAL=${EDITOR}
  fi

  export PAGER="less"
  export LESS='-IMRXF'
  GPG_TTY="$(tty)"
  export GPG_TTY

  # Used to set up ssh environment
  SSH_ENV="${HOME}/.ssh/environment"

  xdg_config_home_default="${HOME}/.config"
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$xdg_config_home_default}"
  unset xdg_config_home_default
}

_start_ssh_agent() {
  ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
  chmod 600 "${SSH_ENV}"
  # shellcheck disable=SC1090 # Allow sourcing non-constant.
  . "${SSH_ENV}" >/dev/null
}

_ps_all() {
  if [ "$(uname -s)" = "FreeBSD" ] || [ "$(uname -s)" = "Darwin" ]; then
    ps -avxw
  else
    ps -ef
  fi
}

_ssh_agent_isnt_running() {
  # shellcheck disable=SC2143 # Special grepping.
  if [ -z "${SSH_AGENT_PID}" ] || [ -z "$(_ps_all | grep "${SSH_AGENT_PID}" | grep -v grep | grep ssh-agent)" ]; then
    return 0
  else
    return 1
  fi
}

run_ssh_agent() {
  # check for running ssh-agent with proper $SSH_AGENT_PID
  if _ssh_agent_isnt_running; then
    # if ${SSH_AGENT_PID} is not properly set, we might be able to load one
    # from ${SSH_ENV} if it is set.
    if [ -f "${SSH_ENV}" ]; then
      # shellcheck disable=SC1090 # Allow sourcing non-constant.
      . "${SSH_ENV}" >/dev/null
    else
      # If we can't find SSH_ENV, we can probably assume that we have
      # never set up the environment on this machine before so lets add
      # some useful values to the ssh config.
      cat >>"${HOME}/.ssh/config" <<EOF
# .ssh/config
# vim: set filetype=sshconfig:
# Emacs stuff
# Local Variables:
# mode: sshconfig
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
      _start_ssh_agent
    fi

  fi
}

# Values for EDITOR and PAGER are just defaults since they should be overridden
# in the call to custvars further down in this init script.
export EDITOR="vi"
export PAGER="more"

export ENV="$HOME/.shrc"
for _shname in "zsh" "bash" "mksh" "ksh"; do
  if [ "$(basename "${SHELL}")" = "${_shname}" ]; then
    export ENV="${HOME}/.${_shname}rc"
    break
  fi
done
_shname=""

# set ANDROID_HOME
if [ -d "$HOME/dev/android-sdk" ]; then
  export ANDROID_HOME="$HOME/dev/android-sdk"
  export ANDROID_SDK_HOME="$HOME/dev/android-sdk"

  # Not sure if location below is the canonical place for AVDs to exist, but
  # that is where Android Studio dumped them on my current Linux desktop.
  export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
fi

# Use hardware acceleration for video decoding/encoding
# Place these values locally in `.profile` since they vary from machine to machine.
# export LIBVA_DRIVER_NAME=iHD
# export LIBVA_DRIVER_NAME=radeonsi
# export VDPAU_DRIVER=radeonsi

# This is the most de-facto portable way I have found so far to check if the
# shell we are in is interactive.
case $- in
*i*) _interactive_shell="1" ;;
*) ;;
esac

[ -n "${_interactive_shell}" ] && [ "$(uname -s)" = "FreeBSD" ] && [ -x /usr/bin/fortune ] && /usr/bin/fortune freebsd-tips && echo

refreshpath
set_manpath
custvars
run_ssh_agent

# Add homebrew variables
if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(arch)" = "i386" ]; then
    # For Apple running under Rosetta2 (i.e. 64-bit Intel CPU).
    export HOMEBREW_PREFIX='/usr/local/homebrew'
  else
    # For Native Apple Silicon CPUs.
    export HOMEBREW_PREFIX='/opt/homebrew'
  fi
elif [ "$(uname -s)" = "Linux" ]; then
  # For linux homebrew
  export HOMEBREW_PREFIX='/home/linuxbrew/.linuxbrew'
fi

[ -x "${HOMEBREW_PREFIX}/bin/brew" ] && eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"

# Must come after homebrew so that shim'd versions are always found first.
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="${ASDF_DATA_DIR}/shims:${PATH}"

# Run again after adding homebrew so that we can pick up nvim as the default editor.
custvars

# Remove duplicate paths at the very end.
PATH=$(remove_duplicate_paths "$PATH")
