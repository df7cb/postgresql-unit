#!/bin/sh

set -eux

PG_CONFIG=/usr/lib/postgresql/9.6/bin/pg_config
export PGPORT=5432
export PGDATABASE=regression

make PG_CONFIG=$PG_CONFIG PROFILE="-Werror"
sudo make install PG_CONFIG=$PG_CONFIG
psql -c "DROP TABLE u" || :
psql -c "DROP EXTENSION unit CASCADE" || :
psql -c "CREATE EXTENSION unit"
#psql -eX -f sql/unit.sql
if ! make installcheck REGRESS_OPTS="--use-existing" PG_CONFIG=$PG_CONFIG; then
	cat regression.diffs
	exit 1
fi
