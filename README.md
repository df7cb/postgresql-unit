SI Units for PostgreSQL
=======================
Christoph Berg <cb@df7cb.de>

postgresql-unit implements a PostgreSQL datatype for SI units, plus byte. The
base units can be combined to named and unnamed derived units using operators
defined in the PostgreSQL type system. SI prefixes are used for input and
output, and quantities can be converted to arbitrary scale.

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
  tonne (t), astronomical unit (au)*
* prefix multiples: *da, h, k, M, G, T, P, E, Z, Y*
* prefix fractions: *d, c, m, μ, n, p, f, a, z, y*
* operators: **+, -, *, /, ^**, conversion to arbitrary scale (*@*)

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
```

References
----------

* https://en.wikipedia.org/wiki/International_System_of_Units

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
