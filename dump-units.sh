#!/bin/sh

# output intentionally not ordered so the initial load order from definitions.units is preserved
psql <<-EOT
	SET extra_float_digits = 3;
	SET unit.output_base_units = on;
	\copy (SELECT prefix, factor, definition, dump FROM unit_prefixes ORDER BY ordering) to 'unit_prefixes.data'
	\copy (SELECT name, unit, shift, definition, dump FROM unit_units ORDER BY ordering) to 'unit_units.data'
EOT
