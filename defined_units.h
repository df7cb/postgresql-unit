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

const struct derived_unit_t si_derived_units[] = { /* https://en.wikipedia.org/wiki/International_System_of_Units#Derived_units */
	/* The second is part of this table so we can easily detect its usage for printing it using the hh:mm:ss syntax */
	{ "s",   {  0,  0,  1,  0,  0,  0,  0,  0,} }, /* second          time                                             s */
	{ "Hz",  {  0,  0, -1,  0,  0,  0,  0,  0,} }, /* hertz           frequency                                        s^-1 */
	{ "N",   {  1,  1, -2,  0,  0,  0,  0,  0,} }, /* newton          force, weight                                    kg·m·s^-2 */
	{ "Pa",  { -1,  1, -2,  0,  0,  0,  0,  0,} }, /* pascal          pressure, stress                         N/m^2   kg·m^-1·s^-2 */
	{ "J",   {  2,  1, -2,  0,  0,  0,  0,  0,} }, /* joule           energy, work, heat                       N·m     kg·m^2·s^-2 */
	{ "W",   {  2,  1, -3,  0,  0,  0,  0,  0,} }, /* watt            power, radiant flux                      J/s     kg·m^2·s^-3 */
	{ "C",   {  0,  0,  1,  1,  0,  0,  0,  0,} }, /* coulomb         electric charge                                  s·A */
	{ "V",   {  2,  1, -3, -1,  0,  0,  0,  0,} }, /* volt            voltage                                  W/A     kg·m^2·s^-3·A^-1 */
	{ "F",   { -2, -1,  4,  2,  0,  0,  0,  0,} }, /* farad           electric capacitance                     C/V     kg^-1·m^-2·s^4·A^2 */
	{ "Ω",   {  2,  1, -3, -2,  0,  0,  0,  0,} }, /* ohm             electric resistance, impedance           V/A     kg·m^2·s^-3·A^-2 */
	{ "S",   { -2, -1,  3,  2,  0,  0,  0,  0,} }, /* siemens         electrical conductance                   A/V     kg^-1·m^-2·s^3·A^2 */
	{ "Wb",  {  2,  1, -2, -1,  0,  0,  0,  0,} }, /* weber           magnetic flux                            V·s     kg·m^2·s^-2·A^-1 */
	{ "T",   {  0,  1, -2, -1,  0,  0,  0,  0,} }, /* tesla           magnetic flux density                    Wb/m^2  kg·s^-2·A^-1 */
	{ "H",   {  2,  1, -2, -2,  0,  0,  0,  0,} }, /* henry           inductance                               Wb/A    kg·m^2·s^-2·A^-2 */
	{ "lx",  { -2,  0,  0,  0,  0,  0,  1,  0,} }, /* lux             illuminance                              lm/m^2  m^-2·cd */
	{ "Gy",  {  2,  0, -2,  0,  0,  0,  0,  0,} }, /* gray            absorbed dose (of ionizing radiation)    J/kg    m^2·s^-2 */
	{ "kat", {  0,  0, -1,  0,  0,  1,  0,  0,} }, /* katal           catalytic activity                               mol·s^-1 */
	{ 0 }
};

#endif /* _DEFINED_UNITS_H */
