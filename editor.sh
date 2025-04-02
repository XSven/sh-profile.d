#!/usr/bin/env sh

set -o vi

# The -e option of the crontab command is used to edit the current crontab
# using the editor specified by the VISUAL or EDITOR environment variables.

# Git commands such as commit and tag launch an editor to let you edit
# messages. The order of preference is the GIT_EDITOR environment variable,
# then core.editor configuration, then VISUAL, then EDITOR, and then the
# default chosen at compile time, which is usually vi.

# The acledit command lets you change the access control information of a
# given file with the editor specified by the EDITOR environment variable.
# The EDITOR environment variable must be specified with a complete path
# name; otherwise, the acledit command will fail.

if command_exists vim; then
  EDITOR=$(command -v vim)
  export EDITOR
  # examples:
  # vimh tags        # get help about the "tags" command
  # vimh "'tags'"    # get help about the "tags" option
  # vimh "^o"        # get help about the "CTRL-o" command
  vimh() {
    vim +":h $1 | on"
  }
fi

