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
  units AS a CROSS JOIN units AS b
\crosstabview

-- test division
WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('1'), ('2'))
SELECT
  u, i, u / i
FROM
  units CROSS JOIN i
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
  units AS a CROSS JOIN units AS b
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
