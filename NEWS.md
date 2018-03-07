6.0: Mar 7, 2018
----------------
* Add @@ operator: similar to @, but returns the value of the resulting unit
  as double precision number.
* Fix parsing of addition/subtraction in unit values.
* Grant SELECT on unit prefixes and units table to public.
* Add unit_load() function to load/update the data tables.

5.0: Jan 10, 2018
-----------------
* Add rounding function.
* Import definitions.units from GNU units 2.16 with 70 new units.

4.0: Jul 7, 2017
----------------
* Support exponents written using Unicode superscript characters.
* Report 22P02/invalid_text_representation on invalid unit input.
* Fix crash when unit_reset() runs into an OOM error. Patch by Andreas
  Seltenreich, thanks!
* Change @ operator signature to (unit, text).

3.0: Mar 22, 2017
-----------------
* Support defining new units at runtime.
* Import unit definitions from GNU units.
* Add sqrt() and cbrt() functions.
* Extension is not relocatable after installation anymore.
* Bump extension version to 3.
* Bump minimum supported PostgreSQL version to 9.5 so we can use
  hash_create(HASH_BLOBS).
* Bump license to GPL-3+ to match GNU units' license.

2.0: Jan 9, 2017
----------------
* Support IEC binary prefixes for byte.
* Support United States customary units: in, ft, yd, mi, oz, lb.
* Add variance and stddev aggregates

1.1: Oct 31, 2016
-----------------
* Use float8out_internal to format floats on output.

v1.0: Sep 22, 2016
------------------
* Initial release
