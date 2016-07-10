#!/bin/sh

set -eux

PG_CONFIG=/usr/lib/postgresql/9.5/bin/pg_config
export PGPORT=5495
export PGDATABASE=regression

make PG_CONFIG=$PG_CONFIG
sudo make install PG_CONFIG=$PG_CONFIG
psql -c "DROP TABLE u" || :
psql -c "DROP EXTENSION unit CASCADE" || :
psql -c "CREATE EXTENSION unit"
#psql -eX -f sql/unit.sql
make installcheck REGRESS_OPTS="--use-existing" PG_CONFIG=$PG_CONFIG
