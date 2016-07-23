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

/* derived units */
#define UNIT_Hz		8
#define UNIT_N		9

struct derived_unit_t {
	char		*name;
	signed char	 units[N_UNITS];
};

struct derived_unit_t derived_units[] = { /* https://en.wikipedia.org/wiki/International_System_of_Units */
			/*  m  kg   s   A   K  mol cd   B  */
	{ "m",   "\001\000\000\000\000\000\000\000" }, /* meter                                                                 */
	{ "g",   "\000\001\000\000\000\000\000\000" }, /* gram (!)                                                              */
	{ "s",   "\000\000\001\000\000\000\000\000" }, /* second                                                                */
	{ "A",   "\000\000\000\001\000\000\000\000" }, /* ampere                                                                */
	{ "K",   "\000\000\000\000\001\000\000\000" }, /* kelvin                                                                */
	{ "mol", "\000\000\000\000\000\001\000\000" }, /* mole                                                                  */
	{ "cd",  "\000\000\000\000\000\000\001\000" }, /* candela                                                               */
	{ "B",   "\000\000\000\000\000\000\000\001" }, /* byte                                                                  */

//	{ "rad", "\000\000\000\000\000\000\000\000" }, /* radian          angle                                            m·m^-1 */
//	{ "sr",  "\000\000\000\000\000\000\000\000" }, /* steradian       solid angle                                      m^2·m^-2 */
	{ "Hz",  "\000\000\377\000\000\000\000\000" }, /* hertz           frequency                                        s^-1 */
	{ "N",   "\001\001\376\000\000\000\000\000" }, /* newton          force, weight                                    kg·m·s^-2 */
	{ "Pa",  "\377\001\376\000\000\000\000\000" }, /* pascal          pressure, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",   "\002\001\376\000\000\000\000\000" }, /* joule           energy, work, heat                       N·m     kg·m^2·s^-2 */
	{ "W",   "\002\001\375\000\000\000\000\000" }, /* watt            power, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",   "\000\000\001\001\000\000\000\000" }, /* coulomb         electric charge                                  s·A */
	{ "V",   "\002\001\375\377\000\000\000\000" }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",   "\376\377\004\002\000\000\000\000" }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",   "\002\001\375\376\000\000\000\000" }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",   "\376\377\003\002\000\000\000\000" }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb",  "\002\001\376\377\000\000\000\000" }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",   "\000\001\376\377\000\000\000\000" }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",   "\002\001\376\376\000\000\000\000" }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
//	{ "°C",  "\000\000\000\000\000\000\000\000" }, /* degree Celsius  temperature relative to 273.15           K       K */
//	{ "lm",  "\000\000\000\000\000\000\000\000" }, /* lumen           luminous flux                            cd·sr   cd */
	{ "lx",  "\376\000\000\000\000\000\001\000" }, /* lux             illuminance                              lm/m^2  m^-2·cd */
//	{ "Bq",  "\000\000\000\000\000\000\000\000" }, /* becquerel       radioactivity (decays per unit time)             s^-1 */
	{ "Gy",  "\002\000\376\000\000\000\000\000" }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
//	{ "Sv",  "\000\000\000\000\000\000\000\000" }, /* sievert         equivalent dose (of ionizing radiation)  J/kg    m^2·s^-2 */
	{ "kat", "\000\000\377\000\000\001\000\000" }, /* katal           catalytic activity                               mol·s^-1 */

//	{ "m/s", "\001\000\377\000\000\000\000\000" }, /* meter/second    velocity                                              */
//	{ "B/s", "\001\000\000\000\000\000\000\377" }, /* byte/second     bandwidth                                             */

	{ NULL, {NULL} }
};

/* constant */
#define UNIT_unity	0

typedef struct Unit {
	double			value;
	signed char		units[N_UNITS];
} Unit;

