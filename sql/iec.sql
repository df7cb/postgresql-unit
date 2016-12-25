VALUES
	(('1 B'::unit)),
	(('1 KiB'::unit)),
	(('1 MiB'::unit)),
	(('1 GiB'::unit)),
	(('1 TiB'::unit)),
	(('1 PiB'::unit)),
	(('1 EiB'::unit)),
	(('1 ZiB'::unit)),
	(('1 YiB'::unit));

VALUES
	(('1 B'::unit @ 'B')),
	(('1 KiB'::unit @ 'KiB')),
	(('1 MiB'::unit @ 'MiB')),
	(('1 GiB'::unit @ 'GiB')),
	(('1 TiB'::unit @ 'TiB')),
	(('1 PiB'::unit @ 'PiB')),
	(('1 EiB'::unit @ 'EiB')),
	(('1 ZiB'::unit @ 'ZiB')),
	(('1 YiB'::unit @ 'YiB'));

VALUES
	(('1 B'::unit @ 'B')),
	(('1 kB'::unit @ 'KiB')),
	(('1 MB'::unit @ 'MiB')),
	(('1 GB'::unit @ 'GiB')),
	(('1 TB'::unit @ 'TiB')),
	(('1 PB'::unit @ 'PiB')),
	(('1 EB'::unit @ 'EiB')),
	(('1 ZB'::unit @ 'ZiB')),
	(('1 YB'::unit @ 'YiB'));

-- errors
SELECT '1 kiB'::unit;
SELECT '1 Ki'::unit;
SELECT '1 Kim'::unit;
