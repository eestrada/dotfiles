# .bash_profile
# vim: set filetype=bash:
# shellcheck shell=bash

# User specific environment and startup programs

PATH=$HOME/.local/bin:$HOME/bin:$PATH

export PATH

if [ -f "${HOME}/.profile" ]; then
  . "${HOME}/.profile"
fi

# Get the aliases and functions from .bashrc
if [ -f "${HOME}/.bashrc" ]; then
  . "${HOME}/.bashrc"
fi

[ -r "${HOME}/.dotfile_misc/macos/iterm2/shell_integration.bash" ] && . "${HOME}/.dotfile_misc/macos/iterm2/shell_integration.bash"
