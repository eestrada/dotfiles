# .zshrc
# vim: set syntax=sh:
# Emacs stuff
# Local Variables:
# mode: sh
# End:

emulate sh -c ". ${HOME}/.shrc"

# Originally sourced from: https://github.com/voku/dotfiles/blob/397e31eaa57b385bc761a4859d58a65c4f1eb6fd/.redpill/lib/1_options.zsh#L54


# ===== History
# Allow multiple terminal sessions to all append to one zsh command history
setopt APPEND_HISTORY
# Save each command’s beginning timestamp (in seconds since the epoch) and the duration (in seconds) to the history file
setopt EXTENDED_HISTORY
# Add commands as they are typed, don't wait until shell exit
setopt INC_APPEND_HISTORY
# If the internal history needs to be trimmed to add the current command line, setting this option will cause the oldest history event that has a duplicate to be lost before losing a unique event
setopt HIST_EXPIRE_DUPS_FIRST
# Do not enter command lines into the history list if they are duplicates of the previous event
setopt HIST_IGNORE_DUPS
# remove command lines from the history list when the first character on the line is a space
#setopt HIST_IGNORE_SPACE
# When searching history don't display results already cycled through twice
setopt HIST_FIND_NO_DUPS
# remove the history (fc -l) command from the history list when invoked
setopt HIST_NO_STORE
# remove superfluous blanks from each command line being added to the history list
setopt HIST_REDUCE_BLANKS
# whenever the user enters a line with history expansion, don’t execute the line directly
setopt HIST_VERIFY
# Allow command substitution in prompt string
setopt PROMPT_SUBST

# # The following lines were auto-generated by compinstall
#
# zstyle ':completion:*' completer _complete _ignored
# zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
# zstyle :compinstall filename '/Users/eestrada/.zshrc'
#
# # End of lines added by compinstall

# TODO: add color to prompt
# Custom terminal prompt
PS1='[%n@%m %~]'

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

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
export FPATH

# source local shell overrides and additions
source_files "${HOME}/.zshrc_local" "${HOME}/.zshrc_local.sh" "${HOME}/.zshrc-local.sh"

# This seems to work best when it is the last thing called.
autoload -Uz compinit && compinit

# This echos some parse errors to the terminal and might not be worth enabling.
autoload -Uz bashcompinit && bashcompinit && source_files "${HOME}/.bash_completion"
