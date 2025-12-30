#!/usr/bin/env sh

if [ -z "${HOSTNAME}" ]; then
  HOSTNAME=$(hostname)
fi
# bash sets the variable HOSTNAME but does not export it.
export HOSTNAME

clean_path() (
  func_name=clean_path
  quiet=false
  while getopts :q option; do
    case ${option} in
       q) quiet=true;;
      \?) shift $(( OPTIND - 2 ))
          printf '%s: %s: Invalid option.\n' "${func_name}" "$1" 1>&2
          return 2;;
    esac
  done
  shift $(( OPTIND - 1 ))
  old_path=$1

  IFS=:
  new_path=${IFS}
  for directory in ${old_path}; do
    message=

    if [ "${directory}" = . ]; then
      message='Current directory'
    elif [ ! -e "${directory}" ]; then
      message='Non existing directory'
    elif [ ! -d "${directory}" ]; then
      message='File that is not a directory'
    elif [ -n "${directory%%/*}" ]; then
      message='Relative directory'
    else
      case ${new_path} in
        *${IFS}${directory}${IFS}* ) message='Duplicate directory';;
      esac
    fi

    if [ -n "${message}" ]; then
      if ! ${quiet}; then
        printf '%s: %s: %s\n' "${func_name}" "${directory}" "$message removed from path." 1>&2
      fi
    else
      new_path=${new_path}${directory}${IFS}
    fi
  done

  new_path=${new_path#"${IFS}"}
  printf '%s\n' "${new_path%"${IFS}"}"
)

# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html#tag_20_22
# The standard error output was not suppressed (2>&1) on purpose
command_exists() {
  command -v "$1" >/dev/null
}

get_coloured_exit_status() (
  exit_status=$1

  ESC=
  NORM="${ESC}[0m"
  if [ "${exit_status}" -eq 0 ]; then
    COLOUR="${ESC}[0;32m"
  else
    COLOUR="${ESC}[0;31m"
  fi

  echo "${COLOUR}${exit_status}${NORM}"
  return 0
)

get_os_name() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

# Prepare shortened prompt string using tilde notation for users' home
# directories.
tildize() (
  case $1 in
    ${HOME}* ) echo "~${1#${HOME}}"
               return 0;;
  esac

  IFS=:
  # shellcheck disable=SC2034
  while read -r user skip skip skip skip home skip; do
    if [ "${home}" != / ]; then
      case $1 in
        # The order of expansion and comparison of multiple "|" delimited
        # patterns that label a compound-list statement is unspecified.
        "${home}" | "${home}"/* ) echo "~${user}${1#${home}}"
                                  return 0;;
      esac
    fi
  done < /etc/passwd
  echo "$1"
  return 0
)

PS1='${SHELL##*/}:$(get_coloured_exit_status $?)://${LOGNAME}@${HOSTNAME}/$(tildize "${PWD}")/
$'

# The GECOS information of a given user has usually 5 fields: real (full) name,
# work room, work phone, home phone, and other notes (like email address) on
# the user. With the chfn command you may change a user's GECOS information.
# chfn could stand for change full name or change finger. The finger or pinky
# command will display the pieces of information that can be changed by chfn.
read_GECOS() (
  field_number=$1

  IFS=:
  # shellcheck disable=SC2034
  while read -r user skip skip skip gecos skip; do
    if [ "${user}" = "${LOGNAME}" ]; then
      # shellcheck disable=SC2086
      ( IFS=,; set -- ${gecos}; eval echo \$\{"${field_number}"\} )
      return 0
    fi
  done < /etc/passwd
  return 1
)

# The 1st GECOS field is the user's full name.
FULL_NAME=$(read_GECOS 1)
export FULL_NAME

# The 5th GECOS field is the user's email address.
EMAIL=$(read_GECOS 5)
export EMAIL

select_loop() (
  if [ $# -eq 0 ]; then
    return
  fi

  # show menu
  i=0
  for item; do
    i=$(( i + 1 ))
    printf '%d) %s\n' $i "${item}" 1>&2
  done
  unset item

  # select loop
  # End Of Transmission (EOT, ^D) breaks the loop because the read()
  # exit status is >0 in this case
  while { printf %s "${PS3:-#? }" 1>&2; read -r REPLY; exit_status=$?; [ ${exit_status} -eq 0 ]; }; do
    case ${REPLY} in
      '' | 0* | *[!0-9]* ) continue;;
    esac
    if [ "${REPLY}" -ge 1 ] && [ "${REPLY}" -le $# ]; then
      # indirect expansion of positional parameters
      # https://unix.stackexchange.com/questions/111618/indirect-variable-expansion-in-posix-as-done-in-bash
      # shellcheck disable=SC2086
      eval item=\$\{${REPLY}\}
      break
    fi
  done
  if [ ${exit_status} -eq 0 ]; then
    printf %s\\n "${item}"
  else
    return ${exit_status}
  fi
)

use_bash() {
  case ${SHELL} in
    *bash ) return 1;;
  esac
  # -A enables forwarding of the authentication agent connection.
  # -t enforces pseudo-tty allocation.
  ssh -A -t localhost 'SHELL=/usr/bin/bash /usr/bin/bash --login'
}

true

