FROM ubuntu:18.04

LABEL MAINTAINER mh@zenner-iot.com

ARG PG_VERSION=11
ARG PG_UNIT_VERSION=7.1
ARG PG_CONFIG=/usr/lib/postgresql/$PG_VERSION/bin/pg_config

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      lsb-release \
      flex \
      bison \
      curl && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y \
      postgresql-server-dev-$PG_VERSION && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/postgresql-unit

RUN curl -fsSL https://github.com/df7cb/postgresql-unit/archive/$PG_UNIT_VERSION.tar.gz | \
    tar --strip-components 1 -xzC /opt/postgresql-unit/

RUN make
RUN make install

FROM postgres:11

COPY --from=0 /opt/postgresql-unit/unit.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=0 /opt/postgresql-unit/unit_prefixes.data \
              /opt/postgresql-unit/unit_units.data \
              /opt/postgresql-unit/unit.control \
              /opt/postgresql-unit/unit--*.sql \
              /usr/share/postgresql/$PG_MAJOR/extension/

COPY  ./initdb-unit.sh /docker-entrypoint-initdb.d/
