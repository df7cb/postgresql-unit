PG_CONFIG=pg_config
OBJS = unit.o
MODULE_big = unit
EXTENSION = unit
DATA = unit--1.0.sql
REGRESS = unit compare crosstab

USE_PGXS=1
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
