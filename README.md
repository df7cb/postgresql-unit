SI Units for PostgreSQL
=======================
Christoph Berg <cb@df7cb.de>

**postgresql-unit** implements a *PostgreSQL datatype for SI units, plus byte*.
The base units can be combined to named and unnamed derived units using
operators defined in the PostgreSQL type system. SI prefixes are used for input
and output, and quantities can be converted to arbitrary scale. Byte quantities
can also use IEC binary prefixes for input and output.

Some non-SI units are supported, namely *coherent* derived units such as
*newton* and *joule*, *non-coherent* units such as *hours* and *litres*, and
assorted *United States customary units* such as *inch* and *mile*.

Requires PostgreSQL 9.5 or later (uses *HASH_BLOBS*), flex, and bison 3 (the
pre-built grammar files are used if only bison 2 is available).

[![Build Status](https://travis-ci.org/ChristophBerg/postgresql-unit.svg?branch=master)](https://travis-ci.org/ChristophBerg/postgresql-unit)

Features
--------

* SI base types: *meter (m), kilogram (kg), second (s), ampere (A), kelvin (K),
  mole (mol), candela (cd)*
* *byte (B)* is also a base type
* derived units coherent with SI: *radian (rad), steradian (sr), hertz (Hz),
  newton (N), pascal (Pa), joule (J), watt (W), coulomb (C), volt (V), farad
  (F), ohm (Ω), siemens (S), weber (Wb), tesla (T), henry (H), degree Celsius
  (°C, support limited), lumen (lm), lux (lx), becquerel (Bq), gray (Gy),
  sievert (Sv), katal (kat)*
* non-coherent units: *minute (min), hour(h), day(d), hectare (ha), litre (l),
  tonne (t), bar, astronomical unit (au)*
* United States customary units: *inch (in), foot (ft), yard (yd), mile (mi),
  ounce (oz), pound (lb)*
* prefix multiples: *da, h, k, M, G, T, P, E, Z, Y*
* prefix fractions: *d, c, m, μ, n, p, f, a, z, y*
* IEC binary prefix multiples: *Ki, Mi, Gi, Ti, Pi, Ei, Zi, Yi*
* operators: **+, -, *, /, ^**, conversion to arbitrary scale (**@**)

Examples
--------

```
# CREATE extension unit;
CREATE EXTENSION

# SELECT '800 m'::unit + '500 m' AS length;
 length
--------
 1.3 km

# SELECT '120 km/h'::unit AS speed;
    speed
-------------
 33.3333 m/s

# SELECT '9.81 N'::unit / 'kg' AS gravity;
  gravity
------------
 9.81 m/s^2

# SELECT '2 MB/min'::unit @ 'GB/d' AS traffic;
  traffic
-----------
 2.88 GB/d

# SELECT '1 hl'::unit @ '0.5 l' AS bottles_of_beer;
 bottles_of_beer
-----------------
 200 * 0.5 l

# SET unit.byte_output_iec = on;
# SELECT '4 TB'::unit AS disk_sold_as_4tb;
   disk_sold_as_4tb
----------------------
 3.63797880709171 TiB

# SELECT '500 mi'::unit AS walk_500_miles;
 walk_500_miles
----------------
 804.672 km
```

Config
------

* `unit.byte_output_iec`:
  Set to `on` to format byte quantities using IEC binary prefixes (Ki, Mi, ...)
  on output by default. (Default: off)

References
----------

* https://en.wikipedia.org/wiki/International_System_of_Units
* http://physics.nist.gov/cuu/Units/index.html
* https://en.wikipedia.org/wiki/Binary_prefix
* https://en.wikipedia.org/wiki/United_States_customary_units

License
-------

Copyright (C) 2016 Christoph Berg

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
