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

{UNIT_R}    {
	unit_names_t	*name;
	int			ret;
	Oid			argtypes[1];
	Datum		values[1];
	size_t		yytext_len;

	/* Check if it's a predefined or previously seen unit */
	name = hash_search(unit_names, yytext, HASH_FIND, NULL);
	if (name)
	{
		elog(DEBUG1, "unit %s found in unit_names hash table", name->name);
		yyunitlval.UNIT_SHIFT = name->unit_shift;
		return UNIT_SHIFT;
	}

	SPI_connect();

	argtypes[0] = TEXTOID;
	values[0] = CStringGetTextDatum(yytext);

	/* look up unit definition without prefix first */
	ret = SPI_execute_with_args("SELECT unit, shift "
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
		Unit	   *unitp;
		double		shift;
		bool		is_null;

		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext);
		yyunitlval.UNIT_SHIFT.unit = *unitp;

		shift = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null));
		yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : shift;

		elog(DEBUG1, "unit %s (value %g)",
				SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
				unitp->value);

		goto found;
	}

	/* look up definition with prefix */
	ret = SPI_execute_with_args("SELECT prefix, factor, name, unit, shift "
								"FROM unit_prefixes CROSS JOIN unit_units WHERE "
								"prefix||name = $1 AND "
								"$1 LIKE prefix||'%' AND "
								"$1 LIKE '%'||name "
								"ORDER BY prefix",
								1, /* nargs */
								argtypes,
								values,
								NULL, /* nulls */
								true, /* read only */
								0); /* limit */
	if (ret != SPI_OK_SELECT)
		elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

	if (SPI_processed > 2)
		elog(ERROR, "unit \"%s\" is ambiguous, %lu prefix/name combinations found", yytext, (uint64)SPI_processed); /* SPI_processed was uint32 before 9.6 */
	if (SPI_processed == 2)
		elog(ERROR, "unit \"%s\" is ambiguous, \"%s-%s\" vs. \"%s-%s\"", yytext,
			 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
			 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 3),
			 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 1),
			 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 3));

	if (SPI_processed == 1) /* found definition */
	{
		double		factor;
		Unit	   *unitp;
		double		shift;
		bool		is_null;

		factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext);

		yyunitlval.UNIT_SHIFT.unit = *unitp;
		yyunitlval.UNIT_SHIFT.unit.value *= factor;

		shift = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 5, &is_null));
		yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : shift;

		goto found;
	}

	/* if unit is long enough, look up unit definition with plural 's' removed */
	yytext_len = strlen(yytext);
	if (yytext_len >= MIN_PLURAL_LENGTH && yytext[yytext_len - 1] == 's') {
		ret = SPI_execute_with_args("SELECT unit, shift "
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
			Unit	   *unitp;
			double		shift;
			bool		is_null;

			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext);
			yyunitlval.UNIT_SHIFT.unit = *unitp;

			shift = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null));
			yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : shift;

			elog(DEBUG1, "unit %s (value %g)",
					SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
					unitp->value);

			goto found;
		}

		/* look up definition with prefix */
		ret = SPI_execute_with_args("SELECT prefix, factor, name, unit, shift "
									"FROM unit_prefixes CROSS JOIN unit_units WHERE "
									"prefix||name = substring($1 for length($1) - 1) AND "
									"substring($1 for length($1) - 1) LIKE prefix||'%' AND "
									"substring($1 for length($1) - 1) LIKE '%'||name "
									"ORDER BY prefix",
									1, /* nargs */
									argtypes,
									values,
									NULL, /* nulls */
									true, /* read only */
									0); /* limit */
		if (ret != SPI_OK_SELECT)
			elog(ERROR, "internal error determining definition of unit \"%s\"", yytext);

		if (SPI_processed > 2)
			elog(ERROR, "unit \"%s\" is ambiguous, %lu prefix/name combinations found", yytext, (uint64)SPI_processed); /* SPI_processed was uint32 before 9.6 */
		if (SPI_processed == 2)
			elog(ERROR, "unit \"%s\" is ambiguous, \"%s-%s\" vs. \"%s-%s\"", yytext,
				 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
				 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 3),
				 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 1),
				 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 3));

		if (SPI_processed == 1) /* found definition */
		{
			double		factor;
			Unit	   *unitp;
			double		shift;
			bool		is_null;

			factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext);
			yyunitlval.UNIT_SHIFT.unit = *unitp;
			yyunitlval.UNIT_SHIFT.unit.value *= factor;

			shift = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 5, &is_null));
			yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : shift;

			goto found;
		}
	}

	/* nothing found, error out */
	elog(ERROR, "unit \"%s\" is not known", yytext);

found:

	SPI_finish();

	/* store computed unit in hash table */
	name = hash_search(unit_names, yytext, HASH_ENTER, NULL);
	strlcpy(name->name, yytext, UNIT_NAME_LENGTH);
	name->unit_shift = yyunitlval.UNIT_SHIFT;

	return UNIT_SHIFT;
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
