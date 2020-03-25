#!/bin/sh

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
    _chicken="Answer not 'y'. Chickening out of dealing with '%s'.\n"
    _target=$(joinpath "${HOME}" "${2}")
    _link_to=$(relpath "${1}" "${2}")
    printf "\nCreate symlink '~/%s' pointing to '%s'? [y/N] " "${2}" "${_link_to}"
    IFS= read confirm_link
    if [ "$confirm_link" = 'y' ] || [ "$confirm_link" = 'Y' ]; then
      if [ -e "${HOME}/${2}" ]; then
        printf "First rename existing file/folder '~/%s' to '~/%s.prev'? [y/N] " "${2}" "${2}"
        IFS= read confirm_mv
        if [ "$confirm_mv" = 'y' ] || [ "$confirm_mv" = 'Y' ]; then
          mv -vf "${HOME}/${2}" "${HOME}/${2}.prev"
        else
          printf "${_chicken}" "~/${2}.prev"
          return 1
        fi
      fi
      ln -vfs "$_link_to" "$_target"
    else
      printf "${_chicken}" "${2}"
      return 1
    fi
}

echo "Setting up configs general to all systems."
linknew  sh/shrc.sh .shrc
linknew  sh/shrc.sh .mkshrc
linknew  sh/shrc.sh .bashrc
linknew  sh/shrc.sh .zshrc
linknew  sh/profile.sh .profile
linknew  sh/profile.sh .zprofile
linknew  sh/zlogin.sh .zlogin
linknew  sh/zlogout.sh .zlogout
linknew  sh/bash_logout.sh .bash_logout
linknew  sh/bash_profile.sh .bash_profile
linknew  emacs.el .emacs
linknew  guile.scm .guile
linknew  racketrc.rkt .racketrc
linknew  vimrc.vim .vimrc
linknew  vim .vim
linknew  gitconfig.ini .gitconfig
linknew  hgrc.ini .hgrc
linknew  tmux.conf .tmux.conf
linknew  color-themes/base16-shell .base16-shell
linknew  notestxtrc.sh .notestxtrc

if [ $(uname -s) = "Darwin" ]; then
  echo "\nSetting up macOS/Darwin specific configs:"
  linknew  macOS/hammerspoon .hammerspoon
elif [ $(uname -s) = "FreeBSD" ] || [ $(uname -s) = "Linux" ]; then
  echo "\nSetting up configs general to both FreeBSD and Linux:"
  linknew  xscreensaver .xscreensaver
  linknew  i3/i3status.conf .i3status.conf
  linknew  i3 .i3
  linknew  xinitrc.sh .xinitrc
  linknew  Xmodmap .Xmodmap
  linknew  Xresources .Xresources
  linknew  Xresources.d .Xresources.d

  # NOTE: nested folders under .config and similar
  # linknew  dunst .config/dunst  # FIXME: won't work because we can't do symlinks from nested folders yet

  # mkdir -p ~/.vdirsyncer
  # linknew  vdirsyncer/config.ini ~/.vdirsyncer/config

  if [ $(uname -s) = "FreeBSD" ]; then
    echo "\nSetting up configs specific to FreeBSD:"
  elif [ $(uname -s) = "Linux" ]; then
    echo "\nSetting up configs specific to Linux:"
  fi
else
  echo "\nNot on a system we recognize as needing special configs: $(uname -s)"
fi
