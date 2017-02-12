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
	{ "m",   {  1,  0,  0,  0,  0,  0,  0,  0,}, 1.0, 0 }, /* meter           length                    */
	{ "kg",  {  0,  1,  0,  0,  0,  0,  0,  0,}, 1.0, 0 }, /* kilogram        mass                      */
	{ "s",   {  0,  0,  1,  0,  0,  0,  0,  0,}, 1.0, 0 }, /* second          time                      */
	{ "A",   {  0,  0,  0,  1,  0,  0,  0,  0,}, 1.0, 0 }, /* ampere          electrical current        */
	{ "K",   {  0,  0,  0,  0,  1,  0,  0,  0,}, 1.0, 0 }, /* kelvin          thermodynamic temperature */
	{ "mol", {  0,  0,  0,  0,  0,  1,  0,  0,}, 1.0, 0 }, /* mole            amount of substance       */
	{ "cd",  {  0,  0,  0,  0,  0,  0,  1,  0,}, 1.0, 0 }, /* candela         luminous intensity        */
	{ "B",   {  0,  0,  0,  0,  0,  0,  0,  1,}, 1.0, 0 }, /* byte            information characters    */

	{ "Hz",  {  0,  0, -1,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* hertz           frequency                                        s^-1 */
	{ "N",   {  1,  1, -2,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* newton          force, weight                                    kg·m·s^-2 */
	{ "Pa",  { -1,  1, -2,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* pascal          pressure, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",   {  2,  1, -2,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* joule           energy, work, heat                       N·m     kg·m^2·s^-2 */
	{ "W",   {  2,  1, -3,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* watt            power, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",   {  0,  0,  1,  1,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* coulomb         electric charge                                  s·A */
	{ "V",   {  2,  1, -3, -1,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",   { -2, -1,  4,  2,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",   {  2,  1, -3, -2,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",   { -2, -1,  3,  2,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb",  {  2,  1, -2, -1,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",   {  0,  1, -2, -1,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",   {  2,  1, -2, -2,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
	{ "lx",  { -2,  0,  0,  0,  0,  0,  1,  0,}, 1.0, U_DERIVED }, /* lux             illuminance                              lm/m^2  m^-2·cd */
	{ "Gy",  {  2,  0, -2,  0,  0,  0,  0,  0,}, 1.0, U_DERIVED }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
	{ "kat", {  0,  0, -1,  0,  0,  1,  0,  0,}, 1.0, U_DERIVED }, /* katal           catalytic activity                               mol·s^-1 */

	{ "l",   {  3,  0,  0,  0,  0,  0,  0,  0,}, .001, 0        }, /* liter                                                            1e-3 m^3 */
	{ "g",   {  0,  1,  0,  0,  0,  0,  0,  0,}, .001, 0        }, /* gram                                                             1e-3 kg */
	{ "t",   {  0,  1,  0,  0,  0,  0,  0,  0,}, 1000, 0        }, /* tonne                                                            1e3 kg */
	{ "bar", { -1,  1, -2,  0,  0,  0,  0,  0,}, 100000, 0      }, /* bar                                                              100 kPa */
	{ "min", {  0,  0,  1,  0,  0,  0,  0,  0,}, 60, 0          }, /* minute                                                           60 s */
//	{ "h",   {  0,  0,  1,  0,  0,  0,  0,  0,}, 3600, 0        }, /* hour                                                             60 min */
	{ "d",   {  0,  0,  1,  0,  0,  0,  0,  0,}, 86400, 0       }, /* day                                                              24 h */
//	{ "a",   {  0,  0,  1,  0,  0,  0,  0,  0,}, 365.25 * 86400, 0 }, /* julian year                                                   365.25 d */
//	{ "rad", {  0,  0,  0,  0,  0,  0,  0,  0,}, 1.0, 0         }, /* radian          angle                                            m·m^-1 */
	{ "sr",  {  0,  0,  0,  0,  0,  0,  0,  0,}, 1.0, 0         }, /* steradian       solid angle                                      m^2·m^-2 */
	{ "ohm", {  2,  1, -3, -2,  0,  0,  0,  0,}, 1.0, 0         }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "°C",  {  0,  0,  0,  0,  1,  0,  0,  0,}, 1.0, 0         }, /* degree Celsius  temperature relative to 273.15           K       K */
	{ "lm",  {  0,  0,  0,  0,  0,  0,  1,  0,}, 1.0, 0         }, /* lumen           luminous flux                            cd·sr   cd */
	{ "Bq",  {  0,  0, -1,  0,  0,  0,  0,  0,}, 1.0, 0         }, /* becquerel       radioactivity (decays per unit time)             s^-1 */
	{ "Sv",  {  2,  0, -2,  0,  0,  0,  0,  0,}, 1.0, 0         }, /* sievert         equivalent dose (of ionizing radiation)  J/kg    m^2·s^-2 */

	/* United States customary units */
	{ "in",  {  1,  0,  0,  0,  0,  0,  0,  0,}, .0254, 0       }, /* inch                                                             25.4 mm */
	{ "ft",  {  1,  0,  0,  0,  0,  0,  0,  0,}, .3048, 0       }, /* foot                                                             0.3048 m */
	{ "yd",  {  1,  0,  0,  0,  0,  0,  0,  0,}, .9144, 0       }, /* yard                                                             0.9144 m */
	{ "mi",  {  1,  0,  0,  0,  0,  0,  0,  0,}, 1609.344, 0    }, /* mile                                                             1.609344 km */
	{ "oz",  {  0,  1,  0,  0,  0,  0,  0,  0,}, .028349523125, 0 }, /* ounce                                                          28.349523125 g */
	{ "lb",  {  0,  1,  0,  0,  0,  0,  0,  0,}, .45359237, 0   }, /* pound                                                            453.59237 g */

	{ 0 }
};

const struct prefixes_t
unit_predefined_prefixes[] = {
	{ "y",  1e-24 },
	{ "z",  1e-21 },
	{ "a",  1e-18 },
	{ "f",  1e-15 },
	{ "p",  1e-12 },
	{ "n",  1e-9 },
	{ "µ",  1e-6 },
	{ "mu", 1e-6 },
	{ "m",  1e-3 },
	{ "c",  1e-2 },
	{ "d",  1e-1 },

	{ "da", 1e1 },
	{ "h",  1e2 },
	{ "k",  1e3 },
	{ "M",  1e6 },
	{ "G",  1e9 },
	{ "T",  1e12 },
	{ "P",  1e15 },
	{ "E",  1e18 },
	{ "Z",  1e21 },
	{ "Y",  1e24 },

	{ "Ki", 0x1p+10 },
	{ "Mi", 0x1p+20 },
	{ "Gi", 0x1p+30 },
	{ "Ti", 0x1p+40 },
	{ "Pi", 0x1p+50 },
	{ "Ei", 0x1p+60 },
	{ "Zi", 0x1p+70 },
	{ "Yi", 0x1p+80 },

	{ 0 },
};

#endif /* _DEFINED_UNITS_H */
