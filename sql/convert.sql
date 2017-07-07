-- length
WITH
  l(u) AS (VALUES
	('mm'),
	('m'),
	('km'),
	('in'),
	('ft'),
	('yd'),
	('mi'))
SELECT
  l1.u, l2.u, l1.u::unit @ l2.u
FROM
  l l1 CROSS JOIN l l2
\crosstabview

-- area
WITH
  l(u) AS (VALUES
	('mm^2'),
	('m^2'),
	('km^2'),
	('in^2'),
	('ft^2'),
	('yd^2'),
	('mi^2'))
SELECT
  l1.u, l2.u, l1.u::unit @ l2.u
FROM
  l l1 CROSS JOIN l l2
\crosstabview

-- volume
WITH
  l(u) AS (VALUES
	('mm^3'),
	('l'),
	('m^3'),
	('in^3'),
	('ft^3'),
	('yd^3'))
SELECT
  l1.u, l2.u, l1.u::unit @ l2.u
FROM
  l l1 CROSS JOIN l l2
\crosstabview

-- weight
WITH
  l(u) AS (VALUES
	('g'),
	('kg'),
	('t'),
	('oz'),
	('lb'))
SELECT
  l1.u, l2.u, l1.u::unit @ l2.u
FROM
  l l1 CROSS JOIN l l2
\crosstabview

-- time
WITH
  l(u) AS (VALUES
	('s'),
	('min'),
	('h'),
	('d'),
	('julianyear'))
SELECT
  l1.u, l2.u, l1.u::unit @ l2.u
FROM
  l l1 CROSS JOIN l l2
\crosstabview
