MODULE_big = unit
OBJS = unit.o unitparse.yy.o unitparse.tab.o
EXTENSION = unit
DATA = unit_prefixes.data unit_units.data \
	   unit--1.sql unit--1--2.sql \
	   unit--2.sql
DATA_built = unit--2--3.sql unit--3.sql \
			 unit--3--4.sql unit--4.sql \
			 unit--4--5.sql unit--5.sql \
			 unit--5--6.sql unit--6.sql
REGRESS = extension tables unit unicode prefix units temperature functions round derived compare aggregate iec custom
EXTRA_CLEAN = unitparse.yy.* powers powers.o unit-*.dump # unitparse.tab.*

# avoid add/mult contraction so '-459.67 °F' is really '0 K'
# problem visible on ppc64el Ubuntu trusty..zesty (Debian unaffected)
PG_CPPFLAGS += -ffp-contract=off

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

PG_VERSION_NUM = $(shell awk '/PG_VERSION_NUM/ { print $$3 }' $(shell $(PG_CONFIG) --includedir-server)/pg_config.h)
HAS_CROSSTAB = $(shell [ $(PG_VERSION_NUM) -ge 90600 ] && echo yes)
ifeq ($(HAS_CROSSTAB),yes)
REGRESS += crosstab convert
endif

# upgrade testing, not enabled by default (needs extension actually installed)
#REGRESS += upgrade

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

%.sql: %.sql.in
	sed -e "s!@MODULEDIR@!$(datadir)/$(datamoduledir)!g" $< > $@

# unit definitions from GNU units
definitions.units.patched: definitions.units definitions.units.patch
	cp $< $@
	patch $@ definitions.units.patch

# powers-of-10 template
powers: powers.c
	gcc -o $@ $^ -lm
