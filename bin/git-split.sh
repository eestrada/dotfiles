#!/bin/sh

# script originally sourced from: https://stackoverflow.com/a/53849613/1733321

if [[ $# -ne 2 ]] ; then
  echo "Usage: git-split.sh original copy"
  exit 0
fi

git mv "$1" "$2"
git commit -n -m "Split history $1 to $2 - rename file to target-name"
REV=`git rev-parse HEAD`
git reset --hard HEAD^
git mv "$1" temp
git commit -n -m "Split history $1 to $2 - rename source-file to temp"
git merge $REV
git commit -a -n -m "Split history $1 to $2 - resolve conflict and keep both files"
git mv temp "$1"
git commit -n -m "Split history $1 to $2 - restore name of source-file"
