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
