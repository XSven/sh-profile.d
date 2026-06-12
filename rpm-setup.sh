#!/usr/bin/env sh

# This script should be sourced but not executed. If you make it executable and
# run it, you may get an error like:
#
# bash return: can only `return' from a function or sourced script
#

${FORCE:-false} || [ ! -e "${HOME}/.rpmmacros" ] || return
unset FORCE

# https://wiki.centos.org/HowTos/SetupRpmBuildEnvironment

rm -f "${HOME}/.rpmmacros"

# Alternative _topdir macro definition:
# %_topdir        ${HOME}/src/packages
# Alternative _buildrootdir macro definition:
# %_buildrootdir  %{_topdir}/BUILDROOT
# %__perl         /opt/perl5/perlbrew/perls/perl-5.38.3/bin/perl
cat > "${HOME}/.rpmmacros" <<RPMMACROS
%_buildrootdir  %{_tmppath}
%_dbpath        %{getenv:HOME}/rpmdb
%_topdir        ${HOME}/rpmbuild
%buildroot      %{_buildrootdir}/%{name}-%{version}-%{release}.%{_arch}
%packager       ${FULL_NAME} <${EMAIL}>
RPMMACROS

# On purpose the _topdir directory will not be deleted automatically because it
# might contain valuable, unsaved files.
_topdir=$(rpm --eval '%{_topdir}')
if [ ! -d "${_topdir}" ]; then
  mkdir -p "${_topdir}"
  ( cd "${_topdir}" && mkdir SOURCES SPECS BUILD SRPMS RPMS )
fi
unset _topdir
