MODULE_big = unit
OBJS = unit.o unitparse.yy.o unitparse.tab.o
EXTENSION = unit
DATA = unit--*.sql
REGRESS = extension tables unit prefix functions derived compare aggregate iec
#REGRESS += upgrade
EXTRA_CLEAN = unitparse.yy.* powers powers.o unittest unittest.o # unitparse.tab.*

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

PG_VERSION_NUM = $(shell awk '/PG_VERSION_NUM/ { print $$3 }' $(shell $(PG_CONFIG) --includedir-server)/pg_config.h)
HAS_CROSSTAB = $(shell [ $(PG_VERSION_NUM) -ge 90600 ] && echo yes)
ifeq ($(HAS_CROSSTAB),yes)
REGRESS += crosstab convert
endif

unit.o: unit.c unit.h defined_units.h float8out_internal.h

unitparse.yy.c: unitparse.l
	flex -o $@ $<

unitparse.yy.o: unit.h defined_units.h unitparse.tab.c # actually unitparse.tab.h

unitparse.tab.c: unitparse.y
ifneq ($(shell bison --version | grep 'Bison..2'),)
	echo "### bison 2 detected, using pre-built unitparse.tab.c and .h files ###" # remove this hack once wheezy and precise are gone
	touch $@
else
	bison -d $<
endif

unitparse.tab.o: unit.h defined_units.h

# test program
unittest: unitparse.yy.o unitparse.tab.o unittest.o
	gcc -o $@ $^ -lm

# powers-of-10 template
powers: powers.c
	gcc -o $@ $^ -lm
