\i units.sql

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
	(1e-27),
	(1e-30),
	(0))
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

WITH
  pfx(p) AS (VALUES
	('y'),('z'),('a'),('f'),('p'),('n'),('µ'),('mu'),('m'),('c'),('d'),
	(''),
	('da'),('h'),('k'),('M'),('G'),('T'),('P'),('E'),('Z'),('Y')),
  unt(u) AS (VALUES
	('m/m'),
	('m'),('g'),('s'),('A'),('K'),('mol'),('cd'),('B'),
	('rad'),('sr'),('Hz'),('N'),('Pa'),('J'),('W'),('C'),('V'),('F'),('Ω'),('ohm'),('S'),('Wb'),('T'),('H'),('°C'),('lm'),('lx'),('Bq'),('Gy'),('Sv'),('kat'),
	('t'),('l'))
SELECT
  u, p, (p||u)::unit
FROM
  pfx CROSS JOIN unt
\crosstabview
