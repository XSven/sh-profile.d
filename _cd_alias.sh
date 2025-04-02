#!/bin/sh

_cd () {
  if "cd" "$@"; then
    PATH=$(clean_path -q "${PATH}")
    # do the following only if $PWD refers to a perl project
    for _ in local/bin blib/script blib/bin; do
      # on purpose do not check if ${PWD}/$_ is an existing directory or not
      PATH=${PWD}/$_:${PATH}
    done
  fi
}

# alias cd=_cd
#
# This doesn't help much because perl programs that are found in the PATH are
# missing their library portion. That's why we need something like
# App::runscript
