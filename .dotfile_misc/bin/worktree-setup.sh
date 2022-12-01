#!/bin/sh

# clone repo
mkdir -p "${HOME}/dev"
cd "${HOME}/dev"
git clone git@github.com:eestrada/dotfiles.git
cd dotfiles

# create a bogus work tree pointing to master branch because git won't allow us to
# create a worktree to an existing directory like our home directory. Lock it
# from the very beginning to prevent attempted moves or deletes.
git worktree add --lock --no-checkout --force "${HOME}/homedir-dotfiles" master

# point home dir to repo
cp -v "${HOME}/homedir-dotfiles/.git" "${HOME}/"

# point repo to home dir
echo "${HOME}/.git" > ".git/worktrees/homedir-dotfiles/gitdir"

# delete dummy work dir; it no longer serves any purpose
rm -rf "${HOME}/homedir-dotfiles"

# because we created the worktree without checking out, we need to fix its initial stage.
cd "${HOME}" || exit 1 && git restore --staged .
