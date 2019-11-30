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

/* Compromise: Allow the rational exponents but don't use more storage: 1, n/2, n/4 */
const struct derived_unit_t si_derived_units[] = { /* https://en.wikipedia.org/wiki/International_System_of_Units#Derived_units */
	/* The second is part of this table so we can easily detect its usage for printing it using the hh:mm:ss syntax */
	{ "s",  { 0*4,  0*4,  1*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* second          time                                             s */
	{ "Hz", { 0*4,  0*4, -1*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* hertz           frequency                                        s^-1 */
	{ "N",  { 1*4,  1*4, -2*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* newton          force*4, weight                                    kg·m·s^-2 */
	{ "Pa", {-1*4,  1*4, -2*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* pascal          pressure*4, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",  { 2*4,  1*4, -2*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* joule           energy*4, work*4, heat                       N·m     kg·m^2·s^-2 */
	{ "W",  { 2*4,  1*4, -3*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* watt            power*4, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",  { 0*4,  0*4,  1*4,  1*4,  0*4,  0*4,  0*4,  0*4} }, /* coulomb         electric charge                                  s·A */
	{ "V",  { 2*4,  1*4, -3*4, -1*4,  0*4,  0*4,  0*4,  0*4} }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",  {-2*4, -1*4,  4*4,  2*4,  0*4,  0*4,  0*4,  0*4} }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",  { 2*4,  1*4, -3*4, -2*4,  0*4,  0*4,  0*4,  0*4} }, /* ohm             electric resistance*4, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",  {-2*4, -1*4,  3*4,  2*4,  0*4,  0*4,  0*4,  0*4} }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb", { 2*4,  1*4, -2*4, -1*4,  0*4,  0*4,  0*4,  0*4} }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",  { 0*4,  1*4, -2*4, -1*4,  0*4,  0*4,  0*4,  0*4} }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",  { 2*4,  1*4, -2*4, -2*4,  0*4,  0*4,  0*4,  0*4} }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
	{ "lx", {-2*4,  0*4,  0*4,  0*4,  0*4,  0*4,  1*4,  0*4} }, /* lux             illuminance                              lm/m^2  m^-2·cd */
	{ "Gy", { 2*4,  0*4, -2*4,  0*4,  0*4,  0*4,  0*4,  0*4} }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
	{ "kat",{ 0*4,  0*4, -1*4,  0*4,  0*4,  1*4,  0*4,  0*4} }, /* katal           catalytic activity                               mol·s^-1 */
	{ 0 }
};

#endif /* _DEFINED_UNITS_H */
