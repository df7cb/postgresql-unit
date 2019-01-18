SET client_min_messages = warning;
DROP TABLE IF EXISTS unittypmod;
RESET client_min_messages;
CREATE TABLE unittypmod (
	--one unit(1),
	length unit('LENGTH'),
	area unit('AREA')
);

\d unittypmod

SELECT 'foo'::unit('');
SELECT 'foo'::unit(1);
SELECT 'foo'::unit(LENGTH);
SELECT 'foo'::unit(AREA);
SELECT 'foo'::unit(foo);
SELECT 'foo'::unit(4);
