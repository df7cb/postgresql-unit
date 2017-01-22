/*
Copyright (C) 2016 Christoph Berg

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

#define when(x) if (!strcmp(yytext, x))
%}

%option prefix="yyunit"
%option noyywrap
%option nounput
%option noinput

DOUBLE_R [\-+]?[0-9]*\.?[0-9]+([eE][\-+]?[0-9]+)?
UNIT_R   [a-zA-Z_][a-zA-Z_0-9]*
EXP_R    \^[\-+]?[0-9]+

%%

{DOUBLE_R} {
	yyunitlval.UNIT.value = atof(yytext);
	bzero(&yyunitlval.UNIT.units, N_UNITS);
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
	int			yylen;
	pg_wchar   *data;
	int			data_len;
	bool		match;
	regmatch_t	pmatch;
	char		p[UNIT_NAME_LENGTH]; /* prefix string found */
	unit_prefixes_t *prefix;

	/* Check if it's a unit without any prefix */
	name = hash_search(unit_names, yytext, HASH_FIND, NULL);
	if (name)
	{
		yyunitlval.UNIT = name->unit;
		return UNIT;
	}

	/* Check if it starts with a prefix we know */
	/* Convert data string to wide characters */
	yylen = strlen(yytext);
	data = (pg_wchar *) palloc((yylen + 1) * sizeof(pg_wchar));
	data_len = pg_mb2wchar_with_len(yytext, data, yylen);

	/* Perform RE match and return result */
	match = pg_regexec(&unit_prefix_regex, data, data_len,
		0,		 /* start at beginning */
		NULL,	 /* no details */
		1,		 /* nmatch */
		&pmatch, /* store start/end here */
		0);		 /* no flags */

	pfree(data);
	if (match != REG_OKAY)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("Unknown prefix on unit \"%s\" in unit input", yytext)));

	if (pmatch.rm_so != 0)
		elog(ERROR,
			 "Regex match expected at position 0, but found at %ld", pmatch.rm_so);

	strlcpy(p, yytext, pmatch.rm_so);
	prefix = hash_search(unit_prefixes, p, HASH_FIND, NULL);
	if (! prefix)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("Prefix \"%s\" on input unit \"%s\" not found in hash table", p, yytext)));

	/* Now see if the remainder is a known unit */
	name = hash_search(unit_names, yytext + pmatch.rm_so, HASH_FIND, NULL);
	if (! name)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("Unknown unit \"%s-%s\" in unit input", prefix->prefix, yytext + pmatch.rm_so)));

	yyunitlval.UNIT = name->unit;
	yyunitlval.UNIT.value *= prefix->factor;
	return UNIT;
}

{EXP_R} {
	yyunitlval.EXPONENT = atoi(yytext+1);
	return EXPONENT;
}

\* return '*';
\/ return '/';

[ \t\n]* /* eat whitespace */

. return ERR;
