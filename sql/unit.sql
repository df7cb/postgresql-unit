-- test input and output
SELECT '1'::unit;
CREATE TABLE u (u unit);
INSERT INTO u VALUES ('1');
SELECT * FROM u;

-- test constructors
SELECT meter();
SELECT meter(2.0) AS two_meters;
SELECT kilogram();
SELECT kilogram(3.0) AS three_kilogram;
SELECT second();
SELECT second(4.0) AS four_seconds;
SELECT ampere();
SELECT ampere(5.0) AS five_ampere;
SELECT kelvin();
SELECT kelvin(6.0) AS six_kelvin;
SELECT mole();
SELECT mole(7.0) AS seven_mole;
SELECT candela();
SELECT candela(8.0) AS eight_candela;
SELECT byte();
SELECT byte(9.0) AS nine_byte;

-- test operators
SELECT '1'::unit + '2' AS sum;
SELECT '1'::unit - '2' AS difference;
SELECT '2'::unit * '2' AS product;
SELECT '5'::unit / '2' AS fraction;
SELECT '5'::unit / '0' AS division_by_zero;

-- test more operations
SELECT meter() * '2' AS two_meters;
SELECT '3' * meter() AS three_meters;
SELECT meter() * meter() AS square_meter;
SELECT meter() * kilogram() AS meter_kilogram;
SELECT meter() + '1' AS error;
SELECT meter() + kilogram() AS error;

-- test comparisons
WITH
  v(u) AS (VALUES ('1'::unit), ('2'::unit),
	(meter()), (meter() * '2'),
	(kilogram()), (kilogram() * '2')),
  va(a) AS (SELECT * FROM v),
  vb(b) AS (SELECT * FROM v)
SELECT
  a, b, unit_cmp(a, b) AS cmp,
  a < b  AS lt, a <= b AS le,
  a = b  AS eq, a <> b AS ne,
  a >= b AS ge, a > b  AS ge
FROM
  va CROSS JOIN vb;

-- test btree index
INSERT INTO u SELECT meter(generate_series(1,10000)::double precision);
INSERT INTO u SELECT generate_series(1,10000)::text::unit * kilogram();
ANALYZE u;
CREATE INDEX ON u(u);
SELECT * FROM u WHERE u = meter(400);
SELECT * FROM u WHERE u = '300' * kilogram();
EXPLAIN (COSTS OFF) SELECT * FROM u WHERE u = meter(400);
EXPLAIN (COSTS OFF) SELECT * FROM u WHERE u = '300' * kilogram();
