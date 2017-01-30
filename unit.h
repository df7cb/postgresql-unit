#ifndef _UNIT_H
#define _UNIT_H 1

#include <postgres.h>
#include <utils/hsearch.h>

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

/* defined units */

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

struct prefixes_t {
	char		*prefix;
	double		 factor;
};

extern const struct prefixes_t unit_predefined_prefixes[];

/* type def */

typedef struct Unit {
	double			value;
	signed char		units[N_UNITS];
} Unit;

/* hash table and regex interface */

extern HTAB		*unit_names;

typedef struct unit_names_t {
	char		 name[UNIT_NAME_LENGTH];
	Unit		 unit;
} unit_names_t;

typedef struct unit_dimensions_t {
	char		 units[N_UNITS];
	char		 name[UNIT_NAME_LENGTH];
} unit_dimensions_t;

/* parser interface */

int unit_parse (char *s, Unit *unit); /* in unit.y */

char *unit_cstring (Unit *unit);

/* static functions */

/* test if two Units have the same dimension */
static inline void
test_same_dimension (char *op, Unit *a, Unit *b)
{
	if (memcmp(a->units, b->units, N_UNITS))
		ereport(ERROR,
				(errcode(ERRCODE_DATA_EXCEPTION),
				 errmsg("dimension mismatch in \"%s\" operation: \"%s\", \"%s\"",
					 op, unit_cstring(a), unit_cstring(b))));
}

static inline void
unit_add_internal (Unit *a, Unit *b, Unit *result)
{
	test_same_dimension("+", a, b);
	result->value = a->value + b->value;
	memcpy(result->units, a->units, N_UNITS);
}

static inline void
unit_sub_internal (Unit *a, Unit *b, Unit *result)
{
	test_same_dimension("-", a, b);
	result->value = a->value - b->value;
	memcpy(result->units, a->units, N_UNITS);
}

static inline void
unit_mult_internal (Unit *a, Unit *b, Unit *result)
{
	int		 i;

	result->value = a->value * b->value;
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = a->units[i] + b->units[i];
}

static inline void
unit_div_internal (Unit *a, Unit *b, Unit *result)
{
	int		 i;

	if (b->value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"",
					 unit_cstring(b))));

	result->value = a->value / b->value;
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = a->units[i] - b->units[i];
}

#endif /* _UNIT_H */
