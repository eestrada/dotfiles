#!/bin/sh
set -e

_default_repo='git@github.com:eestrada/dotfiles.git'
REPO_URL=${1:-${_default_repo}}
DIRECTORY=${2:-${HOME}}
unset _default_repo

# echo "${REPO_URL}"
# echo "${DIRECTORY}"

cd "${DIRECTORY}" || exit

# start as empty repo
git init

# git remote add --fetch --track=master origin git@github.com:eestrada/dotfiles.git
git remote add --fetch --track=master origin "${REPO_URL}"

# Force repo to think it is checked out to the same commit as the `origin` remote
cat .git/refs/remotes/origin/master >.git/refs/heads/master

# We haven't actually checked out, so we need to make the index reflect reality.
git restore --staged .

# "restore" the files that are safe to do so
# (i.e. files that git considers to be deleted from the working directory)
git ls-files -z --deleted | git restore --pathspec-file-nul '--pathspec-from-file=-'

# Clone submodules.
git submodule update --init --recursive

# add sourcing for global shell overrides and additions
for _LOCAL_SHELL_RC in ".bashrc" ".kshrc" ".mkshrc" ".shrc" ".zshrc" ".profile"; do
    printf '\n. "%s"\n' "\${HOME}/${_LOCAL_SHELL_RC}_global.sh" >>"${HOME}/${_LOCAL_SHELL_RC}"
done
unset _LOCAL_SHELL_RC

# add sourcing for global git config additions
# shellcheck disable=2088
git config --global --add include.path '~/.gitconfig-global.ini'

# shellcheck disable=2016
echo 'Running `git status` and `git diff` in your home directory should now work.'
echo 'Try it to see how much drift there is between your home dir and the repo.'
echo "Be careful with checking out files! You don't want to mess up your pre-existing configurations."
