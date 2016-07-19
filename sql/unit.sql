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

-- text extractors
SELECT value('2'::unit);
SELECT value(meter(2));
SELECT dimension('2'::unit);
SELECT dimension(kilogram(2));

-- test unit addition/subtraction
SELECT '1'::unit + '2' AS sum;
SELECT '1'::unit - '2' AS difference;
SELECT meter() + '1' AS error;
SELECT meter() + kilogram() AS error;

-- test unit multiplication/division
SELECT - '1'::unit AS negative;
SELECT '2'::unit * '2' AS product;
SELECT '5'::unit / '2' AS fraction;
SELECT '0'::unit / '2' AS zero;
SELECT '5'::unit / '0' AS division_by_zero;

SELECT - second() AS minus_second;
SELECT meter() * '2' AS two_meters;
SELECT '3' * meter() AS three_meters;
SELECT meter() * meter() AS square_meter;
SELECT meter() * kilogram() AS meter_kilogram;
SELECT '1' / second(.02) AS hertz;
SELECT meter(9.81) / (second() * second()) AS acceleration;

-- test unit/double operators
SELECT 2 * meter() AS two_meters;
SELECT ampere() * 3 AS three_ampere;
SELECT 4 / second() AS four_hertz;
SELECT kelvin() / 5 AS fifth_kelvin;
SELECT 0 / candela() AS zero_by_candela;
SELECT 1 / mole(0) AS error;
SELECT byte(0) / 2 AS zero_byte;
SELECT kilogram(1) / 0 AS error;

-- test exponentiation
SELECT '6'::unit ^ 2 AS square;
SELECT meter(7) ^ 2 AS square_meter;
SELECT second(2) ^ -1 AS hertz;
SELECT ampere(4) ^ 0 AS unity;
SELECT '0'::unit ^ 0 AS unity;

WITH
  v(u) AS (VALUES
	(NULL),
	('0'::unit),
	('1'::unit),
	('2'::unit),
	(meter(0)),
	(meter()),
	(meter() * '2'),
	(kilogram(0)),
	(kilogram()),
	(kilogram() * '2')
  ),
  va(a) AS (SELECT * FROM v),
  vb(b) AS (SELECT * FROM v)
SELECT
  a, b,
  -a AS neg,
  a * b AS mul,
  CASE WHEN value(b) = 0 THEN NULL ELSE a / b END AS div
FROM
  va CROSS JOIN vb;

WITH
  v(a) AS (VALUES
	(NULL),
	('1'::unit),
	('2'::unit),
	(meter()),
	(meter() * '2'),
	(kilogram()),
	(kilogram() * '2')
  )
SELECT
  a,
  a ^ -2 AS pow_2, a ^ -1 AS pow_1, a ^ 0 AS pow0, a ^ 1 AS pow1, a ^ 2 AS pow2
FROM
  v;
