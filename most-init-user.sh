#!/usr/bin/env sh
# This script should be sourced but not executed. If you make it executable and
# run it, you may get an error like:
#
# bash return: can only `return' from a function or sourced script
#

${FORCE:-false} || [ ! -e "${HOME}/.mostrc" ] || return
unset FORCE

rm -f "${HOME}/.mostrc"

cat > "${HOME}/.mostrc" <<DOT_MOSTRC
% most function overview
% /usr/share/doc/most/most-fun.txt

% Movement:
% "H" (upper case) still refers to the "help" function
setkey column_left "h"
% "J" (upper case) still refers to the "goto_line" function
setkey down "j"
setkey up "k"
setkey column_right "l"
setkey page_down "^f"
setkey page_up "^b"
% "bob" (begin of file) function
setkey bob "gg"
% "eob" (end of file) function
setkey eob "G"
DOT_MOSTRC
