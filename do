#!/bin/sh

set -eux

PGVERSION="9.6"
PG_CONFIG=/usr/lib/postgresql/$PGVERSION/bin/pg_config
export PGPORT=5432
export PGDATABASE=regression

make PG_CONFIG=$PG_CONFIG PROFILE="-Werror"
sudo make install PG_CONFIG=$PG_CONFIG
psql -c "DROP EXTENSION IF EXISTS unit CASCADE"
if ! make installcheck REGRESS_OPTS="--use-existing" PG_CONFIG=$PG_CONFIG; then
	cat regression.diffs
	exit 1
fi
