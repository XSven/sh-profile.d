#!/usr/bin/env sh

PGSERVICEFILE=${XDG_CONFIG_HOME}/pg/pg_service.conf
export PGSERVICEFILE

mkdir -p "$(dirname "${PGSERVICEFILE}")"

export PGSEVICENAME=localpostgres
