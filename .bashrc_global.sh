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
PS1="${PS1}\$(_tmux_print_status)"
PS1="${PS1}\$(_git_print_branch)"

# Always add newline
PS1="$PS1"$'\n'

# Trailing character of PS1 determined on whether we are currently root or not
case `id -u` in
    0) PS1="${PS1}# ";;
    *) PS1="${PS1}$ ";;
esac

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"

[ -f ~/.config/fzf/setup.bash ] && source ~/.config/fzf/setup.bash

source_files "${HOME}/.bash_completion"

# source local shell overrides and additions
source_files "${HOME}/.bashrc_local" "${HOME}/.bashrc_local.sh" "${HOME}/.bashrc-local.sh"
