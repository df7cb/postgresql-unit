-- type definition

CREATE TYPE unit;

CREATE OR REPLACE FUNCTION unit_in(cstring)
  RETURNS unit
  AS '$libdir/unit'
  LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION unit_out(unit)
  RETURNS cstring
  AS '$libdir/unit'
  LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE unit (
	internallength = 16,
	input = unit_in,
	output = unit_out,
	alignment = double
);

-- constructors

CREATE FUNCTION meter(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_meter'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION kilogram(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_kilogram'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION second(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_second'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ampere(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_ampere'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION kelvin(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_kelvin'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION mole(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_mole'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION candela(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_candela'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION byte(double precision DEFAULT 1.0)
	RETURNS unit
	AS '$libdir/unit', 'unit_byte'
	LANGUAGE C IMMUTABLE STRICT;

-- extractors

CREATE FUNCTION value(unit)
	RETURNS double precision
	AS '$libdir/unit', 'unit_value'
	LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION dimension(unit)
	RETURNS unit
	AS '$libdir/unit', 'unit_dimension'
	LANGUAGE C IMMUTABLE STRICT;

-- operators

CREATE FUNCTION unit_add(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR + (
	leftarg = unit,
	rightarg = unit,
	procedure = unit_add,
	commutator = +
);

CREATE FUNCTION unit_sub(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR - (
	leftarg = unit,
	rightarg = unit,
	procedure = unit_sub
);

CREATE FUNCTION unit_neg(unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR - (
	rightarg = unit,
	procedure = unit_neg
);

CREATE FUNCTION unit_mul(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR * (
	leftarg = unit,
	rightarg = unit,
	procedure = unit_mul,
	commutator = *
);

CREATE FUNCTION dbl_unit_mul(double precision, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR * (
	leftarg = double precision,
	rightarg = unit,
	procedure = dbl_unit_mul,
	commutator = *
);

CREATE FUNCTION unit_dbl_mul(unit, double precision)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR * (
	leftarg = unit,
	rightarg = double precision,
	procedure = unit_dbl_mul,
	commutator = *
);

CREATE FUNCTION unit_div(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR / (
	leftarg = unit,
	rightarg = unit,
	procedure = unit_div
);

CREATE FUNCTION dbl_unit_div(double precision, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR / (
	leftarg = double precision,
	rightarg = unit,
	procedure = dbl_unit_div
);

CREATE FUNCTION unit_dbl_div(unit, double precision)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR / (
	leftarg = unit,
	rightarg = double precision,
	procedure = unit_dbl_div
);

CREATE FUNCTION unit_pow(unit, int)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR ^ (
	leftarg = unit,
	rightarg = int,
	procedure = unit_pow
);

-- comparisons

CREATE FUNCTION unit_lt(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION unit_le(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION unit_eq(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION unit_ne(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION unit_ge(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION unit_gt(unit, unit) RETURNS bool
   AS '$libdir/unit' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR < (
	leftarg = unit, rightarg = unit, procedure = unit_lt,
	commutator = > , negator = >= ,
	restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR <= (
	leftarg = unit, rightarg = unit, procedure = unit_le,
	commutator = >= , negator = > ,
	restrict = scalarltsel, join = scalarltjoinsel
);
CREATE OPERATOR = (
	leftarg = unit, rightarg = unit, procedure = unit_eq,
	commutator = = , negator = <> ,
	restrict = eqsel, join = eqjoinsel
);
CREATE OPERATOR <> (
	leftarg = unit, rightarg = unit, procedure = unit_ne,
	commutator = <> , negator = = ,
	restrict = neqsel, join = neqjoinsel
);
CREATE OPERATOR >= (
	leftarg = unit, rightarg = unit, procedure = unit_ge,
	commutator = <= , negator = < ,
	restrict = scalargtsel, join = scalargtjoinsel
);
CREATE OPERATOR > (
	leftarg = unit, rightarg = unit, procedure = unit_gt,
	commutator = < , negator = <= ,
	restrict = scalargtsel, join = scalargtjoinsel
);

CREATE FUNCTION unit_cmp(unit, unit)
	RETURNS int4
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS unit_ops
	DEFAULT FOR TYPE unit USING btree AS
		OPERATOR 1 < ,
		OPERATOR 2 <= ,
		OPERATOR 3 = ,
		OPERATOR 4 >= ,
		OPERATOR 5 > ,
		FUNCTION 1 unit_cmp(unit, unit);

-- aggregates

CREATE AGGREGATE sum(unit)
(
	sfunc = unit_add,
	stype = unit
);

CREATE FUNCTION unit_least(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE min(unit)
(
	sfunc = unit_least,
	stype = unit
);

CREATE FUNCTION unit_greatest(unit, unit)
	RETURNS unit
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE max(unit)
(
	sfunc = unit_greatest,
	stype = unit
);

CREATE TYPE unit_accum_t AS (
	s unit,
	n bigint
);

CREATE FUNCTION unit_accum(a unit_accum_t, u unit)
	RETURNS unit_accum_t
	AS $$SELECT (CASE WHEN a.s = '0'::unit THEN u ELSE a.s + u END, a.n + 1)::unit_accum_t$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION unit_avg(a unit_accum_t)
	RETURNS unit
	AS $$SELECT CASE WHEN a.n > 0 THEN a.s / a.n ELSE NULL END$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE AGGREGATE avg(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_avg,
	initcond = '(0,0)'
);

