#!/usr/bin/env sh

PAGER=$(command -v most)
export PAGER

# prefer case-sensitive search
MOST_SWITCHES=-c
export MOST_SWITCHES

if command_exists vim; then
  MOST_EDITOR="${EDITOR} +%d %s"
  export MOST_EDITOR
fi
