#include "unit.h"
#include <stdio.h>

void yyerror (char const *s);
void unitprint (Unit *unit);
void parse (char *s);

void
yyerror (char const *s)
{
	fprintf (stderr, "yyerror: %s\n", s);
}

void
unitprint (Unit *unit)
{
	int i;
	printf("%g", unit->value);
	for (i = 0; i < N_UNITS; i++)
		if (unit->units[i] != 0)
			printf(" %s^%d", base_units[i], unit->units[i]);
	printf("\n");
}

void
parse (char *s)
{
	Unit unit;
	printf("%s:\t", s);
	if (unit_parse(s, &unit) > 0)
		printf ("parse error\n");
	else
		unitprint(&unit);
}

int
main (int argc, char **argv)
{
	parse("2 km");
	parse("km");
	parse("2 s^2");
	parse("22");
	parse("4m/s");
	parse("bad");
	parse("9.81 m/s*s");
}
