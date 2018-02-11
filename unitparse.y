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
#include <strings.h> /* bzero */
#include <math.h> /* pow */
#include "unit.h"

/* flex/bison prototypes */
int yylex (void);
struct yyunit_buffer_state *yyunit_scan_string(char *str);
void yyunit_delete_buffer(struct yyunit_buffer_state *buffer);
void yyerror (char const *s);

static UnitShift *unit_parse_result; /* parsing result gets stored here */
%}

%define parse.error verbose
%define api.prefix {yyunit}

%define api.value.type union
%token <double> DOUBLE
%token <UnitShift> UNIT_SHIFT
%token <int> EXPONENT SUPER_SIGN SUPER
%token ERR
%type  <UnitShift> input expr simple_expr
%type  <double> number
%type  <int> exponent super

%left '+' '-'
%left '/'
%left '*' /* * binds stronger than / */
%left UMINUS	/* unary minus */

%%

input:
  expr {
	*unit_parse_result = $1;
  }
;

expr:
  simple_expr
/* accept only simple expressions after unary sign to disambiguate
 * (-N)N from -(NN): (-273.15)°C is not the same as -(273.15°C) */
| '+' simple_expr %prec UMINUS {
	$$ = $2;
	$$.shift = 0.0;
  }
| '-' simple_expr %prec UMINUS {
	$$ = $2;
	$$.unit.value = -$$.unit.value;
	$$.shift = 0.0;
  }
| expr exponent {
	int i;
	if ($2 != 1) {
		$$.unit.value = pow($1.unit.value, $2);
		for (i = 0; i < N_UNITS; i++)
			$$.unit.units[i] = $1.unit.units[i] * $2;
	} else {
		$$ = $1;
	}
	$$.shift = 0.0;
  }
| expr '+' expr {
	unit_add_internal(&$1.unit, &$3.unit, &$$.unit);
	$$.shift = 0.0;
  }
| expr '-' expr {
	unit_sub_internal(&$1.unit, &$3.unit, &$$.unit);
	$$.shift = 0.0;
  }
| expr expr %prec '*' {
	unit_mult_internal(&$1.unit, &$2.unit, &$$.unit);
	$$.unit.value += $2.shift; /* shift is evaluated exactly here */
	$$.shift = 0.0;
  }
| expr '*' expr {
	unit_mult_internal(&$1.unit, &$3.unit, &$$.unit);
	$$.shift = 0.0;
  }
| expr '/' expr {
	unit_div_internal(&$1.unit, &$3.unit, &$$.unit);
	$$.shift = 0.0;
  }
| '/' expr {
	Unit nominator = { 1.0, {0} };
	unit_div_internal(&nominator, &$2.unit, &$$.unit);
	$$.shift = 0.0;
  }
;

simple_expr:
  number {
	$$.unit.value = $1;
	memset(&$$.unit.units, 0, N_UNITS);
	$$.shift = 0.0;
  }
| UNIT_SHIFT
| '(' expr ')' {
	$$ = $2;
	$$.shift = 0.0;
  }

number:
  DOUBLE
| DOUBLE '|' DOUBLE {
    $$ = $1 / $3;
  }

exponent:
  EXPONENT
| SUPER_SIGN super { $$ = $1 * $2; }
| super
;

super:
  SUPER
| SUPER super { $$ = 10 * $1 + $2; }
;

%%

/* parse a given string and return the result via the second argument */
int
unit_parse (char *s, UnitShift *unit_shift)
{
	struct yyunit_buffer_state *buf;
	int ret;

	unit_parse_result = unit_shift;
	buf = yyunit_scan_string(s);
	ret = yyunitparse();
	yyunit_delete_buffer(buf);
	return ret;
}
