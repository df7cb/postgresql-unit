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
#include <strings.h> /* bzero */
#include <math.h> /* pow */
#include "unit.h"

/* flex/bison prototypes */
int yylex (void);
struct yyunit_buffer_state *yyunit_scan_string(char *str);
void yyunit_delete_buffer(struct yyunit_buffer_state *buffer);
void yyerror (char const *s);

static Unit *unit_parse_result; /* parsing result gets stored here */
%}

%define parse.error verbose
%define api.prefix {yyunit}

%define api.value.type union
%token <Unit> DOUBLE
%token <Unit> UNIT
%token <int> EXPONENT
%token ERR
%type  <Unit> input expr
/*%type  <int> maybe_exp */

%left '+' '-'
%left '/'
%precedence '*' /* * binds stronger than / */
%left '|'		/* tightly binding division for fractions */

%%

input:
  expr {
	*unit_parse_result = $1;
  }
;

expr:
  DOUBLE
| UNIT
| '(' expr ')' {
	$$ = $2;
  }
| expr EXPONENT {
	int i;
	if ($2 != 1) {
		$$.value = pow($1.value, $2);
		for (i = 0; i < N_UNITS; i++)
			$$.units[i] = $1.units[i] * $2;
	} else {
		$$ = $1;
	}
  }
| expr '+' expr {
	unit_add_internal(&$1, &$3, &$$);
  }
| expr '-' expr {
	unit_sub_internal(&$1, &$3, &$$);
  }
| expr expr %prec '*' {
	unit_mult_internal(&$1, &$2, &$$);
  }
| expr '*' expr {
	unit_mult_internal(&$1, &$3, &$$);
  }
| expr '/' expr {
	unit_div_internal(&$1, &$3, &$$);
  }
| expr '|' expr {
	unit_div_internal(&$1, &$3, &$$);
  }
;

/*
maybe_exp:
  %empty { $$ = 1; }
| EXPONENT
;
*/

%%

/* parse a given string and return the result via the second argument */
int
unit_parse (char *s, Unit *unit)
{
	struct yyunit_buffer_state *buf;
	int ret;

	unit_parse_result = unit;
	buf = yyunit_scan_string(s);
	ret = yyunitparse();
	yyunit_delete_buffer(buf);
	return ret;
}
