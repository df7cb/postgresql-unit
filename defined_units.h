#ifndef _DEFINED_UNITS_H
#define _DEFINED_UNITS_H 1

#include <stdio.h> /* NULL */
#include "unit.h"

const char *base_units[N_UNITS] = {
	"m",
	"kg",
	"s",
	"A",
	"K",
	"mol",
	"cd",
	"B",
};

const struct derived_unit_t derived_units[] = { /* https://en.wikipedia.org/wiki/International_System_of_Units */
	/* name     m  kg   s   A   K  mol cd   B   factor  flags */
	{ "Hz",  "\000\000\377\000\000\000\000\000", 1.0, U_DERIVED }, /* hertz           frequency                                        s^-1 */
	{ "N",   "\001\001\376\000\000\000\000\000", 1.0, U_DERIVED }, /* newton          force, weight                                    kg·m·s^-2 */
	{ "Pa",  "\377\001\376\000\000\000\000\000", 1.0, U_DERIVED }, /* pascal          pressure, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",   "\002\001\376\000\000\000\000\000", 1.0, U_DERIVED }, /* joule           energy, work, heat                       N·m     kg·m^2·s^-2 */
	{ "W",   "\002\001\375\000\000\000\000\000", 1.0, U_DERIVED }, /* watt            power, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",   "\000\000\001\001\000\000\000\000", 1.0, U_DERIVED }, /* coulomb         electric charge                                  s·A */
	{ "V",   "\002\001\375\377\000\000\000\000", 1.0, U_DERIVED }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",   "\376\377\004\002\000\000\000\000", 1.0, U_DERIVED }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",   "\002\001\375\376\000\000\000\000", 1.0, U_DERIVED }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",   "\376\377\003\002\000\000\000\000", 1.0, U_DERIVED }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb",  "\002\001\376\377\000\000\000\000", 1.0, U_DERIVED }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",   "\000\001\376\377\000\000\000\000", 1.0, U_DERIVED }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",   "\002\001\376\376\000\000\000\000", 1.0, U_DERIVED }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
	{ "lx",  "\376\000\000\000\000\000\001\000", 1.0, U_DERIVED }, /* lux             illuminance                              lm/m^2  m^-2·cd */
	{ "Gy",  "\002\000\376\000\000\000\000\000", 1.0, U_DERIVED }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
	{ "kat", "\000\000\377\000\000\001\000\000", 1.0, U_DERIVED }, /* katal           catalytic activity                               mol·s^-1 */

	{ "l",   "\003\000\000\000\000\000\000\000", .001, 0        }, /* liter                                                            1e-3 m^3 */
	{ "g",   "\000\001\000\000\000\000\000\000", .001, 0        }, /* gram                                                             1e-3 kg */
	{ "t",   "\000\001\000\000\000\000\000\000", 1000, 0        }, /* tonne                                                            1e3 kg */
	{ "bar", "\377\001\376\000\000\000\000\000", 100000, 0      }, /* bar                                                              100 kPa */
	{ "min", "\000\000\001\000\000\000\000\000", 60, 0          }, /* minute                                                           60 s */
	{ "h",   "\000\000\001\000\000\000\000\000", 3600, 0        }, /* hour                                                             60 min */
	{ "d",   "\000\000\001\000\000\000\000\000", 86400, 0       }, /* day                                                              24 h */
	{ "a",   "\000\000\001\000\000\000\000\000", 365.25 * 86400, 0 }, /* julian year                                                   365.25 d */
	{ "rad", "\000\000\000\000\000\000\000\000", 1.0, 0         }, /* radian          angle                                            m·m^-1 */
	{ "sr",  "\000\000\000\000\000\000\000\000", 1.0, 0         }, /* steradian       solid angle                                      m^2·m^-2 */
	{ "ohm", "\002\001\375\376\000\000\000\000", 1.0, 0         }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "°C",  "\000\000\000\000\001\000\000\000", 1.0, 0         }, /* degree Celsius  temperature relative to 273.15           K       K */
	{ "lm",  "\000\000\000\000\000\000\001\000", 1.0, 0         }, /* lumen           luminous flux                            cd·sr   cd */
	{ "Bq",  "\000\000\377\000\000\000\000\000", 1.0, 0         }, /* becquerel       radioactivity (decays per unit time)             s^-1 */
	{ "Sv",  "\002\000\376\000\000\000\000\000", 1.0, 0         }, /* sievert         equivalent dose (of ionizing radiation)  J/kg    m^2·s^-2 */

	{ 0 }
};

#endif /* _DEFINED_UNITS_H */
