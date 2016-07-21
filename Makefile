MODULES = unit
EXTENSION = unit
DATA = unit--1.0.sql
REGRESS = unit functions compare aggregate crosstab

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
