-- prefix/unit definition tables

CREATE TABLE unit_prefixes (
	prefix varchar(32) PRIMARY KEY,
	factor double precision NOT NULL,
	definition text NOT NULL
);

CREATE TABLE unit_units (
	name varchar(32) PRIMARY KEY,
	unit unit, -- TODO: NOT NULL
	definition text NOT NULL
);

-- creating new units

CREATE FUNCTION unit_new(cstring, unit)
	RETURNS void
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;
