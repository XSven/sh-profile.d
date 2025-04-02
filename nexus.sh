#!/usr/bin/env sh

downloadAssetFromNexusServer() (
  NAME=downloadAssetFromNexusServer

  NUMBER_OF_ARGUMENTS=3
  VERSION=1.0.0

  set -o nounset


  authentication=''
  classifier=''
  nexusVersion=2
  output=''
  packaging=jar
  urlOnly=false
  verbose=''
  while getopts :3UVc:hno:p:u:v option; do
    case ${option} in
       3) nexusVersion=${option};;
       U) [ -z "${output}" ] || {
            echo 1>&2 "${NAME}[${LINENO}]: ${output}: Output file name specified. Request for URL only mode rejected."
            return 2
          }
          urlOnly=true;;
       V) echo "${NAME} ${VERSION}"
          return 0;;
       c) classifier=${OPTARG};;
       h) ESC=
          O="${ESC}[0m"
          B="${ESC}[1m"
          echo "
${B}${NAME} ${VERSION}${O}

${B}Purpose${O}

  This function downloads a Maven asset from a Nexus repository server using
  the Nexus REST API. The function uses ${B}curl${O} to interact with the server.

${B}Syntax${O}

  ${B}${NAME}${O} ${B}-V${O}
  ${B}${NAME}${O} ${B}-h${O}
  ${B}${NAME}${O} [ ${B}-3${O} ] [ ${B}-U${O} | ${B}-o${O} output ] [ ${B}-c${O} classifier ] [ ${B}-p${O} packaging ]
                               [ ${B}-n${O} | ${B}-u${O} username:password ] [ ${B}-v${O} ] nexusUrl repository groupId:artifactId:version

${B}Options${O}

  ${B}-3${O}
  Use the Nexus 3 REST API instead of the default Nexus 2 REST API.

  ${B}-U${O}
  Do not download but print the REST redirect URL to standard output.

  ${B}-V${O}
  Displays version information. Version information goes to standard output.

  ${B}-c${O} classifier
  Specifies the classifier of the artifact, e.g., javadoc, sources, ....

  ${B}-h${O}
  Displays this help. Help goes to standard output.

  ${B}-n${O}
  Reads user name and password to use for server authentication from the
  ${B}\${HOME}/.netrc${O} file.

  ${B}-o${O} output
  Specifies the output file name. It defaults to the dash separated
  concatenation of the artifact id, version, and classifier (optional)
  coordinate with the packaging (optional) as its file name extension.
  If the specified output file name is a directory, the default file
  name will be stored in that directory. If the output file name is
  a single dash, the output will be sent to standard output. In all
  other cases the output file name will be used as is.

  ${B}-p${O} packaging
  Specifies the packaging type of the artifact, e.g., pom, jar, .... It
  defaults to ${B}${packaging}${O}. For Nexus 3 REST API based download
  the packaging type is used to set the ${B}maven.extension${O} format
  specific attribute.

  ${B}-u${O} username:password
  Specifies user name and password to use for server authentication.

  ${B}-v${O}
  Makes the downloading more verbose/talkative.

${B}Exit status${O}

  ${B}0${O}
  The version information was printed or the function help was printed.

  ${B}2${O}
  A syntax error occurred.

${B}Links${O}

  https://repository.sonatype.org/nexus-restlet1x-plugin/default/docs/path__artifact_maven_redirect.html
  https://help.sonatype.com/repomanager3/rest-and-integration-api/search-api#SearchAPI-SearchandDownloadAsset

${B}Examples${O}

  ${NAME}    -v -u jenkins.ibdev:******        -c javadoc http://repository.int.kn IBDEV com.kn.ib:knib-lib-nbrclient:2.3.1

  ${NAME}       -n                      -p pom            http://repository.int.kn IBDEV com.kn.ib:knib-lib-nbrclient:2.3.1

  cat \${HOME}/.netrc
  machine repository.int.kn
  login jenkins.ibdev
  password ******

  ${NAME}    -v -u jenkins.ib2:******                     http://repository.int.kn ib2-snapshots com.kn.ib2:configuration-service-server:LATEST

  # A camel case artifactId, e.g. KNIB-App-ArchivingDaemon, is working too!
  ${NAME}    -v -u jenkins.ibdev:****** -p rpm -c x86_64  http://repository.int.kn IBDEV com.kn.ib:KNIB-App-ArchivingDaemon:1.0.25

  # A Nexus 3 download of a snapshot artifact.
  ${NAME} -3 -v -n                      -p tgz -c noarch  https://repository.int.kn ibdev-snapshots com.kn.ib:KNIB-Lib-Cvs:5.1.0-SNAPSHOT

  # Prepare the URL of an artifact and pass it to rpm to download the artifact and to list its content.
  # The version of this artifact is unusual because it contains the release number of the rpm that it represents!
  rpm -qlp \$(${NAME} -U -c powerpc -p rpm  http://repository.int.kn IBDEV com.kn.ib:EdiStar3-EdiCon:6.17.0-1)
"
          return 0;;
       n) [ -z "${authentication}" ] || {
            echo 1>&2 "${NAME}[${LINENO}]: ${authentication}: Server authentication already configured."
            return 2
          }
          authentication=-n;;
       o) ! ${urlOnly} || {
            echo 1>&2 "${NAME}[${LINENO}]: : Useless specification of output file name in URL only mode."
            return 2
          }
          output=${OPTARG};;
       p) packaging=${OPTARG};;
       u) [ -z "${authentication}" ] || {
            echo 1>&2 "${NAME}[${LINENO}]: ${authentication}: Server authentication already configured."
            return 2
          }
          authentication="-u ${OPTARG}";;
          # TODO: Implement a check that proves that OPTARG == username:password
       v) verbose=-v;;
      \?) shift $(( OPTIND - 2 ))
          echo 1>&2 "${NAME}[${LINENO}]: $1: Invalid option."
          return 2;;
    esac
  done
  shift $(( OPTIND - 1 ))

  [ $# -eq 0 ] && {
    echo 1>&2 "${NAME}[${LINENO}]: : Missing Nexus URL."
    return 2
  }
  [ $# -eq 1 ] && {
    echo 1>&2 "${NAME}[${LINENO}]: : Missing repository."
    return 2
  }
  [ $# -eq 2 ] && {
    echo 1>&2 "${NAME}[${LINENO}]: : Missing GAV coordinate."
    return 2
  }
  [ $# -gt ${NUMBER_OF_ARGUMENTS} ] && {
    echo 1>&2 "${NAME}[${LINENO}]: $#: Too many arguments. Exactly ${NUMBER_OF_ARGUMENTS} arguments expected."
    return 2
  }

  nexusUrl=$1
  repository=$2
  gav=$3

  oldIFS=${IFS}
  IFS=:
  # shellcheck disable=SC2086
  set -- ${gav}
  groupId=$1
  artifactId=$2
  version=$3
  IFS=${oldIFS}

  # NOTE referring to the Nexus 2 REST API: We could think about using LATEST as
  # value for the GAV version coordinate if its value would be empty. The article
  # https://articles.javatalks.ru/articles/32 (Nexus: why you shouldn't use LATEST)
  # explains why we shouldn't do that.
  # shellcheck disable=SC2015
  [ -n "${groupId}" ] && [ -n "${artifactId}" ] && [ -n "${version}" ] || {
    echo 1>&2 "${NAME}[${LINENO}]: ${gav}: Invalid GAV coordinate."
    return 2
  }

  if [ "${nexusVersion}" -eq 2 ]; then
    endPoint=/nexus/service/local/artifact/maven/redirect
    parameter="g=${groupId}&a=${artifactId}&v=${version}&r=${repository}"
    [ -z "${packaging}" ]  || parameter="${parameter}&p=${packaging}"
    [ -z "${classifier}" ] || parameter="${parameter}&c=${classifier}"
  else
    endPoint=/service/rest/v1/search/assets/download
    parameter="group=${groupId}&name=${artifactId}&maven.baseVersion=${version}&sort=version&repository=${repository}"
    [ -z "${packaging}" ]  || parameter="${parameter}&maven.extension=${packaging}"
    [ -z "${classifier}" ] || parameter="${parameter}&maven.classifier=${classifier}"
  fi

  redirectUrl="${nexusUrl}${endPoint}?${parameter}"
  if ${urlOnly}; then
    echo "${redirectUrl}"
    return 0
  fi

  defaultOutput=${artifactId}-${version}
  [ -z "${classifier}" ] || defaultOutput=${defaultOutput}-${classifier}
  defaultOutput=${defaultOutput}${packaging:+.${packaging}}
  if [ -z "${output}" ]; then
    output=${defaultOutput}
  elif [ "${output}" != - ] && [ -d "${output}" ]; then
    output=${output}/${defaultOutput}
  fi

  # curl options explained
  # -f       Fail silently (no HTML response document) of server errors.
  # -R       If possible make the local file get the same timestamp as the remote file.
  # -s -S    Don't show progress meter but error messages.
  # -X GET   Set default request method explicitly
  # -o file  Write output to file instead of stdout.
  location=--location
  [ -z "${authentication}" ] || location=--location-trusted
  [ -z "${verbose}" ] || set -o xtrace
  curl -f -R -s -S -X GET -o "${output}" "${location}" ${verbose} "${authentication}" "${redirectUrl}" \
    && [ "${output}" != - ] && echo 1>&2 "${output}"
)
