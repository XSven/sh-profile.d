#!/usr/bin/env sh

# https://specifications.freedesktop.org/basedir-spec/latest/
# https://wiki.archlinux.org/title/XDG_Base_Directory

XDG_CONFIG_HOME=${HOME}/.config
export XDG_CONFIG_HOME

XDG_DATA_HOME=${HOME}/.local/share
export XDG_DATA_HOME
