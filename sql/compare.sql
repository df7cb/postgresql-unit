-- test comparisons
WITH
  v(u) AS (VALUES
	(NULL),
	('-2'::unit),
	('-1'::unit),
	('-0'::unit),
	('0'::unit),
	('1'::unit),
	('2'::unit),
	(meter()),
	(meter() * '2'),
	(kilogram()),
	(kilogram() * '2')
  ),
  va(a) AS (SELECT * FROM v),
  vb(b) AS (SELECT * FROM v)
SELECT
  a, b,
  CASE WHEN unit_cmp(a, b) < 0 THEN '<'
       WHEN unit_cmp(a, b) = 0 THEN '='
       WHEN unit_cmp(a, b) > 0 THEN '>'
  END AS cmp,
  a < b  AS lt, a <= b AS le,
  a = b  AS eq, a <> b AS ne,
  a >= b AS ge, a > b  AS gt
FROM
  va CROSS JOIN vb;

-- test btree index
CREATE TEMP TABLE u (u unit);
INSERT INTO u SELECT meter(generate_series(1,10000)::double precision);
INSERT INTO u SELECT generate_series(1,10000)::text::unit * kilogram();
ANALYZE u;
CREATE INDEX ON u(u);
SELECT * FROM u WHERE u = meter(400);
SELECT * FROM u WHERE u = '300' * kilogram();
EXPLAIN (COSTS OFF) SELECT * FROM u WHERE u = meter(400);
EXPLAIN (COSTS OFF) SELECT * FROM u WHERE u = '300' * kilogram();

-- test strict operators
SELECT '1 m'::unit << '1 m'::unit;
SELECT '1 m'::unit << '1 A'::unit;
SELECT '1 m'::unit <<= '1 m'::unit;
SELECT '1 m'::unit <<= '1 A'::unit;
SELECT '1 m'::unit == '1 m'::unit;
SELECT '1 m'::unit == '1 A'::unit;
SELECT '1 m'::unit <<>> '1 m'::unit;
SELECT '1 m'::unit <<>> '1 A'::unit;
SELECT '1 m'::unit >>= '1 m'::unit;
SELECT '1 m'::unit >>= '1 A'::unit;
SELECT '1 m'::unit >> '1 m'::unit;
SELECT '1 m'::unit >> '1 A'::unit;
