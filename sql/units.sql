SELECT * FROM unit_prefixes ORDER BY factor, prefix;

SELECT * FROM unit_units ORDER BY dimension(unit), unit, name;

-- units that do not conform to their original definition
SELECT *, definition::unit AS parsed_definition, unit / definition::unit AS deviation
  FROM unit_units WHERE unit <> definition::unit;

-- prefix-unit combinations that are ambiguous
/* runs several minutes:
CREATE OR REPLACE FUNCTION valid_unit(u text)
RETURNS boolean LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM u::unit;
	RETURN true;
EXCEPTION
WHEN OTHERS THEN
	RETURN false;
END;
$$;

SELECT prefix, name
FROM unit_prefixes CROSS JOIN unit_units
WHERE NOT valid_unit(prefix||name)
ORDER BY prefix, name;
*/

SELECT 'daA'::unit;
SELECT 'dasb'::unit;
SELECT 'dat'::unit;
SELECT 'dau'::unit;
SELECT 'daustbl'::unit;
SELECT 'daustblsp'::unit;
SELECT 'daustbsp'::unit;
SELECT 'daustsp'::unit;
SELECT 'Eint'::unit;
SELECT 'Gint'::unit;
SELECT 'Mint'::unit;
SELECT 'Pint'::unit;
SELECT 'Tint'::unit;
SELECT 'yoctodecillion'::unit;
