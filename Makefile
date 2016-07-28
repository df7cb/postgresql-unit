MODULE_big = unit
OBJS = unit.o unitparse.yy.o unitparse.tab.o
EXTENSION = unit
DATA = unit--1.sql
REGRESS = unit functions derived compare aggregate
EXTRA_CLEAN = unitparse.yy.* unitparse.tab.* unittest unittest.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

PG_VERSION_NUM = $(shell awk '/PG_VERSION_NUM/ { print $$3 }' $(shell $(PG_CONFIG) --includedir-server)/pg_config.h)
HAS_CROSSTAB = $(shell [ $(PG_VERSION_NUM) -ge 90600 ] && echo yes)
ifeq ($(HAS_CROSSTAB),yes)
REGRESS += crosstab
endif

unit.o: unit.c unit.h defined_units.h

unitparse.yy.c: unitparse.l
	flex -o $@ $<

unitparse.yy.o: unit.h defined_units.h unitparse.tab.c # actually unitparse.tab.h

unitparse.tab.c: unitparse.y
	bison -d $<

unitparse.tab.o: unit.h defined_units.h

# test program
unittest: unitparse.yy.o unitparse.tab.o unittest.o
	gcc -o $@ $^ -lm
