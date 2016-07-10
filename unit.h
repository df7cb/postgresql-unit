#define UNIT_m		0 /* meter */
#define UNIT_kg		1 /* kilogram */
#define UNIT_s		2 /* second */
#define UNIT_A		3 /* ampere */
#define UNIT_K		4 /* kelvin */
#define UNIT_mol	5 /* mole */
#define UNIT_cd		6 /* candela */
#define UNIT_B		7 /* byte */

#define N_UNITS		8

typedef struct Unit {
	double			value;
	unsigned char	units[N_UNITS];
} Unit;
