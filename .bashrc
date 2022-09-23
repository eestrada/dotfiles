# .bashrc
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:

# Source global bashrc definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source general shrc definitions
. "${HOME}/.shrc"

# Custom terminal prompt
PS1="[\u@\h \W]"

# Trailing character of PS1 determined on whether we are currently root or not
case `id -u` in
    0) PS1="${PS1}# ";;
    *) PS1="${PS1}$ ";;
esac

# update PATH for the Google Cloud SDK.
source_files "${HOME}/google-cloud-sdk/path.bash.inc"

# Use bash-completion
source_files  /usr/local/share/bash-completion/bash_completion \
              /usr/local/etc/profile.d/bash_completion.sh \
              "${HOME}/google-cloud-sdk/completion.bash.inc";
