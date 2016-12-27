SELECT
  f, meter(f), kilogram(f)
FROM
  factors;

SELECT
  p, (p||'m/m')::unit AS factor,
  ('0.001 '||p||'m')::unit AS "0.001 m",
  (p||'m')::unit AS "meter",
  ('1000 '||p||'m')::unit AS "1000 m",
  ('0.001 '||p||'g')::unit AS "0.001 g",
  (p||'g')::unit AS "gram",
  ('1000 '||p||'g')::unit AS "1000 g"
FROM
  prefixes;
