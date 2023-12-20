#!/bin/sh

# clone repo
mkdir -p "${HOME}/dev"
cd "${HOME}/dev"
# git clone --no-checkout git@github.com:eestrada/dotfiles.git dotfiles_git
git clone --no-checkout https://github.com/eestrada/dotfiles.git dotfiles_git
cd dotfiles_git

# Switch to a dummy branch so that we don't conflict with the worktree on master
git switch -c local_dummy_branch

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

# "restore" the files that are safe to do so (i.e. files that don't already exist)
git restore $(git ls-files --deleted)

# Clone submodules.
git submodule update --init --recursive

# add sourcing for global shell overrides and additions
for _LOCAL_SHELL_RC in ".bashrc" ".kshrc" ".mkshrc" ".shrc" ".zshrc" ".profile"
do
    printf '\n. "%s"\n' "\${HOME}/${_LOCAL_SHELL_RC}_global.sh" >> "${HOME}/${_LOCAL_SHELL_RC}"
done
unset _LOCAL_SHELL_RC

# add sourcing for global git config additions
git config --global --add include.path '~/.gitconfig-global.ini'

echo 'Running `git status` in your home directory should now work.'
echo 'Try it to see how much drift there is between your home dir and the repo.'
echo "Be careful with checking out files! You don't want to mess up your pre-existing configurations."
