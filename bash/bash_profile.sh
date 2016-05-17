# .bash_profile

# Emacs stuff
# Local Variables:
# mode: sh
# End:

# Get the aliases and functions from .bashrc
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
