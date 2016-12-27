/*
Copyright (C) 2016 Christoph Berg

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
*/

#include "postgres.h"
#include "fmgr.h"
#include "utils/guc.h"
#include <math.h>

#include "unit.h"
#include "defined_units.h"
#include "powers.h"

#if PG_VERSION_NUM >= 90600
#include "utils/builtins.h" /* float8out_internal */
#else

/* minimal version of PG 9.6's float8out_internal function for use in 9.4 and 9.5 */
#define MAXDOUBLEWIDTH	128
#define DBL_DIG			15
extern int		extra_float_digits;

static char *
float8out_internal(double num)
{
	char	   *ascii = (char *) palloc(MAXDOUBLEWIDTH + 1);
	int			ndig = DBL_DIG + extra_float_digits;

	if (isnan(num))
		return strcpy(ascii, "NaN");

	if (ndig < 1)
		ndig = 1;

	snprintf(ascii, MAXDOUBLEWIDTH + 1, "%.*g", ndig, num);

	return ascii;
}

#endif /* PG_VERSION_NUM */

/* module initialization */

PG_MODULE_MAGIC;

static bool unit_byte_output_iec;

void _PG_init(void);

void
_PG_init(void)
{
	DefineCustomBoolVariable("unit.byte_output_iec",
			"Output byte unit values with binary IEC prefixes",
			"Set to on to output byte unit values using binary IEC prefixes "
			"instead of decimal SI prefixes",
			&unit_byte_output_iec,
			false,
			PGC_USERSET,
			0, /* no flags */
			NULL,
			NULL,
			NULL);

	EmitWarningsOnPlaceholders("unit");
}

/* internal functions */

/* format Unit as string */
static char *
unit_cstring (Unit *unit)
{
	int		 i;
	int		 n_numerator = 0;
	int		 u_numerator = -1;
	int		 derived_unit = -1;
	char	*output;
	char	*output_p;
	bool	 numerator = false;
	bool	 denominator = false;

	/* check if this is a combination of base units we have a specific name for */
	for (i = 0; derived_units[i].name && derived_units[i].flags & U_DERIVED; i++)
		if (! memcmp(unit->units, derived_units[i].units, N_UNITS))
		{
			derived_unit = i;
			break;
		}
	if (derived_unit == -1) /* otherwise, sum up positive exponents */
		for (i = 0; i < N_UNITS; i++) {
			if (unit->units[i] > 0) {
				n_numerator += unit->units[i];
				u_numerator = i;
			}
		}

	output_p = output = palloc(128);
#define print_output(...) output_p += sprintf(output_p, __VA_ARGS__);

	/* case 1a: kg in numerator (exponent 1): print with SI prefix */
	if (n_numerator == 1 && u_numerator == UNIT_kg) {
		double	 v_abs = fabs(unit->value);
		char	*prefix = "k";
		double	 factor = 1.0;

		if (v_abs >= POWER_24) {
			/* do nothing */
		} else if (v_abs >= POWER_21) {
			prefix = "Y"; factor = 1e-21;
		} else if (v_abs >= POWER_18) {
			prefix = "Z"; factor = 1e-18;
		} else if (v_abs >= POWER_15) {
			prefix = "E"; factor = 1e-15;
		} else if (v_abs >= POWER_12) {
			prefix = "P"; factor = 1e-12;
		} else if (v_abs >= POWER_9) {
			prefix = "T"; factor = 1e-9;
		} else if (v_abs >= POWER_6) {
			prefix = "G"; factor = 1e-6;
		} else if (v_abs >= POWER_3) {
			prefix = "M"; factor = 1e-3;
		} else if (v_abs >= POWER_0) {
			prefix = "k";
		} else if (v_abs >= POWER__3) {
			prefix = "";  factor = 1e3;
		} else if (v_abs >= POWER__6) {
			prefix = "m"; factor = 1e6;
		} else if (v_abs >= POWER__9) {
			prefix = "µ"; factor = 1e9;
		} else if (v_abs >= POWER__12) {
			prefix = "n"; factor = 1e12;
		} else if (v_abs >= POWER__15) {
			prefix = "p"; factor = 1e15;
		} else if (v_abs >= POWER__18) {
			prefix = "f"; factor = 1e18;
		} else if (v_abs >= POWER__21) {
			prefix = "a"; factor = 1e21;
		} else if (v_abs >= POWER__24) {
			prefix = "z"; factor = 1e24;
		} else if (v_abs >= POWER__27) {
			prefix = "y"; factor = 1e27;
		} /* else: smaller value or 0 (or -0), print using kg */

		print_output("%s %sg", float8out_internal (unit->value * factor),
				prefix); /* gram with SI prefix */
		numerator = true;

	/* case 1b: byte in numerator (exponent 1), and binary IEC prefix requested */
	} else if (n_numerator == 1 && u_numerator == UNIT_B && unit_byte_output_iec) {
		double	 v_abs = fabs(unit->value);
		char	*prefix = "";
		double	 factor = 1.0;

		if (v_abs >= 0x1p+90) {
			// do nothing
		} else if (v_abs >= 0x1p+80) {
			prefix = "Yi"; factor = 0x1p-80;
		} else if (v_abs >= 0x1p+70) {
			prefix = "Zi"; factor = 0x1p-70;
		} else if (v_abs >= 0x1p+60) {
			prefix = "Ei"; factor = 0x1p-60;
		} else if (v_abs >= 0x1p+50) {
			prefix = "Pi"; factor = 0x1p-50;
		} else if (v_abs >= 0x1p+40) {
			prefix = "Ti"; factor = 0x1p-40;
		} else if (v_abs >= 0x1p+30) {
			prefix = "Gi"; factor = 0x1p-30;
		} else if (v_abs >= 0x1p+20) {
			prefix = "Mi"; factor = 0x1p-20;
		} else if (v_abs >= 0x1p+10) {
			prefix = "Ki"; factor = 0x1p-10;
		} /* else do nothing */

		print_output("%s %sB", float8out_internal (unit->value * factor),
				prefix); /* byte with binary prefix */
		numerator = true;

	/* case 2: derived unit, or numerator with exactly one unit (exponent 1)
	 * not covered above */
	} else if (derived_unit >= 0 || n_numerator == 1) {
		double	 v_abs = fabs(unit->value);
		char	*prefix = "";
		double	 factor = 1.0;

		if (v_abs >= 1e27) {
			// do nothing
		} else if (v_abs >= POWER_24) {
			prefix = "Y"; factor = 1e-24;
		} else if (v_abs >= POWER_21) {
			prefix = "Z"; factor = 1e-21;
		} else if (v_abs >= POWER_18) {
			prefix = "E"; factor = 1e-18;
		} else if (v_abs >= POWER_15) {
			prefix = "P"; factor = 1e-15;
		} else if (v_abs >= POWER_12) {
			prefix = "T"; factor = 1e-12;
		} else if (v_abs >= POWER_9) {
			prefix = "G"; factor = 1e-9;
		} else if (v_abs >= POWER_6) {
			prefix = "M"; factor = 1e-6;
		} else if (v_abs >= POWER_3) {
			prefix = "k"; factor = 1e-3;
		} else if (v_abs >= POWER_0) {
			// do nothing
		} else if (v_abs >= POWER__3) {
			prefix = "m"; factor = 1e3;
		} else if (v_abs >= POWER__6) {
			prefix = "µ"; factor = 1e6;
		} else if (v_abs >= POWER__9) {
			prefix = "n"; factor = 1e9;
		} else if (v_abs >= POWER__12) {
			prefix = "p"; factor = 1e12;
		} else if (v_abs >= POWER__15) {
			prefix = "f"; factor = 1e15;
		} else if (v_abs >= POWER__18) {
			prefix = "a"; factor = 1e18;
		} else if (v_abs >= POWER__21) {
			prefix = "z"; factor = 1e21;
		} else if (v_abs >= POWER__24) {
			prefix = "y"; factor = 1e24;
		} /* else do nothing */

		/* case 2a: derived unit, print with SI prefix and exit */
		if (derived_unit >= 0) {
			print_output("%s %s%s", float8out_internal (unit->value * factor),
					prefix, derived_units[i].name);
			return output;
		}

		/* case 2b: single unit in numerator (exponent 1), print with SI prefix and continue */
		print_output("%s %s%s", float8out_internal (unit->value * factor),
				prefix, base_units[u_numerator]);
		numerator = true;

	/* case 3: zero or more than one unit in numerator */
	} else {
		/* always use scientific notation here */
		print_output("%s", float8out_internal (unit->value));

		for (i = 0; i < N_UNITS; i++) /* format units in numerator */
			if (unit->units[i] > 0) {
				print_output("%s%s", numerator ? "*" : " ", base_units[i]);
				if (unit->units[i] > 1)
					print_output("^%d", unit->units[i]);
				numerator = true;
			}
	}

	/* print units in denominator */
	for (i = 0; i < N_UNITS; i++) /* format units in denominator */
		if (unit->units[i] < 0) {
			if (numerator) { /* format as .../a^x*b^y */
				print_output("%s%s", denominator ? "*" : "/", base_units[i]);
				if (unit->units[i] < -1)
					print_output("^%d", -unit->units[i]);
			} else { /* format as a^-x*b^-y */
				print_output("%s%s^%d", denominator ? "*" : " ", base_units[i], unit->units[i]);
			}
			denominator = true;
		}

	/* done */
	return output;
}

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

/* input and output */

char *yyerrstr; /* copy of error catched by yyuniterror() */

void yyuniterror (char *s);

void
yyuniterror (char *s)
{
	/* store error for later use in unit_in */
	yyerrstr = pstrdup(s);
}

PG_FUNCTION_INFO_V1 (unit_in);

Datum
unit_in (PG_FUNCTION_ARGS)
{
	char	*str = PG_GETARG_CSTRING(0);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	if (unit_parse(str, result) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 str, yyerrstr)));
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_out);

Datum
unit_out(PG_FUNCTION_ARGS)
{
	Unit	*unit = (Unit *) PG_GETARG_POINTER(0);
	PG_RETURN_CSTRING(unit_cstring(unit));
}

/* constructors */

PG_FUNCTION_INFO_V1 (dbl2unit);

Datum
dbl2unit (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_meter);

Datum
unit_meter (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_m] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_kilogram);

Datum
unit_kilogram (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_kg] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_second);

Datum
unit_second (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_s] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_ampere);

Datum
unit_ampere (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_A] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_kelvin);

Datum
unit_kelvin (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_K] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_mole);

Datum
unit_mole (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_mol] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_candela);

Datum
unit_candela (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_cd] = 1;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1 (unit_byte);

Datum
unit_byte (PG_FUNCTION_ARGS)
{
	Unit	*result;

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = PG_GETARG_FLOAT8(0);
	result->units[UNIT_B] = 1;
	PG_RETURN_POINTER(result);
}

/* extractors */

PG_FUNCTION_INFO_V1(unit_value);

Datum
unit_value(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);

	PG_RETURN_FLOAT8(a->value);
}

PG_FUNCTION_INFO_V1(unit_dimension);

Datum
unit_dimension(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = 1;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

/* operators */

PG_FUNCTION_INFO_V1(unit_add);

Datum
unit_add(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;

	test_same_dimension("+", a, b);
	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value + b->value;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_sub);

Datum
unit_sub(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;

	test_same_dimension("-", a, b);
	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value - b->value;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_neg);

Datum
unit_neg(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = - a->value;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_mul);

Datum
unit_mul(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;
	int		 i;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value * b->value;
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = a->units[i] + b->units[i];
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(dbl_unit_mul);

Datum
dbl_unit_mul(PG_FUNCTION_ARGS)
{
	double	 a = PG_GETARG_FLOAT8(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a * b->value;
	memcpy(result->units, b->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_dbl_mul);

Datum
unit_dbl_mul(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	double	 b = PG_GETARG_FLOAT8(1);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value * b;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_div);

Datum
unit_div(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;
	int		 i;

	if (b->value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"",
					 unit_cstring(b))));

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value / b->value;
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = a->units[i] - b->units[i];
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(dbl_unit_div);

Datum
dbl_unit_div(PG_FUNCTION_ARGS)
{
	double	 a = PG_GETARG_FLOAT8(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;
	int		 i;

	if (b->value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"",
					 unit_cstring(b))));

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a / b->value;
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = - b->units[i];
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_dbl_div);

Datum
unit_dbl_div(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	double	 b = PG_GETARG_FLOAT8(1);
	Unit	*result;

	if (b == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division of unit by zero")));

	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value / b;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_pow);

Datum
unit_pow(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	int		 b = PG_GETARG_INT32(1);
	Unit	*result;
	int		 i;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = pow(a->value, b);
	for (i = 0; i < N_UNITS; i++)
		result->units[i] = a->units[i] * b;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_at);

Datum
unit_at(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	char	*b = PG_GETARG_CSTRING(1);
	Unit	 bu;
	//int		 i;

	if (unit_parse(b, &bu) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 b, yyerrstr)));
	test_same_dimension("@", a, &bu);
	if (bu.value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"", b)));
	PG_RETURN_CSTRING(psprintf("%s %s%s",
				float8out_internal (a->value / bu.value),
				(atof(b) > 0 ? "* " : ""),
				b));
}

/* comparisons */

static int
unit_cmp_internal(Unit *a, Unit *b)
{
	if (a->value < b->value)
		return -1;
	if (a->value > b->value)
		return 1;
	return memcmp(a->units, b->units, N_UNITS);
}

PG_FUNCTION_INFO_V1(unit_lt);

Datum
unit_lt(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) < 0);
}

PG_FUNCTION_INFO_V1(unit_le);

Datum
unit_le(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) <= 0);
}

PG_FUNCTION_INFO_V1(unit_eq);

Datum
unit_eq(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) == 0);
}

PG_FUNCTION_INFO_V1(unit_ne);

Datum
unit_ne(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) != 0);
}

PG_FUNCTION_INFO_V1(unit_ge);

Datum
unit_ge(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) >= 0);
}

PG_FUNCTION_INFO_V1(unit_gt);

Datum
unit_gt(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_BOOL(unit_cmp_internal(a, b) > 0);
}

PG_FUNCTION_INFO_V1(unit_cmp);

Datum
unit_cmp(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	PG_RETURN_INT32(unit_cmp_internal(a, b));
}

PG_FUNCTION_INFO_V1(unit_least);

Datum
unit_least(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	test_same_dimension("unit_least", a, b);
	if (unit_cmp_internal(a, b) <= 0)
		PG_RETURN_POINTER(a);
	PG_RETURN_POINTER(b);
}

PG_FUNCTION_INFO_V1(unit_greatest);

Datum
unit_greatest(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);

	test_same_dimension("unit_greatest", a, b);
	if (unit_cmp_internal(a, b) >= 0)
		PG_RETURN_POINTER(a);
	PG_RETURN_POINTER(b);
}

