#!/usr/bin/env sh

# $Format:%D, %h$

# shellcheck disable=SC1090,SC1091

. ~/profile.d/XDG_base_directory_defaults.sh

. ~/profile.d/setup-functions.sh

. ~/profile.d/editor.sh
# do not change the order: editor.sh should be sourced before most.sh
if command_exists most; then
  . ~/profile.d/most.sh
  . ~/profile.d/most-init-user.sh
fi

if command_exists gpg; then
  . ~/profile.d/gpg.sh
  if command_exists pass; then
    . ~/profile.d/pass.sh
  fi
fi

#if [ "$(get_os_name)" = aix ]; then
#  # /usr/lib/rpm/rpmdeps invalid range expression
#  # https://community.ibm.com/community/user/power/discussion/usrlibrpmrpmdeps-invalid-range-expression
#  # legacy locale
#  LANG=EN_US.UTF-8 # has issues when building rpms
#else
#  # CLDR sourced locale
#  LANG=en_US.UTF-8
#fi

# /etc/environment
# PATH=/usr/bin:/etc:/usr/sbin:/usr/local/bin:/opt/freeware/bin:/opt/freeware/sbin:/usr/ucb:/usr/bin/X11:/sbin

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if command_exists rpm; then
  . ~/profile.d/rpmmacros.sh
fi

if command_exists cvs; then
  . ~/profile.d/cvs.sh
fi

if command_exists git; then
  . ~/profile.d/git-config-global.sh
  . ~/profile.d/git-functions.sh
  PS1='${SHELL##*/}:$(get_coloured_exit_status $?):$(get_coloured_git_branch)://${LOGNAME}@${HOSTNAME}/$(tildize "${PWD}")/
$'
fi

if command_exists perl; then
  . ~/profile.d/perl.sh
fi

if command_exists go; then
  . ~/profile.d/go.sh
fi

if command_exists psql; then
  . ~/profile.d/pg.sh
fi

if command_exists podman; then
  . ~/profile.d/podman.sh
fi

. ~/profile.d/nexus.sh

if [ -f ~/customizations.sh ]; then
  . ~/customizations.sh
fi

mkdir -p ~/bin
PATH=~/bin:${PATH}

PATH=$(clean_path "${PATH}")
