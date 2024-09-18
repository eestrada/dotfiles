#!/bin/sh

# script originally sourced from: https://stackoverflow.com/a/53849613/1733321

if [ $# -ne 2 ] ; then
  echo "Usage: git-split.sh original copy"
  exit 2
fi

git_pwd="$(pwd)"

git mv "$1" "$2"
cd "$git_pwd" || exit
git commit -n -m "Split '$1' to '$2' - rename to target"
REV=$(git rev-parse HEAD)

git reset --hard HEAD^
cd "$git_pwd" || exit
git mv "$1" "${1}_temp"
cd "$git_pwd" || exit
git commit -n -m "Split '$1' to '$2' - rename to temp"

git merge "$REV"
git commit -a -n -m "Split '$1' to '$2' - keep both files"

git mv "${1}_temp" "$1"
cd "$git_pwd" || exit
git commit -n -m "Split '$1' to '$2' - restore source from temp"
