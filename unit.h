#ifndef _UNIT_H
#define _UNIT_H 1

/* indices */
#define UNIT_m		0 /* meter */
#define UNIT_kg		1 /* kilogram */
#define UNIT_s		2 /* second */
#define UNIT_A		3 /* ampere */
#define UNIT_K		4 /* kelvin */
#define UNIT_mol	5 /* mole */
#define UNIT_cd		6 /* candela */
#define UNIT_B		7 /* byte */

#define N_UNITS		8

extern const char *base_units[N_UNITS];

struct derived_unit_t {
	char		*name;
	signed char	 units[N_UNITS];
};

extern const struct derived_unit_t derived_units[];

typedef struct Unit {
	double			value;
	signed char		units[N_UNITS];
} Unit;

int unit_parse (char *s, Unit *unit); /* in unit.y */

#endif /* _UNIT_H */
