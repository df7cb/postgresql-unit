7.7: Jan 06, 2023
-----------------
* Fix printing of values around 1e33 on i386.

7.6: Jan 04, 2023
-----------------
* Import definitions.units September 2022 Version 3.15.
* Add R ronna, Q quetta, r ronto, Q quecto, Ri robi, Qi quebi prefixes.

7.4: May 20, 2021 - World Metrology Day
---------------------------------------
* Fix hash table creation on PostgreSQL 14.

7.3: Oct 19, 2020
-----------------
* Packaging updates.

7.2: May 20, 2019 - World Metrology Day
---------------------------------------
* Rewire PostgreSQL 12's new extra_float_digits=1 default internally to 0 to
  keep nice, short decimal representations.

7.1: Dec 3, 2018
----------------
* Import definitions.unit 2.44 from units 2.18 with 36 new units.
  When upgrading from a previous install, use `SELECT unit_load();` to import.
* Adjust powers.h to round "1" down by one ULP.

7.0: Sep 28, 2018
-----------------
* Format time using commonyears + days + hh:mm:ss.sss s.
* Avoid using Gs for Gigaseconds, that's actually gauss.
* Modify @(unit, text) operator to return text instead of cstring.
* Import definitions.units from GNU units 2.17 with 13 new units.
* Add π to known units.
* Remove bison 2 compat mode, but keep pregenerated files for jessie and
  trusty.
* Support send/receive via the binary protocol.
* Support Infinity and NaN.
* Add strict comparison operators that error out when dimensions of arguments
  do not match: << <<= == <<>> >>= >>.
* Add range type over units: unitrange.

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
