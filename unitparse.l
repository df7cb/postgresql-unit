/*
Copyright (C) 2016-2017 Christoph Berg

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
*/

%{
#include "unit.h"
#include "unitparse.tab.h"
#include <executor/spi.h>
#include <utils/builtins.h> /* CStringGetTextDatum */
#include <catalog/pg_type.h> /* TEXTOID */

#define when(x) if (!strcmp(yytext, x))
%}

%option prefix="yyunit"
%option noyywrap
%option nounput
%option noinput

 /* UTF-8 support, see http://stackoverflow.com/questions/9611682/flexlexer-support-for-unicode */
U       [\x80-\xbf]
U2      [\xc2-\xdf]
U3      [\xe0-\xef]
U4      [\xf0-\xf4]
UTF8    {U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}
ALPHA   [a-zA-Z$%'"_]|{UTF8}
ALNUM   [a-zA-Z$%'"_0-9]|{UTF8}

DOUBLE_R [\-+]?[0-9]*\.?[0-9]+([eE][\-+]?[0-9]+)?
UNIT_R   {ALPHA}{ALNUM}*
EXP_R    \^[\-+]?[0-9]+

%%

{DOUBLE_R} {
	yyunitlval.DOUBLE = atof(yytext);
	return DOUBLE;
}

 /*
	bzero(&yyunitlval.UNIT.units, N_UNITS);
	     when ("y") yyunitlval.UNIT.value = 1e-24;
	else when ("z") yyunitlval.UNIT.value = 1e-21;
	else when ("a") yyunitlval.UNIT.value = 1e-18;
	else when ("f") yyunitlval.UNIT.value = 1e-15;
	else when ("p") yyunitlval.UNIT.value = 1e-12;
	else when ("n") yyunitlval.UNIT.value = 1e-9;
	else when ("µ") yyunitlval.UNIT.value = 1e-6;
	else when ("mu") yyunitlval.UNIT.value = 1e-6;
	else when ("m") yyunitlval.UNIT.value = 1e-3;
	else when ("c") yyunitlval.UNIT.value = 1e-2;
	else when ("d") yyunitlval.UNIT.value = 1e-1;

	else when ("da") yyunitlval.UNIT.value = 1e1;
	else when ("h") yyunitlval.UNIT.value = 1e2;
	else when ("k") yyunitlval.UNIT.value = 1e3;
	else when ("M") yyunitlval.UNIT.value = 1e6;
	else when ("G") yyunitlval.UNIT.value = 1e9;
	else when ("T") yyunitlval.UNIT.value = 1e12;
	else when ("P") yyunitlval.UNIT.value = 1e15;
	else when ("E") yyunitlval.UNIT.value = 1e18;
	else when ("Z") yyunitlval.UNIT.value = 1e21;
	else when ("Y") yyunitlval.UNIT.value = 1e24;
	else return ERR;
	return PREFIX;
 }

 {IEC_PREFIX_R}/B { / * IEC binary prefixes for Bytes only * /
	bzero(&yyunitlval.UNIT.units, N_UNITS);
	     when ("Ki") yyunitlval.UNIT.value = 0x1p+10;
	else when ("Mi") yyunitlval.UNIT.value = 0x1p+20;
	else when ("Gi") yyunitlval.UNIT.value = 0x1p+30;
	else when ("Ti") yyunitlval.UNIT.value = 0x1p+40;
	else when ("Pi") yyunitlval.UNIT.value = 0x1p+50;
	else when ("Ei") yyunitlval.UNIT.value = 0x1p+60;
	else when ("Zi") yyunitlval.UNIT.value = 0x1p+70;
	else when ("Yi") yyunitlval.UNIT.value = 0x1p+80;
	else return ERR;
	return PREFIX;
}
 */

{UNIT_R}    {
	unit_names_t	*name;
	int			ret;
	Oid			argtypes[1];
	Datum		values[1];
	double		factor;
	Unit	   *unitp;
	bool		is_null;
	size_t		yytext_len;

	/* Check if it's a predefined or previously seen unit */
	name = hash_search(unit_names, yytext, HASH_FIND, NULL);
	if (name)
	{
		elog(DEBUG1, "unit %s found in unit_names hash table", name->name);
		yyunitlval.UNIT = name->unit;
		return UNIT;
	}

	SPI_connect();

	argtypes[0] = TEXTOID;
	values[0] = CStringGetTextDatum(yytext);

	/* look up unit definition without prefix first */
	ret = SPI_execute_with_args("SELECT unit "
								"FROM unit_units WHERE "
								"name = $1",
								1, /* nargs */
								argtypes,
								values,
								NULL, /* nulls */
								true, /* read only */
								0); /* limit */
	if (ret != SPI_OK_SELECT)
		elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

	if (SPI_processed == 1) /* found definition */
	{
		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext); // FIXME unit_units.name
		yyunitlval.UNIT = *unitp;

		elog(DEBUG1, "unit %s (value %g)",
				SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
				unitp->value);

		goto found;
	}

	/* look up definition with prefix */
	ret = SPI_execute_with_args("SELECT prefix, factor, name, unit "
								"FROM unit_prefixes CROSS JOIN unit_units WHERE "
								"prefix||name = $1 AND "
								"$1 LIKE prefix||'%' AND "
								"$1 LIKE '%'||name",
								1, /* nargs */
								argtypes,
								values,
								NULL, /* nulls */
								true, /* read only */
								0); /* limit */
	if (ret != SPI_OK_SELECT)
		elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

	if (SPI_processed > 1)
		elog(ERROR, "unit \"%s\" is ambiguous", yytext);

	if (SPI_processed == 1) /* found definition */
	{
		factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext); // FIXME unit_units.name
		yyunitlval.UNIT = *unitp;
		yyunitlval.UNIT.value *= factor;

		goto found;
	}

	/* look up unit definition with plural 's' removed */
	yytext_len = strlen(yytext);
	if (yytext_len >= MIN_PLURAL_LENGTH && yytext[yytext_len - 1] == 's') {
		ret = SPI_execute_with_args("SELECT unit "
									"FROM unit_units WHERE "
									"name = substring($1 for length($1) - 1)",
									1, /* nargs */
									argtypes,
									values,
									NULL, /* nulls */
									true, /* read only */
									0); /* limit */
		if (ret != SPI_OK_SELECT)
			elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

		if (SPI_processed == 1) /* found definition */
		{
			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext); // FIXME unit_units.name
			yyunitlval.UNIT = *unitp;

			elog(DEBUG1, "unit %s (value %g)",
					SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
					unitp->value);

			goto found;
		}

		/* look up definition with prefix */
		ret = SPI_execute_with_args("SELECT prefix, factor, name, unit "
									"FROM unit_prefixes CROSS JOIN unit_units WHERE "
									"prefix||name = substring($1 for length($1) - 1) AND "
									"substring($1 for length($1) - 1) LIKE prefix||'%' AND "
									"substring($1 for length($1) - 1) LIKE '%'||name",
									1, /* nargs */
									argtypes,
									values,
									NULL, /* nulls */
									true, /* read only */
									0); /* limit */
		if (ret != SPI_OK_SELECT)
			elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

		if (SPI_processed > 1)
			elog(ERROR, "unit \"%s\" is ambiguous", yytext);

		if (SPI_processed == 1) /* found definition */
		{
			factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext); // FIXME unit_units.name
			yyunitlval.UNIT = *unitp;
			yyunitlval.UNIT.value *= factor;

			goto found;
		}
	}

	/* nothing found, error out */
	elog(ERROR, "unit \"%s\" is not known", yytext);

found:

	/*
	elog(DEBUG1, "prefix %s (%g), unit %s (value %g)",
			SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
			factor,
			SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 3),
			unitp->value);
			*/

	SPI_finish();

	/* store computed unit in hash table */
	name = hash_search(unit_names, yytext, HASH_ENTER, NULL);
	strlcpy(name->name, yytext, UNIT_NAME_LENGTH);
	name->unit = yyunitlval.UNIT;

	return UNIT;
}

{EXP_R} {
	yyunitlval.EXPONENT = atoi(yytext+1);
	return EXPONENT;
}

\+ return '+';
-  return '-';
\/ return '/';
\* return '*';
\| return '|';

\( return '(';
\) return ')';

[ \t\n]* /* eat whitespace */

. return ERR;
