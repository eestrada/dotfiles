#!/bin/sh

function relpath()
{
    python -c "import os, sys; sys.stdout.write(os.path.relpath('${PWD}/${1}', '${HOME}'))";
    # echo 1>&2
}

function linknew()
{
    # TODO: prompt for each call (defaulting to yes).
    mv -vf "${HOME}/${2}" "${HOME}/${2}.prev"
    ln -vfs $(relpath ${1}) "${HOME}/${2}"
}

linknew  bash/bashrc.sh .bashrc
linknew  bash/bash_logout.sh .bash_logout
linknew  bash/bash_profile.sh .bash_profile
linknew  emacs.el .emacs
linknew  guile.scm .guile
linknew  racketrc.rkt .racketrc
linknew  vimrc.vim .vimrc
linknew  gitconfig.ini .gitconfig
linknew  hgrc.ini .hgrc
linknew  idlerc .idlerc