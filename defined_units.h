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

	{ 0 }
};

#endif /* _DEFINED_UNITS_H */
