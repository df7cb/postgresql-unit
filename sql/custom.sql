SELECT '1 foobar'::unit;
SELECT unit_is_hashed('foobar');
INSERT INTO unit_prefixes VALUES ('foo', 42);
SELECT '1 foobar'::unit;
SELECT unit_is_hashed('foobar');
SELECT * FROM unit_prefixes WHERE dump;

INSERT INTO unit_units VALUES ('legobrick', '9.6 mm');
SELECT unit_is_hashed('legobricks');
SELECT '1 m'::unit @ 'legobricks' AS one_meter;
SELECT unit_is_hashed('legobricks');
SELECT * FROM unit_units WHERE dump;

UPDATE unit_units SET unit = '19.1 mm' WHERE name = 'legobrick'; -- Duplo size
SELECT '2 legobricks'::unit AS old_size;
SELECT unit_reset();
SELECT unit_is_hashed('legobricks');
SELECT '2 legobricks'::unit AS new_size;
