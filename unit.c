/*
Copyright (C) 2016-2018 Christoph Berg

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
#include "utils/builtins.h" /* cstring_to_text (needed on 9.5) */
#include "utils/guc.h"
#include "utils/hsearch.h"
#include <math.h>

#include "unit.h"
#include "defined_units.h"
#include "powers.h"

#if PG_VERSION_NUM >= 90600
#include "utils/builtins.h" /* float8out_internal */
#else
#include "float8out_internal.h"
#endif

/* global variables */

static bool unit_output_superscript;
static bool unit_time_output_custom;
static bool unit_byte_output_iec;
static bool unit_output_base_units;

HTAB		*unit_names;
static HTAB *unit_dimensions;

/* unit definitions */

void unit_get_definitions(void);

void
unit_get_definitions(void)
{
	HASHCTL				 hinfo = { 0 };
	int					 i;
	unit_names_t		*unit_name;
	unit_dimensions_t	*unit_dim;
	static HTAB			*tmp_unit_names;
	static HTAB			*tmp_unit_dimensions;

	/* unit_names: char *name -> Unit unit
	 * Lookup table that initially contains the base units and will cache all
	 * units resolved at run time
	 */
	hinfo.keysize = UNIT_NAME_LENGTH;
	hinfo.entrysize = sizeof(unit_names_t);
	Assert(UNIT_NAME_LENGTH + sizeof(UnitShift) == sizeof(unit_names_t));
	tmp_unit_names = hash_create("unit_names",
			20,
			&hinfo,
			HASH_ELEM); /* Set keysize and entrysize */

	PG_TRY();
	{
		for (i = 0; i < N_UNITS; i++)
		{
			unit_name = hash_search(tmp_unit_names,
									base_units[i],
									HASH_ENTER,
									NULL);
			strlcpy(unit_name->name, base_units[i], UNIT_NAME_LENGTH);
			unit_name->unit_shift.unit.value = 1.0;
			memset(unit_name->unit_shift.unit.units, 0, N_UNITS);
			unit_name->unit_shift.unit.units[i] = 1;
			unit_name->unit_shift.shift = 0.0;
		}
	}
	PG_CATCH();
	{
		/* free partially initialized table */
		hash_destroy(tmp_unit_names);
		PG_RE_THROW();
	}
	PG_END_TRY();

	/* No OOM errors were thrown, use the new table */
	if (unit_names)
		hash_destroy(unit_names);
	unit_names = tmp_unit_names;

	/* unit_dimensions: char dimension[N_UNITS] -> char *name
	 * Lookup table for formatting the well-known derived units on output
	 */
	hinfo.keysize = N_UNITS;
	hinfo.entrysize = sizeof(unit_dimensions_t);
	Assert(N_UNITS + UNIT_NAME_LENGTH == sizeof(unit_dimensions_t));
	tmp_unit_dimensions = hash_create("unit_dimensions",
			20,
			&hinfo,
			HASH_ELEM | HASH_BLOBS);

	PG_TRY();
	{
		for (i = 0; si_derived_units[i].name; i++)
		{
			unit_dim = hash_search(tmp_unit_dimensions,
								   si_derived_units[i].units,
								   HASH_ENTER,
								   NULL);
			memcpy(unit_dim->units, si_derived_units[i].units, N_UNITS);
			strlcpy(unit_dim->name, si_derived_units[i].name, UNIT_NAME_LENGTH);
		}
	}
	PG_CATCH();
	{
		/* free partially initialized table */
		hash_destroy(tmp_unit_dimensions);
		PG_RE_THROW();
	}
	PG_END_TRY();

	/* No OOM errors were thrown, use the new table */
	if (unit_dimensions)
		hash_destroy(unit_dimensions);
	unit_dimensions = tmp_unit_dimensions;
}

/* module initialization */

PG_MODULE_MAGIC;

void _PG_init(void);

void
_PG_init(void)
{
	DefineCustomBoolVariable("unit.output_superscript",
			"Output unit exponents using Unicode superscripts",
			"Set to on to output unit exponents using Unicode superscripts",
			&unit_output_superscript,
			false,
			PGC_USERSET,
			0, /* no flags */
			NULL,
			NULL,
			NULL);

	DefineCustomBoolVariable("unit.time_output_custom",
			"Output time values in minutes, hours, days, and julianyears",
			"Set to on to output time unit values greater or equal to 60 s "
			"using minutes, hours, days, and julianyears instead of seconds "
			"with SI prefixes",
			&unit_time_output_custom,
			true,
			PGC_USERSET,
			0, /* no flags */
			NULL,
			NULL,
			NULL);

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

	DefineCustomBoolVariable("unit.output_base_units",
			"Output unit values using base units without prefixes",
			"Set to on to output unit values using base units only "
			"and without prefixes",
			&unit_output_base_units,
			false,
			PGC_USERSET,
			0, /* no flags */
			NULL,
			NULL,
			NULL);

	EmitWarningsOnPlaceholders("unit");

	unit_get_definitions();
}

/* internal functions */

static char *superscripts[] = {
	"⁰",
	"¹",
	"²",
	"³",
	"⁴",
	"⁵",
	"⁶",
	"⁷",
	"⁸",
	"⁹",
};

static void
print_exponent (char **output_p, int e)
{
	if (unit_output_superscript) {
		char  ascii_exp[5];
		int   i = 0;

		sprintf(ascii_exp, "%d", e);
		if (ascii_exp[0] == '-') {
			*output_p += sprintf(*output_p, "%s", "⁻");
			i++;
		}
		for (; ascii_exp[i] != '\0'; i++) {
			Assert (ascii_exp[i] >= '0' && ascii_exp[i] <= '9');
			*output_p += sprintf(*output_p, "%s", superscripts[ascii_exp[i] - '0']);
		}
	} else {
		*output_p += sprintf(*output_p, "^%d", e);
	}
}

/* this function is used to format time values of at least one minute */
static void
print_time_interval (char **output_p, double t)
{
	int		 h, m;
	char	*sign = "+";
	int		 ndig;
	double	 ulp;

	/* print - */
	if (t < 0) {
		*output_p += sprintf(*output_p, "-");
		t = -t;
		sign = "-";
	}
	ndig = DBL_DIG + extra_float_digits - log2(t / 60.0); /* adjust seconds precision for d/h/min already printed */
	ulp = t * __DBL_EPSILON__; /* smallest remainder of seconds that should be printed */

	/* print years */
	if (t >= TIME_YEAR) {
		double years = trunc(t / TIME_YEAR);
		t = fmod(t, TIME_YEAR);
		*output_p += sprintf(*output_p, "%g " TIME_YEAR_NAME, years);
		if (t != 0)
			*output_p += sprintf(*output_p, " %s ", sign);
	}
	if (t == 0)
		return;

	/* print days */
	if (t >= TIME_DAY) {
		int days = trunc(t / TIME_DAY);
		t = fmod(t, TIME_DAY);
		*output_p += sprintf(*output_p, "%d d", days);
		if (t != 0)
			*output_p += sprintf(*output_p, " %s ", sign);
	}
	if (t == 0)
		return;

	/* print hh:mm:ss.sss */
	h = trunc(t / TIME_HOUR);
	t = fmod(t, TIME_HOUR);
	m = trunc(t / TIME_MINUTE);
	t = fmod(t, TIME_MINUTE);
	*output_p += sprintf(*output_p, "%02d:%02d:", h, m);
	if (t < 10.0) /* zero-pad */
		*output_p += sprintf(*output_p, "0");
	if (t < ulp) /* clamp output smaller than input precision */
		t = 0;
	*output_p += sprintf(*output_p, "%.*g s", ndig, t);
}

/* format Unit as string */
char *
unit_cstring (Unit *unit)
{
	int		 i;
	int		 n_numerator = 0;
	int		 u_numerator = -1;
	unit_dimensions_t	*derived_unit = NULL;
	char	*output;
	char	*output_p;
	bool	 numerator = false;
	bool	 denominator = false;

	/* check if this is a combination of base units we have a specific name for */
	derived_unit = hash_search(unit_dimensions,
			unit->units,
			HASH_FIND,
			NULL);
	if (! derived_unit) /* otherwise, sum up positive exponents */
		for (i = 0; i < N_UNITS; i++) {
			if (unit->units[i] > 0) {
				n_numerator += unit->units[i];
				u_numerator = i;
			}
		}

	output_p = output = palloc(128);
#define print_output(...) output_p += sprintf(output_p, __VA_ARGS__);

	/* case 1a: kg in numerator (exponent 1): print with SI prefix */
	if (!unit_output_base_units && n_numerator == 1 && u_numerator == UNIT_kg) {
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
	} else if (!unit_output_base_units && n_numerator == 1 && u_numerator == UNIT_B && unit_byte_output_iec) {
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
	} else if (!unit_output_base_units && (derived_unit || n_numerator == 1)) {
		double	 v_abs = fabs(unit->value);
		char	*prefix = "";
		double	 factor = 1.0;

		/* case 2a: minute/hour/day output requested, unit is seconds, and
		 * absolute value is >= 60 seconds. Print as interval and exit */
		if (unit_time_output_custom && derived_unit &&
				!strcmp(derived_unit->name, "s") && v_abs >= TIME_MINUTE) {
			print_time_interval(&output_p, unit->value);
			return output;
		}

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

		/* case 2b: derived unit, print with SI prefix and exit */
		if (derived_unit) {
			print_output("%s %s%s", float8out_internal (unit->value * factor),
					prefix, derived_unit->name);
			return output;
		}

		/* case 2c: single unit in numerator (exponent 1), print with SI prefix and continue */
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
					print_exponent(&output_p, unit->units[i]);
				numerator = true;
			}
	}

	/* print units in denominator */
	for (i = 0; i < N_UNITS; i++) /* format units in denominator */
		if (unit->units[i] < 0) {
			if (numerator) { /* format as .../a^x*b^y */
				print_output("%s%s", denominator ? "*" : "/", base_units[i]);
				if (unit->units[i] < -1)
					print_exponent(&output_p, -unit->units[i]);
			} else { /* format as a^-x*b^-y */
				print_output("%s%s", denominator ? "*" : " ", base_units[i]);
				print_exponent(&output_p, unit->units[i]);
			}
			denominator = true;
		}

	/* done */
	return output;
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

/* needs search_path = @extschema@ due to use of unit_parse() */
PG_FUNCTION_INFO_V1 (unit_in);

Datum
unit_in (PG_FUNCTION_ARGS)
{
	char		*str = PG_GETARG_CSTRING(0);
	UnitShift	*result;

	result = (UnitShift *) palloc(sizeof(UnitShift));
	if (unit_parse(str, result) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 str, yyerrstr)));
	PG_RETURN_POINTER(&result->unit);
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

/* functions without operators */

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

PG_FUNCTION_INFO_V1(unit_round);

Datum
unit_round(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	result->value = round(a->value);
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

	result = (Unit *) palloc(sizeof(Unit));
	unit_add_internal(a, b, result);
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_sub);

Datum
unit_sub(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;

	result = (Unit *) palloc(sizeof(Unit));
	unit_sub_internal(a, b, result);
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

	result = (Unit *) palloc(sizeof(Unit));
	unit_mult_internal(a, b, result);
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

	result = (Unit *) palloc(sizeof(Unit));
	unit_div_internal(a, b, result);
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

PG_FUNCTION_INFO_V1(unit_sqrt);

Datum
unit_sqrt(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*result;
	int		 i;

	/* compute root of value */
	if (a->value < 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_ARGUMENT_FOR_POWER_FUNCTION),
				 errmsg("cannot take square root of a negative-valued unit")));
	result = (Unit *) palloc(sizeof(Unit));
	result->value = sqrt(a->value);

	/* compute root of base units */
	for (i = 0; i < N_UNITS; i++)
	{
		if (a->units[i] % 2 != 0)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_ARGUMENT_FOR_POWER_FUNCTION),
					 errmsg("cannot take square root of a unit with odd \"%s\" exponent",
						 base_units[i])));
		result->units[i] = a->units[i] >> 1;
	}

	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(unit_cbrt);

Datum
unit_cbrt(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*result;
	int		 i;

	/* compute root of value */
	result = (Unit *) palloc(sizeof(Unit));
	result->value = cbrt(a->value);

	/* compute root of base units */
	for (i = 0; i < N_UNITS; i++)
	{
		if (a->units[i] % 3 != 0)
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_ARGUMENT_FOR_POWER_FUNCTION),
					 errmsg("cannot take cube root of a unit with \"%s\" exponent not divisible by three",
						 base_units[i])));
		result->units[i] = a->units[i] / 3;
	}

	PG_RETURN_POINTER(result);
}

/* obsolete version of unit_at_text used in v1..3 */
/* needs search_path = @extschema@ due to use of unit_parse() */
PG_FUNCTION_INFO_V1(unit_at);

Datum
unit_at(PG_FUNCTION_ARGS)
{
	Unit		*a = (Unit *) PG_GETARG_POINTER(0);
	char		*b = PG_GETARG_CSTRING(1);
	UnitShift	 bu;

	if (unit_parse(b, &bu) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 b, yyerrstr)));
	test_same_dimension("@", a, &bu.unit);
	if (bu.unit.value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"", b)));
	PG_RETURN_CSTRING(psprintf("%s %s%s",
				float8out_internal ((a->value - bu.shift) / bu.unit.value),
				(atof(b) > 0 ? "* " : ""),
				b));
}

/* needs search_path = @extschema@ due to use of unit_parse() */
PG_FUNCTION_INFO_V1(unit_at_text);

Datum
unit_at_text(PG_FUNCTION_ARGS)
{
	Unit		*a = (Unit *) PG_GETARG_POINTER(0);
	char		*b = text_to_cstring(PG_GETARG_TEXT_PP(1));
	UnitShift	 bu;

	if (unit_parse(b, &bu) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 b, yyerrstr)));
	test_same_dimension("@", a, &bu.unit);
	if (bu.unit.value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"", b)));
	PG_RETURN_CSTRING(psprintf("%s %s%s",
				float8out_internal ((a->value - bu.shift) / bu.unit.value),
				(atof(b) > 0 ? "* " : ""),
				b));
}

/* needs search_path = @extschema@ due to use of unit_parse() */
PG_FUNCTION_INFO_V1(unit_at_double);

Datum
unit_at_double(PG_FUNCTION_ARGS)
{
	Unit		*a = (Unit *) PG_GETARG_POINTER(0);
	char		*b = text_to_cstring(PG_GETARG_TEXT_PP(1));
	UnitShift	 bu;

	if (unit_parse(b, &bu) > 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\", %s",
					 b, yyerrstr)));
	test_same_dimension("@@", a, &bu.unit);
	if (bu.unit.value == 0)
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero-valued unit: \"%s\"", b)));
	PG_RETURN_FLOAT8((a->value - bu.shift) / bu.unit.value);
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

/* internal functions */

/* used in load-units.pl */
PG_FUNCTION_INFO_V1(unit_is_hashed);

Datum
unit_is_hashed(PG_FUNCTION_ARGS)
{
	char			*name = PG_GETARG_CSTRING(0);

	PG_RETURN_BOOL (hash_search(unit_names, name, HASH_FIND, NULL) != NULL);
}

PG_FUNCTION_INFO_V1(unit_reset);

Datum
unit_reset(PG_FUNCTION_ARGS)
{
	/* reinitialize hash tables */
	unit_get_definitions();

	PG_RETURN_VOID();
}
