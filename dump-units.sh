#!/bin/sh

# output intentionally not ordered so the initial load order from definitions.units is preserved
psql <<-EOT
	SET extra_float_digits = 3;
	SET unit.output_base_units = on;
	\copy unit_prefixes to 'unit_prefixes.data'
	\copy unit_units to 'unit_units.data'
EOT
