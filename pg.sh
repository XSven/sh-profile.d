#!/usr/bin/env sh

PGSERVICEFILE=${XDG_CONFIG_HOME}/pg/pg_service.conf
if [ -s "${PGSERVICEFILE}" ]; then
  export PGSERVICEFILE
  PGSERVICE=localpostgres
  if grep -q "^\[${PGSERVICE}\]\$" "${PGSERVICEFILE}"; then
    export PGSERVICE
  else
    unset PGSERVICE
  fi
else
  unset PGSERVICEFILE
fi
