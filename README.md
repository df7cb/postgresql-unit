SI Units for PostgreSQL
=======================
Christoph Berg <cb@df7cb.de>

**postgresql-unit** implements a *PostgreSQL datatype for SI units, plus byte*.
The eight base units can be combined to arbitrarily complex derived units using
operators defined in the PostgreSQL type system. SI and IEC binary prefixes are
used for input and output, and quantities can be converted to arbitrary scale.

Unit and prefix definitions are retrieved from database tables, and new
definitions can be added at run time. The extension comes with over 2400 units
and over 100 prefixes predefined in the definitions.units file found in *GNU
Units*.

Requires PostgreSQL 9.5 or later (uses *HASH_BLOBS*), flex, and bison 3 (the
pre-built grammar files are used if only bison 2 is available).

[![Build Status](https://travis-ci.org/ChristophBerg/postgresql-unit.svg?branch=master)](https://travis-ci.org/ChristophBerg/postgresql-unit)

Features
--------

* Base types: *meter (m), kilogram (kg), second (s), ampere (A), kelvin (K),
  mole (mol), candela (cd), byte (B)*
* derived units coherent with SI: *radian (rad), steradian (sr), hertz (Hz),
  newton (N), pascal (Pa), joule (J), watt (W), coulomb (C), volt (V), farad
  (F), ohm (Ω), siemens (S), weber (Wb), tesla (T), henry (H), degree Celsius
  (°C, support limited), lumen (lm), lux (lx), becquerel (Bq), gray (Gy),
  sievert (Sv), katal (kat)*
* non-coherent units: *minute (min), hour(h), day(d), hectare (ha), litre (l),
  tonne (t), bar, astronomical unit (au)*
* United States customary units: *inch (in), foot (ft), yard (yd), mile (mi),
  ounce (oz), pound (lb)*
* about 2400 other units imported from GNU Units
* prefix multiples: *da, h, k, M, G, T, P, E, Z, Y*
* prefix fractions: *d, c, m, μ, n, p, f, a, z, y*
* IEC binary prefix multiples: *Ki, Mi, Gi, Ti, Pi, Ei, Zi, Yi*
* other prefixes imported from GNU Units
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

* `unit.output_base_units`:
  Set to `on` to format values using only base types without prefixes.
  (Default: off)

Internal Representation
-----------------------

Internally, `unit` datums are a 16-byte struct consisting of a double precision
floating point number for the unit value, and an array of 8 signed character
values to store the exponents of the base units for the unit dimension.

```
typedef struct Unit {
    double      value;
    signed char units[N_UNITS];
} Unit;
```

Prefixes and Units Lookup Tables
--------------------------------

Prefixes are defined in the table `unit_prefixes`:

```
CREATE TABLE unit_prefixes (
    prefix varchar(32) PRIMARY KEY,
    factor double precision NOT NULL,
    definition text NOT NULL
);
```

Units are defined in the table `unit_units`:

```
CREATE TABLE unit_units (
    name varchar(32) PRIMARY KEY,
    unit unit NOT NULL,
    definition text NOT NULL
);
```

Whenever the unit input lexer encounters a unit name, it queries the
`unit_units` table to see if the definition is found. If no match is found, the
`unit_prefixes` and `unit_units` tables are cross-joined to see if the
concatenation of prefix and unit name matches. At this point, an error is
thrown if the prefix-unit combination is ambiguous, e.g. for "dat" which is
either a dekatonne (da-t) or a deciatmosphere (d-at). If no match is found, and
the unit name is ending with 's' (e.g. "kilometers" or "lbs"), the two lookup
steps are repeated with the trailing 's' removed.

If the unit definition could be resolved, the result is stored in a
backend-local hash table to speed up the next lookup. (The function
`unit_is_hashed()` reports if a given unit name is already cached.)

References
----------

* https://en.wikipedia.org/wiki/International_System_of_Units
* http://physics.nist.gov/cuu/Units/index.html
* https://en.wikipedia.org/wiki/Binary_prefix
* https://en.wikipedia.org/wiki/United_States_customary_units
* GNU Units: https://www.gnu.org/software/units/

License
-------

Copyright (C) 2016-2017 Christoph Berg

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

The definitions.units file is
Copyright (C) 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2004, 2005, 2006
              2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
Free Software Foundation, Inc
