WITH
  factor(f) AS (VALUES
	(1e27), (1e24), (1e21), (1e18), (1e15), (1e12), (1e9), (1e6), (1e3),
	(1),
	(1e-3), (1e-6), (1e-9), (1e-12), (1e-15), (1e-18), (1e-21), (1e-24), (1e-27), (1e-30),
	(0))
SELECT
  f, meter(f), kilogram(f)
FROM
  factor;

WITH
  pfx(p) AS (VALUES
	('y'),('z'),('a'),('f'),('p'),('n'),('µ'),('mu'),('m'),('c'),('d'),
	(''),
	('da'),('h'),('k'),('M'),('G'),('T'),('P'),('E'),('Z'),('Y'))
SELECT
  p, (p||'m/m')::unit AS factor,
  ('0.001 '||p||'m')::unit AS "0.001 m",
  (p||'m')::unit AS "meter",
  ('1000 '||p||'m')::unit AS "1000 m",
  ('0.001 '||p||'g')::unit AS "0.001 g",
  (p||'g')::unit AS "gram",
  ('1000 '||p||'g')::unit AS "1000 g"
FROM
  pfx;
