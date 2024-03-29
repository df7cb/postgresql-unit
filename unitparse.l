/*
Copyright (C) 2016-2018 Christoph Berg

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
#include <math.h> /* INFINITY, NAN */

#define when(x) if (!strcmp(yytext, x))
%}

%option prefix="yyunit"
%option noyywrap
%option nounput
%option noinput

 /* UTF-8 support, see http://stackoverflow.com/questions/9611682/flexlexer-support-for-unicode */
U       [\x80-\xbf]
 /* 2-byte UTF-8: \xc2-\xdf excluding SUPER_2, SUPER_3 and SUPER_1 */
U2_1    \xc2[\x80-\xb1]
U2_2    \xc2[\xb4-\xb8]
U2_3    \xc2[\xba-\xbf]
U2_4    [\xc3-\xdf]{U}
 /* 3-byte UTF-8: \xe0-\xef excluding SUPER_0 .. SUPER_MINUS */
U3_1    [\xe0-\xe1]{U}{U}
U3_2    \xe2\x80{U}
U3_3    \xe2\x81[\x80-\xaf]
U3_4    \xe2\x81[\xbc-\xbf]
U3_5    \xe2[\x82-\xbf]{U}
U3_6    [\xe3-\xef]{U}{U}
 /* 4-byte UTF-8: \xf0-\xf4 */
U4      [\xf0-\xf4]{U}{U}{U}

UTF8    {U2_1}|{U2_2}|{U2_3}|{U2_4}|{U3_1}|{U3_2}|{U3_3}|{U3_4}|{U3_5}|{U3_6}|{U4}
ALPHA   [a-zA-Z$%'"_]|{UTF8}
ALNUM   [a-zA-Z$%'"_0-9]|{UTF8}

DOUBLE_R [0-9]*\.?[0-9]+([eE][\-+]?[0-9]+)?
TIME_R   [0-9]+:[0-9]+:[0-9]+(\.[0-9]+)?
UNIT_R   {ALPHA}{ALNUM}*
EXP_R    \^[\-+]?[0-9]+

SUPER_PLUS  \xe2\x81\xba
SUPER_MINUS \xe2\x81\xbb
SUPER_0     \xe2\x81\xb0
SUPER_1     \xc2\xb9
SUPER_2     \xc2\xb2
SUPER_3     \xc2\xb3
SUPER_4     \xe2\x81\xb4
SUPER_5     \xe2\x81\xb5
SUPER_6     \xe2\x81\xb6
SUPER_7     \xe2\x81\xb7
SUPER_8     \xe2\x81\xb8
SUPER_9     \xe2\x81\xb9

%%

{DOUBLE_R} {
	yyunitlval.DOUBLE = atof(yytext);
	return DOUBLE;
}

[Ii][Nn][Ff]([Ii][Nn][Ii][Tt][Yy])? {
	yyunitlval.DOUBLE = INFINITY;
	return DOUBLE;
}

[Nn][Aa][Nn] {
	yyunitlval.DOUBLE = NAN;
	return DOUBLE;
}

sqrt {
	yyunitlval.FUNCTION = FUNCTION_SQRT;
	return FUNCTION;
}

exp {
	yyunitlval.FUNCTION = FUNCTION_EXP;
	return FUNCTION;
}

ln {
	yyunitlval.FUNCTION = FUNCTION_LN;
	return FUNCTION;
}

log2 {
	yyunitlval.FUNCTION = FUNCTION_LOG2;
	return FUNCTION;
}

asin {
	yyunitlval.FUNCTION = FUNCTION_ASIN;
	return FUNCTION;
}

tan {
	yyunitlval.FUNCTION = FUNCTION_TAN;
	return FUNCTION;
}

{TIME_R} { /* hh:mm:ss[.sss] */
	char *colon;
	yyunitlval.DOUBLE = TIME_HOUR * atoi(yytext); /* hh */
	colon = strchr(yytext, ':');
	yyunitlval.DOUBLE += TIME_MINUTE * atoi(colon + 1); /* mm */
	colon = strchr(colon + 1, ':');
	yyunitlval.DOUBLE += atof(colon + 1); /* ss[.sss] */
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
		Datum		shift;
		bool		is_null;

		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext);
		yyunitlval.UNIT_SHIFT.unit = *unitp;

		shift = SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null);
		yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : DatumGetFloat8(shift);

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
	{
		long		processed = SPI_processed; /* SPI_processed was uint32 before 9.6 */
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("unit \"%s\" is ambiguous, %lu prefix/name combinations found",
					 yytext, processed)));
	}
	if (SPI_processed == 2)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("unit \"%s\" is ambiguous, \"%s-%s\" vs. \"%s-%s\"", yytext,
					 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
					 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 3),
					 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 1),
					 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 3))));

	if (SPI_processed == 1) /* found definition */
	{
		double		factor;
		Unit	   *unitp;
		Datum		shift;
		bool		is_null;

		factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
		unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
		if (is_null)
			elog(ERROR, "unit \"%s\" definition is NULL", yytext);

		yyunitlval.UNIT_SHIFT.unit = *unitp;
		yyunitlval.UNIT_SHIFT.unit.value *= factor;

		shift = SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 5, &is_null);
		yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : DatumGetFloat8(shift);

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
			Datum		shift;
			bool		is_null;

			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext);
			yyunitlval.UNIT_SHIFT.unit = *unitp;

			shift = SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null);
			yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : DatumGetFloat8(shift);

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
		{
			long		processed = SPI_processed; /* SPI_processed was uint32 before 9.6 */
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
					 errmsg("unit \"%s\" is ambiguous, %lu prefix/name combinations found",
						 yytext, processed)));
		}
		if (SPI_processed == 2)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
					 errmsg("unit \"%s\" is ambiguous, \"%s-%s\" vs. \"%s-%s\"", yytext,
						 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 1),
						 SPI_getvalue(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 3),
						 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 1),
						 SPI_getvalue(SPI_tuptable->vals[1], SPI_tuptable->tupdesc, 3))));

		if (SPI_processed == 1) /* found definition */
		{
			double		factor;
			Unit	   *unitp;
			Datum		shift;
			bool		is_null;

			factor = DatumGetFloat8(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 2, &is_null)); /* we discard is_null here */
			unitp = (Unit *) DatumGetPointer(SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 4, &is_null));
			if (is_null)
				elog(ERROR, "unit \"%s\" definition is NULL", yytext);
			yyunitlval.UNIT_SHIFT.unit = *unitp;
			yyunitlval.UNIT_SHIFT.unit.value *= factor;

			shift = SPI_getbinval(SPI_tuptable->vals[0], SPI_tuptable->tupdesc, 5, &is_null);
			yyunitlval.UNIT_SHIFT.shift = is_null ? 0.0 : DatumGetFloat8(shift);

			goto found;
		}
	}

	/* nothing found, error out */
	ereport(ERROR,
			(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
			 errmsg("unit \"%s\" is not known", yytext)));

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

{SUPER_PLUS}  { yyunitlval.SUPER_SIGN = 1; return SUPER_SIGN; }
{SUPER_MINUS} { yyunitlval.SUPER_SIGN = -1; return SUPER_SIGN; }
{SUPER_0} { yyunitlval.SUPER = 0; return SUPER; }
{SUPER_1} { yyunitlval.SUPER = 1; return SUPER; }
{SUPER_2} { yyunitlval.SUPER = 2; return SUPER; }
{SUPER_3} { yyunitlval.SUPER = 3; return SUPER; }
{SUPER_4} { yyunitlval.SUPER = 4; return SUPER; }
{SUPER_5} { yyunitlval.SUPER = 5; return SUPER; }
{SUPER_6} { yyunitlval.SUPER = 6; return SUPER; }
{SUPER_7} { yyunitlval.SUPER = 7; return SUPER; }
{SUPER_8} { yyunitlval.SUPER = 8; return SUPER; }
{SUPER_9} { yyunitlval.SUPER = 9; return SUPER; }

\+ return '+';
-  return '-';
\/ return '/';
\* return '*';
\| return '|';

\( return '(';
\) return ')';

[ \t\n]* /* eat whitespace */

. return ERR;
