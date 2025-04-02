#!/usr/bin/env sh

# The directory where 'go install' will install a command
GOBIN=~/go/bin
export GOBIN

PATH=${GOBIN}:${PATH}

# Experimenting with project templates
# https://go.dev/blog/gonew
# TODO: introduce dry-run option (-n)
gostart() (
  NAME=gostart

  project_type=lib
  code_hosting_side=git.int.kn
  organization=ibdev_go
  while getopts :c:ho:t:w: option; do
    case ${option} in
      c) code_hosting_side=${OPTARG:-${code_hosting_side}};;
      h) printf 'Usage: %s [ -h ] [ -c <code hosting side> ] [ -o <organization> ] [ -t <project type> ] [ -w <workspace> ] <project name>\n' "${NAME}"
         return 0;;
      o) organization=${OPTARG:-${organization}};;
      t) project_type=${OPTARG:-${project_type}};;
      w) workspace=${OPTARG};;
     \?) shift $((OPTIND - 2))
         printf '%s: %s: Invalid option.\n' "${NAME}" "$1" 1>&2
         return 2;;
  esac
  done
  shift $((OPTIND - 1))

  if [ -z "${GOPATH}" ]; then
    GOPATH=$(go env GOPATH)
  fi

  if [ -z "${workspace}" ]; then
    case ${GOPATH} in
       *:* ) printf '%s: %s: Workspace is not defined.\n' "${NAME}" '' 1>&2
             return 2;;
    esac
    workspace=${GOPATH}
  fi

  if [ $# -ne 1 ]; then
    printf '%s: %d: Wrong number of arguments.\n' "${NAME}" $# 1>&2
    return 2
  fi
  project_name=$1

  if [ "${project_type}" = lib ]; then
    package_name=${project_name}
  elif [ "${project_type}" = app ]; then
    package_name=main
  else
    printf "%s: %s: Invalid project type. 'lib' or 'app' expected.\\n" "${NAME}" "${project_type}" 1>&2
    return 2
  fi
  module_path=${code_hosting_side}/${organization}/${project_name}

  # action
  project_dir=${workspace}/src/${module_path}
  printf '%s: Creating new project: %s\n' "${NAME}" "${project_dir}" 1>&2
  mkdir -p "${project_dir}"

  TAB='	'
  source_code=${project_dir}/${package_name}.go
  cat > "${source_code}" <<-SOURCE_CODE
	package ${package_name}

	func Shout() {}
	SOURCE_CODE

  test_suite=${project_dir}/${package_name}_test.go
  cat > "${test_suite}" <<-TEST_SUITE
	package ${package_name}_test

	import (
	${TAB}"testing"

	${TAB}"${module_path}"
)

	func TestFunc(t *testing.T) {
	${TAB}${package_name}.Shout()
	${TAB}t.Fail()
	}
	TEST_SUITE

  cd "${project_dir}" || return 2
  go mod init "${module_path}"
)
