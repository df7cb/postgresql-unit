#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_unit' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_unit;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_unit';
EOSQL

# Load Unit into both template_database and $POSTGRES_DB
for DB in template_unit "$POSTGRES_DB"; do
        echo "Loading Unit extensions into $DB"
        "${psql[@]}" --dbname="$DB" <<-'EOSQL'
                CREATE EXTENSION IF NOT EXISTS unit;
EOSQL
done
