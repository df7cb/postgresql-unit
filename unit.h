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

#define UNIT_NAME_LENGTH 32
/* longest unit names (without prefixes) observed in definitions.units:
 * hardtranslucentarkansas (23 chars)
 * venezuelanbolivarfuerte */

extern const char *base_units[N_UNITS]; /* names of base units */

typedef enum unit_flags {
	U_DERIVED = 1,
} unit_flags;

struct derived_unit_t {
	char		*name;
	signed char	 units[N_UNITS];
	double		 factor;
	unit_flags	 flags;
};

extern const struct derived_unit_t derived_units[];

typedef struct Unit {
	double			value;
	signed char		units[N_UNITS];
} Unit;

typedef struct unit_names_t {
	char		 name[UNIT_NAME_LENGTH];
	Unit		 unit;
} unit_names_t;

typedef struct unit_dimensions_t {
	char		 units[N_UNITS];
	char		 name[UNIT_NAME_LENGTH];
} unit_dimensions_t;

int unit_parse (char *s, Unit *unit); /* in unit.y */

#endif /* _UNIT_H */
