ALTER TYPE unit_accum_t
	ADD ATTRIBUTE squares double precision;

CREATE OR REPLACE FUNCTION unit_accum(a unit_accum_t, u unit)
	RETURNS unit_accum_t
	AS $$SELECT (CASE WHEN a.s = '0'::unit THEN u ELSE a.s + u END, a.squares + value(u)^2, a.n + 1)::unit_accum_t$$
	LANGUAGE SQL IMMUTABLE STRICT;

-- update v1 avg() aggregate
UPDATE pg_aggregate
	SET agginitval = '(0,0,0)'
	WHERE aggtransfn = 'unit_accum'::regproc AND agginitval = '(0,0)';

CREATE FUNCTION unit_var_pop(a unit_accum_t)
	RETURNS double precision
	AS $$SELECT CASE WHEN a.n > 0 THEN (a.squares - value(a.s)^2 / a.n) / a.n ELSE NULL END$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE AGGREGATE var_pop(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_var_pop,
	initcond = '(0,0,0)'
);

CREATE FUNCTION unit_var_samp(a unit_accum_t)
	RETURNS double precision
	AS $$SELECT CASE WHEN a.n > 1 THEN (a.squares - value(a.s)^2 / a.n) / (a.n - 1)  WHEN a.n = 1 THEN 0 ELSE NULL END$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE AGGREGATE var_samp(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_var_samp,
	initcond = '(0,0,0)'
);

CREATE AGGREGATE variance(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_var_samp,
	initcond = '(0,0,0)'
);

CREATE FUNCTION unit_stddev_pop(a unit_accum_t)
	RETURNS unit
	AS $$SELECT CASE WHEN a.n > 0 THEN sqrt((a.squares - value(a.s)^2 / a.n) / a.n) * dimension(a.s) ELSE NULL END$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE AGGREGATE stddev_pop(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_stddev_pop,
	initcond = '(0,0,0)'
);

CREATE FUNCTION unit_stddev_samp(a unit_accum_t)
	RETURNS unit
	AS $$SELECT CASE WHEN a.n > 1 THEN sqrt((a.squares - value(a.s)^2 / a.n) / (a.n - 1)) * dimension(a.s) WHEN a.n = 1 THEN 0 * dimension(a.s) ELSE NULL END$$
	LANGUAGE SQL IMMUTABLE STRICT;

CREATE AGGREGATE stddev_samp(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_stddev_samp,
	initcond = '(0,0,0)'
);

CREATE AGGREGATE stddev(unit)
(
	sfunc = unit_accum,
	stype = unit_accum_t,
	finalfunc = unit_stddev_samp,
	initcond = '(0,0,0)'
);

