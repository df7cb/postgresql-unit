-- creating new units

CREATE FUNCTION unit_new(cstring, unit)
	RETURNS void
	AS '$libdir/unit'
	LANGUAGE C IMMUTABLE STRICT;
