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
	"cycle",
	"pixel",
};

/* Compromise: Allow the rational exponents but don't use more storage: 1, n/2, n/4 */
const struct derived_unit_t si_derived_units[] = { /* https://en.wikipedia.org/wiki/International_System_of_Units#Derived_units */
	/* The second is part of this table so we can easily detect its usage for printing it using the hh:mm:ss syntax */
	{ "s",  { 0*ONES_DIGIT,  0*ONES_DIGIT,  1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* second          time                                             s */
	{ "Hz", { 0*ONES_DIGIT,  0*ONES_DIGIT, -1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  1*ONES_DIGIT,  0*ONES_DIGIT}, }, /* hertz           frequency                                        s^-1 */
	{ "N",  { 1*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* newton          force, weight                                    kg·m·s^-2 */
	{ "Pa", {-1*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* pascal          pressure, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",  { 2*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* joule           energy, work, heat                       N·m     kg·m^2·s^-2 */
	{ "W",  { 2*ONES_DIGIT,  1*ONES_DIGIT, -3*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* watt            power, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",  { 0*ONES_DIGIT,  0*ONES_DIGIT,  1*ONES_DIGIT,  1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* coulomb         electric charge                                  s·A */
	{ "V",  { 2*ONES_DIGIT,  1*ONES_DIGIT, -3*ONES_DIGIT, -1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",  {-2*ONES_DIGIT, -1*ONES_DIGIT,  4*ONES_DIGIT,  2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",  { 2*ONES_DIGIT,  1*ONES_DIGIT, -3*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",  {-2*ONES_DIGIT, -1*ONES_DIGIT,  3*ONES_DIGIT,  2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb", { 2*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT, -1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",  { 0*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT, -1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",  { 2*ONES_DIGIT,  1*ONES_DIGIT, -2*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
	{ "lx", {-2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* lux             illuminance                              lm/m^2  m^-2·cd */
	{ "Gy", { 2*ONES_DIGIT,  0*ONES_DIGIT, -2*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
	{ "kat",{ 0*ONES_DIGIT,  0*ONES_DIGIT, -1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  1*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT,  0*ONES_DIGIT}, }, /* katal           catalytic activity                               mol·s^-1 */
	{ 0 }
};

#endif /* _DEFINED_UNITS_H */
