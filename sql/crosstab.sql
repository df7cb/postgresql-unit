-- test multiplication
WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('0'), ('1'), ('2'))
SELECT
  unit, i, unit * i
FROM
  units CROSS JOIN i
WHERE
  (base OR coherent) AND NOT duplicate
\crosstabview

SELECT
  a.unit AS a, b.unit AS b, a.unit * b.unit AS mul
FROM
  units AS a CROSS JOIN units AS b
WHERE
  (a.base OR a.coherent) AND NOT a.duplicate AND (b.base OR b.coherent) AND NOT b.duplicate
\crosstabview

SELECT
  f, unit, f * unit
FROM
  factors CROSS JOIN units
WHERE
  (base OR coherent) AND NOT duplicate
\crosstabview

-- test division
WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('1'), ('2'))
SELECT
  unit, i, unit / i
FROM
  units CROSS JOIN i
WHERE
  (base OR coherent) AND NOT duplicate
\crosstabview

WITH i(i) AS (VALUES ('-2'::unit), ('-1'), ('0'), ('1'), ('2'))
SELECT
  i, unit, i / unit
FROM
  units CROSS JOIN i
WHERE
  (base OR coherent) AND NOT duplicate
\crosstabview

SELECT
  a.unit AS a, b.unit AS b, a.unit / b.unit AS div
FROM
  units AS a CROSS JOIN units AS b
WHERE
  (a.base OR a.coherent) AND NOT a.duplicate AND (b.base OR b.coherent) AND NOT b.duplicate
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
  a, b,
  CASE WHEN unit_cmp(a, b) < 0 THEN '<'
       WHEN unit_cmp(a, b) = 0 THEN '='
       WHEN unit_cmp(a, b) > 0 THEN '>'
  END AS cmp
FROM
  va CROSS JOIN vb
\crosstabview

-- test all prefix/unit combinations
SELECT
  u, p, (p||u)::unit
FROM
  prefixes CROSS JOIN units
WHERE
  u <> 'kg' AND
  (p||u) <> 'dat' -- ambiguous
\crosstabview
