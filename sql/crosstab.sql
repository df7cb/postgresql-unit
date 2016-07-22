CREATE TEMP TABLE units (u) AS
  VALUES
	('1'::unit),
	(meter()),
	(kilogram()),
	(second()),
	(ampere()),
	(kelvin()),
	(mole()),
	(candela()),
	(byte());

CREATE TEMP TABLE derived_units (u) AS
  VALUES
	('1'::unit),
	(meter()),
	(kilogram()),
	(second()),
	(ampere()),
	(kelvin()),
	(mole()),
	(candela()),
	(byte()),

	(hertz()),
	(newton()),
	(pascal()),
	(joule()),
	(watt()),
	(coulomb()),
	(volt()),
	(farad()),
	(ohm()),
	(siemens()),
	(weber()),
	(tesla()),
	(henry()),
	(lux()),
	(katal());

SELECT u, 1/u AS inverse FROM derived_units;

-- test multiplication
WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('0'), ('1'), ('2'))
SELECT
  u, i, u * i
FROM
  units CROSS JOIN i
\crosstabview

SELECT
  a.u AS a, b.u AS b, a.u * b.u AS mul
FROM 
  derived_units AS a CROSS JOIN units AS b
\crosstabview

WITH
  factor(f) AS (VALUES
	(1e27),
	(1e24),
	(1e21),
	(1e18),
	(1e15),
	(1e12),
	(1e9),
	(1e6),
	(1e3),
	(1),
	(1e-3),
	(1e-6),
	(1e-9),
	(1e-12),
	(1e-15),
	(1e-18),
	(1e-21),
	(1e-24),
	(1e-27))
SELECT
  f, u, f * u
FROM
  factor CROSS JOIN units
\crosstabview

-- test division
WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('1'), ('2'))
SELECT
  u, i, u / i
FROM
  derived_units CROSS JOIN i
\crosstabview

WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('0'), ('1'), ('2'))
SELECT
  i, u, i / u
FROM
  units CROSS JOIN i
\crosstabview

SELECT
  a.u AS a, b.u AS b, a.u / b.u AS div
FROM 
  derived_units AS a CROSS JOIN units AS b
\crosstabview

-- test comparisons
WITH
  v(u) AS (VALUES
	('-2'::unit),
	('-1'::unit),
	(-kilogram()),
	(-meter()),
	('-0'::unit),
	('0'::unit),
	('1'::unit),
	(kilogram()),
	(meter()),
	('2'::unit),
	(kilogram(2)),
	(meter(2))
  ),
  va(a) AS (SELECT * FROM v),
  vb(b) AS (SELECT * FROM v)
SELECT
  a, b, unit_cmp(a, b) AS cmp
FROM
  va CROSS JOIN vb
\crosstabview
