#!/bin/sh

# Simple script to clone a git repo
# into a directory with pre-existing files in it.
# Primarily meant for bootstrapping dotfiles into the home directory;
# all default values of arguments reflect this purpose.
#
# This script does not overwrite existing files.
# If you want to overwrite existing files
# without first diffing them against the state of the repo,
# all you need to run is: `git restore .` or `git checkout .`
# after running this script.
set -e

_default_repo='git@github.com:eestrada/dotfiles.git'
_default_branch='master'
_default_dir="${HOME}"
REPO_URL=${1:-${_default_repo}}
BRANCH=${2:-${_default_branch}}
DIRECTORY=${3:-${_default_dir}}
unset _default_repo
unset _default_branch
unset _default_dir

cd "${DIRECTORY}" || exit

# start as empty repo
git init

# set up remote, but don't check it out
git remote add --fetch "--track=${BRANCH}" origin "${REPO_URL}"

# Force repo to think it is checked out to the same commit as the `origin` remote
cat ".git/refs/remotes/origin/${BRANCH}" >".git/refs/heads/${BRANCH}"

# track upstream
git branch "--set-upstream-to=origin/${BRANCH}"

# We haven't *actually* checked out,
# so we need to make the index reflect reality.
git restore --staged .

# "restore" the files that are safe to do so
# (i.e. files that git considers to be deleted from the working directory)
if [ -n "$(git ls-files --deleted)" ]; then
    git ls-files -z --deleted | git restore --pathspec-file-nul '--pathspec-from-file=-'
fi

# Clone submodules.
git submodule update --init --recursive

if [ "${DIRECTORY}" = "${HOME}" ]; then
    # add sourcing for global shell overrides and additions
    for _LOCAL_SHELL_RC in ".bashrc" ".kshrc" ".mkshrc" ".shrc" ".zshrc" ".profile"; do
        printf '\n. "%s"\n' "\${HOME}/${_LOCAL_SHELL_RC}_global.sh" >>"${HOME}/${_LOCAL_SHELL_RC}"
    done
    unset _LOCAL_SHELL_RC

    # add sourcing for global git config additions
    # shellcheck disable=2088
    git config --global --add include.path '~/.gitconfig-global.ini'
fi

# shellcheck disable=2016
echo 'Running `git status` and `git diff` in your home directory should now work.'
echo 'Try it to see how much drift there is between your home dir and the repo.'
echo "Be careful with checking out files! You don't want to mess up your pre-existing configurations."
