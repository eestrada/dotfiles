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

# TODO: add color to prompt
# Custom terminal prompt
PS1="[\u@\h \W]"

if [ -n "$TMUX" ]; then
    PS1="$PS1 \$(_tmux_print_status)"
fi

# Always add newline
PS1="$PS1"$'\n'

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

# source local shell overrides and additions
source_files "${HOME}/.bashrc_local" "${HOME}/.bashrc_local.sh" "${HOME}/.bashrc-local.sh"
