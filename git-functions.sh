#!/usr/bin/env sh

github_archive() (
  func_name=github_archive

  set -o nounset

  extract=false
  while getopts :hp:t:x option; do
    case ${option} in
       h) printf 'Usage: %s %s\n       %s %s\n' "${func_name}" '[ -h ]' "${func_name}" '[ -x [ -t <target> | -p <path> ] | -t <target> ] <owner> <repository> <treeIsh>'
          return 0;;
       x) extract=true;;
       p) path=${OPTARG};;
       t) target=${OPTARG};;
      \?) shift $(( OPTIND - 2 ))
          printf '%s: %s: %s\n' "${func_name}" "$1" 'Invalid option.' 1>&2
          return 2;;
     esac
  done
  shift $(( OPTIND - 1 ))

  if [ $# -ne 3 ]; then
    printf '%s: %d: Wrong number of arguments.\n' "${func_name}" $# 1>&2
    return 2
  fi
  owner=$1
  repository=$2
  treeIsh=$3

  api_endpoint=https://api.github.com/repos/${owner}/${repository}/tarball/${treeIsh}
  target=${target:-${repository}}
  if ${extract}; then
    if [ -n "${path:-}" ]; then
      wget -q -O - "${api_endpoint}" | tar --wildcards --strip-components=1 -xzf - "${path}"
    else
      wget -q -O - "${api_endpoint}" | tar --strip-components=1 --one-top-level="${target}" -xzf -
    fi
  else
    wget -q -O "${target}".tgz "${api_endpoint}"
  fi
)

archive_this_git_repository() (
  func_name=archive_this_git_repository

  # POSIX compatibility verified with ShellCheck version 0.8.0

  set -o nounset

  remote_name=origin
  target_directory=${PWD}
  while getopts :hr:t: option; do
    case ${option} in
       h) printf 'Usage: %s %s\n       %s %s\n' "${func_name}" '[ -h ]' "${func_name}" '[ -r <remote name> ] [ -t <target directory> ] [ <treeIsh> ]'
          return 0;;
       r) remote_name=${OPTARG};;
       t) target_directory=${OPTARG}
          if [ ! -d "${target_directory}" ]; then
          printf '%s: %s: %s\n' "${func_name}" "${target_directory}" 'Target directory does not exist.' 1>&2
            return 2
          fi;;
      \?) shift $(( OPTIND - 2 ))
          printf '%s: %s: %s\n' "${func_name}" "$1" 'Invalid option.' 1>&2
          return 2;;
     esac
  done
  shift $(( OPTIND - 1 ))

  # Do not replace -e with -d: .git in submodules is not a directory but a file!
  if [ ! -e "${PWD}/.git" ]; then
    printf '%s: %s: %s\n' "${func_name}" "${PWD}" 'Directory is not a Git repository.' 1>&2
    return 2
  fi

  # How can I determine the URL that a local Git repository was originally cloned from?
  # https://stackoverflow.com/questions/4089430/how-can-i-determine-the-url-that-a-local-git-repository-was-originally-cloned-fr
  if ! remote_repository_url=$(git config --get "remote.${remote_name}.url"); then
    printf '%s: %s: %s\n' "${func_name}" "${remote_name}" 'Cannot get remote repository url.' 1>&2
    return 2
  fi
  repository_name=$(basename "${remote_repository_url}" .git)

  format=tgz
  # The commit cannot be use as a treeIsh value because newest versions of Git do not allow clients to access arbitrary SHA1s.
  # https://confluence.atlassian.com/stashkb/git-upload-archive-archiver-died-with-error-448791164.html
  commit=$(git rev-parse --short HEAD)
  treeIsh=${1:-$(git rev-parse --abbrev-ref HEAD)}

  # Clean treeIsh (translate each directory separator into a plus sign) while defining the output file.
  output=${target_directory}/${repository_name}-$(printf '%s\n' "${treeIsh}" | tr / +)@${commit}.${format}

  git archive --format=${format} \
              --output="${output}" \
              --prefix="${repository_name}"/ \
              --remote="${remote_repository_url}" "${treeIsh}"
  exit_status=$?
  if [ ${exit_status} -ne 0 ]; then
    rm -f "${output}"
  fi

  return ${exit_status}
)

get_coloured_git_branch() (
  if [ -e "${PWD}/.git" ]; then
    ESC=
    NORM="${ESC}[0m"
    if [ "$(git status -s | wc -l)" -eq 0 ]; then
      # green
      COLOUR="${ESC}[0;32m"
    else
      # red
      COLOUR="${ESC}[0;31m"
    fi
    if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
      printf '%s' "${COLOUR}${branch}${NORM}"
    fi
  fi

  return 0
)
