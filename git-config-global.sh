#!/usr/bin/env sh
# This script should be sourced but not executed. If you make it executable and
# run it, you may get an error like:
#
# bash return: can only `return' from a function or sourced script
#

${FORCE:-false} || [ ! -e "${HOME}/.gitconfig" ] || return
unset FORCE

rm -f "${HOME}/.gitconfig"

git config --global user.name  "${FULL_NAME}"
git config --global user.email "${EMAIL}"

git config --global alias.ad add
git config --global alias.br branch
git config --global alias.brl 'branch --list --all'
git config --global alias.cf config
git config --global alias.cfg 'config --get --show-scope --show-origin'
git config --global alias.cfl 'config --list'
git config --global alias.ci commit
git config --global alias.cia 'commit --all'
git config --global alias.cl clone
git config --global alias.co checkout
git config --global alias.dfl 'diff --name-status'
git config --global alias.ex archive
git config --global alias.lg "log --pretty=format:'%h - %ci %d %s (%an <%ae>)' --abbrev-commit"
git config --global alias.lgg '!git lg --color --graph'
git config --global alias.lgh '!git lg -10'
git config --global alias.ls 'ls-tree -r --name-only'
git config --global alias.st status
git config --global alias.stn 'status --untracked-files=no'
git config --global alias.stash-unapply '!git stash show --patch | git apply --reverse'
# Available since git 2.1
git config --global tag.sort -version:refname
git config --global alias.tg tag
# List all tags together with their first annotation line
git config --global alias.tgl 'tag -n --sort=-creatordate'

operatingSystem=$(uname -s | tr '[:lower:]' '[:upper:]')
# core.autocrlf defaults to false
case ${operatingSystem} in
  AIX )      git config --global core.autocrlf false;;
  LINUX )    git config --global core.autocrlf false;;
  MINGW64* ) git config --global core.autocrlf input;;
esac
unset operatingSystem

touch ~/.gitmessage.txt
git config --global commit.template ~/.gitmessage.txt

git config --global core.editor vim
git config --global core.pager less

git config --global push.default simple
git config --global push.recurseSubmodules check

# Available since git 2.28
# Don't use "development"; for prototype developments its sufficient to have a
# "master" branch
git config --global init.defaultBranch master
