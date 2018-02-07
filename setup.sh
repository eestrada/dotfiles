#!/bin/sh

set -e

relpath()
{
    python3 -c "import os, sys; sys.stdout.write(os.path.relpath('${PWD}/${1}', '${HOME}'))";
    # echo 1>&2
}

linknew()
{
    # TODO: prompt for each call (defaulting to yes).
    test -e "${HOME}/${2}" && mv -vf "${HOME}/${2}" "${HOME}/${2}.prev"
    ln -vfs $(relpath ${1} ${2}) "${HOME}/${2}"
}

linknew  bash/bashrc.sh .bashrc
linknew  bash/bash_logout.sh .bash_logout
linknew  bash/bash_profile.sh .bash_profile
linknew  emacs.el .emacs
linknew  guile.scm .guile
linknew  racketrc.rkt .racketrc
linknew  vimrc.vim .vimrc
linknew  vim .vim
linknew  gitconfig.ini .gitconfig
linknew  hgrc.ini .hgrc
linknew  idlerc .idlerc
linknew  tmux.conf .tmux.conf
linknew  color-themes/base16-shell .base16-shell
linknew  Xdefaults .Xdefaults
linknew  xscreensaver .xscreensaver
linknew  i3status.conf .i3status.conf
