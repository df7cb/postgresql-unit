DROP EXTENSION IF EXISTS unit;
CREATE EXTENSION IF NOT EXISTS unit VERSION "1";

CREATE TABLE IF NOT EXISTS pg_depend_save (LIKE pg_depend);
BEGIN;
	DELETE FROM pg_depend_save;
	WITH
		ext AS (DELETE FROM pg_depend WHERE refobjid =
			(SELECT oid FROM pg_extension WHERE extname = 'unit')
			RETURNING *)
	INSERT INTO pg_depend_save SELECT * FROM ext;
COMMIT;
\! pg_dump -f unit-1.dump -T pg_depend_save
INSERT INTO pg_depend SELECT * FROM pg_depend_save;

ALTER EXTENSION unit UPDATE TO "2";

BEGIN;
	DELETE FROM pg_depend_save;
	WITH
		ext AS (DELETE FROM pg_depend WHERE refobjid =
			(SELECT oid FROM pg_extension WHERE extname = 'unit')
			RETURNING *)
	INSERT INTO pg_depend_save SELECT * FROM ext;
COMMIT;
\! pg_dump -f unit-1-2.dump -T pg_depend_save
INSERT INTO pg_depend SELECT * FROM pg_depend_save;

DROP EXTENSION unit;
CREATE EXTENSION unit;

BEGIN;
	DELETE FROM pg_depend_save;
	WITH
		ext AS (DELETE FROM pg_depend WHERE refobjid =
			(SELECT oid FROM pg_extension WHERE extname = 'unit')
			RETURNING *)
	INSERT INTO pg_depend_save SELECT * FROM ext;
COMMIT;
\! pg_dump -f unit-2.dump -T pg_depend_save
INSERT INTO pg_depend SELECT * FROM pg_depend_save;
