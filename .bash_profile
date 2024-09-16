# .bash_profile
# shellcheck shell=bash
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# User specific environment and startup programs

PATH=$HOME/.local/bin:$HOME/bin:$PATH

export PATH

if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Get the aliases and functions from .bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

[ -r "${HOME}/.dotfile_misc/macos/iterm2/shell_integration.bash" ] && . "${HOME}/.dotfile_misc/macos/iterm2/shell_integration.bash"
