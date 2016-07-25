MODULE_big = unit
OBJS = unit.o unitparse.yy.o unitparse.tab.o
EXTENSION = unit
DATA = unit--1.0.sql
REGRESS = unit functions derived compare aggregate crosstab
EXTRA_CLEAN = unitparse.yy.* unitparse.tab.* unittest unittest.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

unit.o: unit.c unit.h defined_units.h

unitparse.yy.c: unitparse.l
	flex --prefix yyunit -o $@ $<

unitparse.yy.o: unit.h defined_units.h unitparse.tab.c # actually unitparse.tab.h

unitparse.tab.c: unitparse.y
	bison -Dapi.prefix=yyunit -d $<

unitparse.tab.o: unit.h defined_units.h

# test program
unittest: unitparse.yy.o unitparse.tab.o unittest.o
	gcc -o $@ $^ -lm
