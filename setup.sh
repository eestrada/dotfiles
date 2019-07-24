#!/bin/sh

set -e


relpath()
{
    _py_script=$(cat <<EOF
import os, sys

cwd = os.path.realpath('${PWD}')
arg1 = os.path.join(cwd, '${1}')
home = os.path.realpath('${HOME}')
relpath = os.path.relpath(arg1, home)
sys.stdout.write(relpath)
EOF
)
    echo "${_py_script}" | python3 -
}

joinpath()
{
    python3 -c "import os, sys; sys.stdout.write(os.path.join('${1}', '${2}'))";
}

linknew()
{
    # TODO: prompt for each call (defaulting to yes).
    test -e "${HOME}/${2}" && mv -vf "${HOME}/${2}" "${HOME}/${2}.prev"
    ln -vfs "$(relpath ${1} ${2})" "$(joinpath ${HOME} ${2})"
}

linknew  sh/shrc.sh .shrc
linknew  sh/shrc.sh .mkshrc
linknew  sh/shrc.sh .bashrc
linknew  sh/profile.sh .profile
linknew  sh/bash_logout.sh .bash_logout
linknew  sh/bash_profile.sh .bash_profile
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
linknew  xscreensaver .xscreensaver
linknew  i3/i3status.conf .i3status.conf
linknew  i3 .i3
linknew  xinitrc.sh .xinitrc
linknew  Xmodmap .Xmodmap
linknew  Xresources .Xresources
linknew  Xresources.d .Xresources.d
linknew  notestxtrc.sh .notestxtrc

# NOTE: nested folders under .config and similar
# linknew  dunst .config/dunst  # FIXME: won't work because we can't do symlinks to nested folders yet

# mkdir -p ~/.vdirsyncer
# linknew  vdirsyncer/config.ini ~/.vdirsyncer/config

