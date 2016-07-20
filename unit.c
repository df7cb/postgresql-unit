#include "postgres.h"
#include "fmgr.h"
#include <math.h>

#include "unit.h"

/* module initialization */

void
_PG_init (void)
{
	memset(&unit_zero, 0, sizeof(Unit));
}

PG_MODULE_MAGIC;

/* internal functions */

static inline char *
unit_fmt (char *name, signed char exponent)
{
	if (exponent == 0)
		return "";
	else if (exponent == 1)
		return name;
	else
		return psprintf("%s^%d", name, exponent);
}

/* format Unit as string */
static char *
unit_cstring (Unit *unit)
{
	char *result = psprintf("%g%s%s%s%s%s%s%s%s",
			unit->value,
			unit_fmt(" m",   unit->units[UNIT_m]),
			unit_fmt(" kg",  unit->units[UNIT_kg]),
			unit_fmt(" s",   unit->units[UNIT_s]),
			unit_fmt(" A",   unit->units[UNIT_A]),
			unit_fmt(" K",   unit->units[UNIT_K]),
			unit_fmt(" mol", unit->units[UNIT_mol]),
			unit_fmt(" cd",  unit->units[UNIT_cd]),
			unit_fmt(" B",   unit->units[UNIT_B])
			);
	return result;
}

/* test if two Units use the same unit */
static inline void
test_same_unit (Unit *a, Unit *b)
{
	if (memcmp(a->units, b->units, N_UNITS))
		ereport(ERROR,
				(errcode(ERRCODE_DATA_EXCEPTION),
				 errmsg("units are not the same: \"%s\", \"%s\"",
					 unit_cstring(a), unit_cstring(b))));
}

/* input and output */

PG_FUNCTION_INFO_V1 (unit_in);

Datum
unit_in (PG_FUNCTION_ARGS)
{
	char	*str = PG_GETARG_CSTRING(0);
	double	 v;
	Unit	*result;

	if (sscanf(str, "%lf", &v) != 1)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for unit: \"%s\"",
					 str)));

	result = (Unit *) palloc0(sizeof(Unit));
	result->value = v;
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

	test_same_unit(a, b);
	result = (Unit *) palloc(sizeof(Unit));
	result->value = a->value + b->value;
	memcpy(result->units, a->units, N_UNITS);
	PG_RETURN_POINTER(result);
}

/* variant of unit_add that accepts dimensionless zero as always compatible for
 * use in aggregates
 */
PG_FUNCTION_INFO_V1(unit_add0);

Datum
unit_add0(PG_FUNCTION_ARGS)
{
	Unit	*a = (Unit *) PG_GETARG_POINTER(0);
	Unit	*b = (Unit *) PG_GETARG_POINTER(1);
	Unit	*result;

	/* handle dimensionless zero additions */
	if (!memcmp(a, &unit_zero, sizeof(Unit)))
		PG_RETURN_POINTER(b);
	if (!memcmp(b, &unit_zero, sizeof(Unit)))
		PG_RETURN_POINTER(a);
	/* other cases */
	test_same_unit(a, b);
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

	test_same_unit(a, b);
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

