#!/usr/bin/env sh

getSslCertificate () (
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo 'usage: getSslCertificate <host> [ <port> ]' 1>&2
    return 1
  fi
  host=$1
  port=${2:-443}

  # Enable SNI (Server Name Indication) in openssl by specifying the -servername option
  virtualHost=${host}
  echo | \
  openssl s_client -servername "${virtualHost}" -connect "${host}:${port}" 2>&1 | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
)

registerSslCertificate() (
  if [ $# -ne 1 ]; then
    echo 'usage: registerSslCertificate <certificate file>' 1>&2
    return 1
  fi
  certificate=$1

  [ -f "${certificate}" ] || {
    echo "certificate file '${certificate}' is not an existing regular file" 1>&2
    return 1
  }
  hash=$(openssl x509 -noout -hash -in "${certificate}")
  [ -n "${hash}" ] || {
    echo "empty hash extracted from certificate file '${certificate}'" 1>&2
    return 1
  }

  for iterator in $(seq 0 9); do
   link=${hash}.${iterator};
    [ -f "${link}" ] && continue
    ln -s "${certificate}" "${link}"
    [ -L "${link}" ] && break
  done
)
