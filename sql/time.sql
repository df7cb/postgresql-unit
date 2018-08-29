SELECT '1.1 s'::unit;
SELECT '61.1 s'::unit;
SELECT '71.1 s'::unit;
SELECT '601 s'::unit;
SELECT '3601 s'::unit;
SELECT '86400 s'::unit;
SELECT '-86400 s'::unit;
SELECT '86401 s'::unit;
SELECT '-86401 s'::unit;
SELECT '365 d'::unit;
SELECT '-365 d'::unit;
SELECT '3650 d'::unit;
SELECT '3651 d'::unit;
SELECT '3651.5 d'::unit;

SELECT '00:00:00.1'::unit;
SELECT '00:00:01'::unit;
SELECT '00:01:00'::unit;
SELECT '01:00:00'::unit;
SELECT '0:0:0'::unit;

SELECT '00:00:01 s'::unit;
SELECT '00:00:01s'::unit;
SELECT '00:00:01 m'::unit;
SELECT '00:01:00 s'::unit;
SELECT '00:01:00.5 s'::unit;
SELECT '01:00:00 s'::unit;
SELECT '1 d + 02:03:04.5 s'::unit;
SELECT '1.1 d'::unit; -- needs ULP clamping

SELECT name, unit, definition FROM unit_units WHERE dimension(unit) = 'TIME' ORDER BY unit, name;

-- units that differ when pushed through output-input functions
-- (same test as in units.sql, but with time_output_custom = true)
SELECT name, unit, unit::text::unit, definition FROM unit_units WHERE unit::text::unit::text <> unit::text;

/* custom time format is only used if dimension is time */
SELECT '1000 s'::unit, '1000 s/m'::unit;
SET unit.time_output_custom = false;
SELECT '1000 s'::unit, '1000 s/m'::unit;

-- test if 'Gs' is avoided on output
SELECT '1 Gsec'::unit, '1 Gsec/m'::unit;
