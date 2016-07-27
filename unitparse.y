%{
#include <strings.h> /* bzero */
#include <math.h> /* pow */
#include "unit.h"

/* flex/bison prototypes */
int yylex (void);
struct yyunit_buffer_state *yyunit_scan_string(char *str);
void yyunit_delete_buffer(struct yyunit_buffer_state *buffer);
void yyerror (char const *s);

static Unit *yyunit; /* parsing result gets stored here */
%}

%define parse.error verbose
%define api.prefix {yyunit}

%define api.value.type union
%token <double> DOUBLE
%token <double> PREFIX
%token <Unit> UNIT
%token <int> EXPONENT
%type  <double> dbl maybe_prefix;
%type  <Unit> input dimension
%type  <int> maybe_exp

%left '/'
%precedence '*' /* * binds stronger than / */

%%

input:
  dbl dimension {
	int i;
	yyunit->value = $1 * $2.value;
	for (i = 0; i < N_UNITS; i++)
		yyunit->units[i] = $2.units[i];
  }
;

dbl:
  %empty { $$ = 1.0; }
| DOUBLE
;

dimension:
  %empty { $$.value = 1.0; bzero(&$$.units, N_UNITS); }
| maybe_prefix UNIT maybe_exp {
	int i;
	if ($3 != 1) {
		$$.value = pow($1 * $2.value, $3);
		for (i = 0; i < N_UNITS; i++)
			$$.units[i] = $2.units[i] * $3;
	} else {
		$$.value = $1 * $2.value;
		for (i = 0; i < N_UNITS; i++)
			$$.units[i] = $2.units[i];
	}
  }
| dimension '*' dimension {
	int i;
	$$.value = $1.value * $3.value;
	for (i = 0; i < N_UNITS; i++)
		$$.units[i] = $1.units[i] + $3.units[i];
  }
| dimension '/' dimension {
	int i;
	$$.value = $1.value / $3.value;
	for (i = 0; i < N_UNITS; i++)
		$$.units[i] = $1.units[i] - $3.units[i];
  }
;

maybe_prefix:
  %empty { $$ = 1.0; }
| PREFIX
;

maybe_exp:
  %empty { $$ = 1; }
| EXPONENT
;

%%

/* parse a given string and return the result via the second argument */
int
unit_parse (char *s, Unit *unit)
{
	struct yyunit_buffer_state *buf;
	int ret;

	yyunit = unit;
	buf = yyunit_scan_string(s);
	ret = yyunitparse();
	yyunit_delete_buffer(buf);
	return ret;
}
