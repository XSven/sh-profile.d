#!/usr/bin/env sh

# This script should be sourced but not executed. If you make it executable and
# run it, you may get an error like:
#
# bash return: can only `return' from a function or sourced script
#

${FORCE:-false} || [ ! -e "${HOME}/.rpmmacros" ] || return
unset FORCE

rm -f "${HOME}/.rpmmacros"

cat > "${HOME}/.rpmmacros" <<RPMMACROS
%_topdir        ${HOME}/rpmbuild
# alternative _topdir macro definition
# %_topdir        ${HOME}/src/packages

%_buildrootdir  %{_tmppath}
# alternative _buildrootdir macro definition
# %_buildrootdir  %{_topdir}/BUILDROOT

%buildroot      %{_buildrootdir}/%{name}-%{version}-%{release}.%{_arch}

%packager       ${FULL_NAME} <${EMAIL}>
RPMMACROS
