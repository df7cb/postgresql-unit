%{
#include "unit.h"
#include "unitparse.tab.h"
%}

%option noyywrap
%option nounput
%option noinput

DOUBLE_R [\-+]?[0-9]*\.?[0-9]+([eE][\-+]?[0-9]+)?
PREFIX_R (y|z|a|f|p|n|µ|mu|m|c|d|da|h|k|M|G|T|P|E|Z|Y)
UNIT_R   (m|g|s|A|K|mol|cd|B|rad|sr|Hz|N|Pa|J|W|C|V|F|Ω|ohm|S|Wb|T|H|°C|lm|lx|Bq|Gy|Sv|kat)
EXP_R    \^[\-+]?[0-9]+

%%

{DOUBLE_R} {
	yyunitlval.DOUBLE = atof(yytext);
	return DOUBLE;
}

{PREFIX_R}/{UNIT_R}  {
	#define when(x) if (!strcmp(yytext, x))
	     when ("y") yyunitlval.DOUBLE = 1e-24;
	else when ("z") yyunitlval.DOUBLE = 1e-21;
	else when ("a") yyunitlval.DOUBLE = 1e-18;
	else when ("f") yyunitlval.DOUBLE = 1e-15;
	else when ("p") yyunitlval.DOUBLE = 1e-12;
	else when ("n") yyunitlval.DOUBLE = 1e-9;
	else when ("µ") yyunitlval.DOUBLE = 1e-6;
	else when ("mu") yyunitlval.DOUBLE = 1e-6;
	else when ("m") yyunitlval.DOUBLE = 1e-3;
	else when ("c") yyunitlval.DOUBLE = 1e-2;
	else when ("d") yyunitlval.DOUBLE = 1e-1;

	else when ("da") yyunitlval.DOUBLE = 1e1;
	else when ("h") yyunitlval.DOUBLE = 1e2;
	else when ("k") yyunitlval.DOUBLE = 1e3;
	else when ("M") yyunitlval.DOUBLE = 1e6;
	else when ("G") yyunitlval.DOUBLE = 1e9;
	else when ("T") yyunitlval.DOUBLE = 1e12;
	else when ("P") yyunitlval.DOUBLE = 1e15;
	else when ("E") yyunitlval.DOUBLE = 1e18;
	else when ("Z") yyunitlval.DOUBLE = 1e21;
	else when ("Y") yyunitlval.DOUBLE = 1e24;
	return PREFIX;
	#undef when
}

{UNIT_R}    {
	int i;
	yyunitlval.UNIT.value = 1;
	/* check if this is a base unit */
	for (i = 0; i < N_UNITS; i++) {
		if (!strcmp(yytext, base_units[i])) {
			bzero(&yyunitlval.UNIT.units, N_UNITS);
			yyunitlval.UNIT.units[i] = 1;
			return UNIT;
		}
	}
	/* the obnoxious kg */
	if (!strcmp(yytext, "g")) {
		yyunitlval.UNIT.value = 1.0/1000.0;
		bzero(&yyunitlval.UNIT.units, N_UNITS);
		yyunitlval.UNIT.units[UNIT_kg] = 1;
		return UNIT;
	}
	/* check if this is a combination of base units we have a specific name for */
	for (i = 0; derived_units[i].name; i++)
		if (!strcmp(derived_units[i].name, yytext))
		{
			yyunitlval.UNIT.value = derived_units[i].factor;
			memcpy(&yyunitlval.UNIT.units, derived_units[i].units, N_UNITS);
			return UNIT;
		}
	/* should not happen */
	return 1; /* error */
}

{EXP_R} {
	yyunitlval.EXPONENT = atoi(yytext+1);
	return EXPONENT;
}

\* return '*';
\/ return '/';

[ \t\n]* /* eat whitespace */

. return 1; /* error */
