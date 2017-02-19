SET client_min_messages = warning;

DROP TABLE IF EXISTS prefixes;
CREATE TABLE prefixes (p text);
DELETE FROM prefixes;
INSERT INTO prefixes VALUES
	('y'),('z'),('a'),('f'),('p'),('n'),('µ'),('mu'),('m'),('c'),('d'),
	(''),
	('da'),('h'),('k'),('M'),('G'),('T'),('P'),('E'),('Z'),('Y');

DROP TABLE IF EXISTS factors;
CREATE TABLE factors (f double precision);
DELETE FROM factors;
INSERT INTO factors VALUES
	(1e27), (1e24), (1e21), (1e18), (1e15), (1e12), (1e9), (1e6), (1e3),
	(1),
	(1e-3), (1e-6), (1e-9), (1e-12), (1e-15), (1e-18), (1e-21), (1e-24), (1e-27), (1e-30),
	(0);

DROP TABLE IF EXISTS units;
CREATE TABLE units (u text, unit unit, base boolean, coherent boolean, duplicate boolean);
COMMENT ON COLUMN units.duplicate IS 'For coherent units, this unit has the same dimension as some other base or coherent unit';
DELETE FROM units;
COPY units (u, base, coherent, duplicate) FROM STDIN;
m/m	t	f	f
m	t	f	f
kg	t	f	f
s	t	f	f
A	t	f	f
K	t	f	f
mol	t	f	f
cd	t	f	f
B	t	f	f
sr	f	t	t
Hz	f	t	f
N	f	t	f
Pa	f	t	f
J	f	t	f
W	f	t	f
C	f	t	f
V	f	t	f
F	f	t	f
Ω	f	t	f
ohm	f	t	t
S	f	t	f
Wb	f	t	f
T	f	t	f
H	f	t	f
°C	f	t	t
lm	f	t	t
lx	f	t	f
Bq	f	t	t
Gy	f	t	f
rad	f	f	t
Sv	f	t	t
kat	f	t	f
g	f	f	t
a	f	f	f
l	f	f	f
t	f	f	f
bar	f	f	f
min	f	f	f
h	f	f	f
d	f	f	f
in	f	f	f
ft	f	f	f
yd	f	f	f
mi	f	f	f
oz	f	f	f
lb	f	f	f
\.
UPDATE units
	SET unit = u::unit;

SELECT * FROM units;
