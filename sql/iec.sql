VALUES
	('1 mB'::unit),
	('1 B'::unit),
	('1 KiB'::unit),
	('1 MiB'::unit),
	('1 GiB'::unit),
	('1 TiB'::unit),
	('1 PiB'::unit),
	('1 EiB'::unit),
	('1 ZiB'::unit),
	('1 YiB'::unit),
	('1 RiB'::unit),
	('1 QiB'::unit);

VALUES
	('1 B'::unit @ 'B'),
	('1 KiB'::unit @ 'KiB'),
	('1 MiB'::unit @ 'MiB'),
	('1 GiB'::unit @ 'GiB'),
	('1 TiB'::unit @ 'TiB'),
	('1 PiB'::unit @ 'PiB'),
	('1 EiB'::unit @ 'EiB'),
	('1 ZiB'::unit @ 'ZiB'),
	('1 YiB'::unit @ 'YiB'),
	('1 RiB'::unit @ 'RiB'),
	('1 QiB'::unit @ 'QiB');

VALUES
	('1 B'::unit @ 'B'),
	('1 kB'::unit @ 'KiB'),
	('1 MB'::unit @ 'MiB'),
	('1 GB'::unit @ 'GiB'),
	('1 TB'::unit @ 'TiB'),
	('1 PB'::unit @ 'PiB'),
	('1 EB'::unit @ 'EiB'),
	('1 ZB'::unit @ 'ZiB'),
	('1 YB'::unit @ 'YiB'),
	('1 RB'::unit @ 'RiB'),
	('1 QB'::unit @ 'QiB');

-- errors
SELECT '1 kiB'::unit;
SELECT '1 Ki'::unit;
-- used to be an error in v2
SELECT '1 Kim'::unit AS "1024 m";

-- binary prefix output
SET unit.byte_output_iec = 'foobar';
SET unit.byte_output_iec = on;

VALUES
	('.001 B'::unit, '.001 B'::unit),
	('1 B'::unit, '1 B'::unit),
	('1 KiB'::unit, '1 kB'::unit),
	('1 MiB'::unit, '1 MB'::unit),
	('1 GiB'::unit, '1 GB'::unit),
	('1 TiB'::unit, '1 TB'::unit),
	('1 PiB'::unit, '1 PB'::unit),
	('1 EiB'::unit, '1 EB'::unit),
	('1 ZiB'::unit, '1 ZB'::unit),
	('1 YiB'::unit, '1 YB'::unit),
	('1 RiB'::unit, '1 RB'::unit),
	('1 QiB'::unit, '1 QB'::unit),
	('1024 QiB'::unit, '1000 QB'::unit);
