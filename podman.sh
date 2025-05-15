#!/usr/bin/env sh

# example: push_image_to_registry harbor.emea.ocp.int.kn cp-666093 rest-manager:1.0.0

push_image_to_registry () (
  func_name=push_image_to_registry

  #set -o xtrace
  set -o nounset

  while getopts :h option; do
    case ${option} in
       h) printf 'Usage: %s %s\n       %s %s\n' "${func_name}" '[ -h ]' "${func_name}" '<registry> <namespace> <image>'
          return 0;;
      \?) shift $(( OPTIND - 2 ))
          printf '%s: %s: %s\n' "${func_name}" "$1" 'Invalid option.' 1>&2
          return 2;;
     esac
  done
  shift $(( OPTIND - 1 ))

  registry=$1
  namespace=$2
  image=${3##*/}

  if ! podman login --get-login "${registry}" 1>/dev/null 2>&1; then
    username=$(vault read --field user "processing/harbor/prod/${registry}/${namespace}/robot_accounts/ibpp-harbor")
    vault read --field password "processing/harbor/prod/${registry}/${namespace}/robot_accounts/ibpp-harbor" | \
    podman login --username "${username}" --password-stdin "${registry}"
  else
    printf '%s: %s\n' "${func_name}" "Already logged into registry ${registry}" 1>&2
  fi

  custom_image=${registry}/${namespace}/${image}
  podman push "${image}" "${custom_image}"
)
