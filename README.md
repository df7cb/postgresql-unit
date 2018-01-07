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
* about 2400 other units imported from GNU Units (including some humorous ones)
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
----------------------
 33.3333333333333 m/s

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

Installation
------------

* Homepage: https://github.com/ChristophBerg/postgresql-unit
* Debian package: https://tracker.debian.org/pkg/postgresql-unit
* Arch package: https://aur.archlinux.org/packages/postgresql-unit/

To compile from source, install the PostgreSQL server headers, `flex`, and
`bison`. Example on Debian:

```
sudo apt-get install build-essential postgresql-server-dev-10 flex bison
make PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config
sudo make install PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config
```

Config
------

* `unit.byte_output_iec`:
  Set to `on` to format byte quantities using IEC binary prefixes (Ki, Mi, ...)
  on output by default. (Default: off)

* `unit.output_base_units`:
  Set to `on` to format values using only base types without prefixes.
  (Default: off)

* `unit.output_superscript`:
  Set to `on` to output unit exponents using Unicode superscripts.
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

All operators and functions operate with that base-units-only format.
Conversion from and to other unit representations is done on input, output, and
using the `@` operator only.

Prefixes and Units Lookup Tables
--------------------------------

Prefixes are defined in the table `unit_prefixes`:

```
CREATE TABLE unit_prefixes (
    prefix varchar(32) PRIMARY KEY,
    factor double precision NOT NULL,
    definition text, -- original definition, informational
    dump boolean DEFAULT true
);
```

Units are defined in the table `unit_units`:

```
CREATE TABLE unit_units (
    name varchar(32) PRIMARY KEY,
    unit unit NOT NULL,
    shift double precision, -- NULL means 0.0 here
    definition text, -- original definition, informational
    dump boolean DEFAULT true
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
`unit_is_hashed()` reports if a given unit name is already cached. The function
`unit_reset()` clears the hash table. Use it if unit definitions are changed.)

The `definition` column is only provided for information on how the unit was
originally defined.

GNU Units
---------

On installation, the prefixes and units definitions tables are populated with
data imported from the `definitions.units` file found in the GNU Units tool.
Notable omissions are currency units (we don't have a base type for them, and
exchange rates aren't static anyway), and non-linear units such as dBm based
on dB and other conversions based on functions and lookup tables.

The `definitions.units` file is an interesting read on its own due to extensive
comments explaining the history and origins or the units covered.

User-Defined Units
------------------

To create custom prefixes and units, insert new rows into the tables:

```
# SELECT '1 foobar'::unit;
ERROR:  unit "foobar" is not known
# INSERT INTO unit_prefixes VALUES ('foo', 42);
INSERT 0 1
# SELECT '1 foobar'::unit;
  unit
---------
 4.2 MPa

# INSERT INTO unit_units VALUES ('legobrick', '9.6 mm');
# SELECT '1 m'::unit @ 'legobricks' AS one_meter;
          one_meter
-----------------------------
 104.166666666667 legobricks
```

*Note: If user-defined (or built-in) units are changed by updating the tables,
call `unit_reset()` to clear the hash table that caches the lookup result.
Otherwise, sessions that have already used the unit will continue to use the
old definition.*

Input Syntax
------------

Unit values allow a fairly complex expression syntax on input.

* `expr expr` denotes multiplication
* operators + - * /
* exponentiation: `expr^integer` or Unicode superscripts: `expr⁺⁻⁰¹²³⁴⁵⁶⁷⁸⁹`
* parentheses ()
* multiplication binds tighter than division such that `kg/s^2*A`
  can be written without parentheses
* `N|M` denotes a numeric fraction, e.g. `3|4`

*Note: This covers the unit input parser for expressions like
`'1|2m / h'::unit`. PostgreSQL operators on type unit values are a separate
layer; PostgreSQL's operator precedence applies there.*

Shifted Units
-------------

The `unit_units.shift` column is used for implementing units where 0 is not
absolute zero in base units, i.e. most commonly for temperature units (°C, °F).

Shifted units are often used in ambiguous contexts, the intended meaning
depending on if an absolute value, or a difference between values is requested.
If `20 °C - 15 °C` is requested, the answer `5 K` is clearly correct, but less
so `5 °C`, because that is actually 278.15 K. On the other hand, some
thermodynamic units are defined based on °C, such as
`celsiusheatunit = cal lb (degC) / gram K` where no offset is desired.

This module resolves the ambiguity by only applying the `shift` offset in
*number name* (and plain *name*) expressions such as `5 °F`. In all other
contexts, shifted units behave just like a unit defined on based units without
a shift.

```
# SELECT '5 °F'::unit, '5 * °F'::unit, '5 °F'::unit @ '°C' AS to_celsius, '5 °F'::unit @ '1 * °C' AS celsius_increments;
   unit   |        unit        |      to_celsius      | celsius_increments
----------+--------------------+----------------------+--------------------
 258.15 K | 2.77777777777778 K | -14.9999999999999 °C | 258.15 * 1 * °C
```

PostgreSQL Operators and Functions
----------------------------------

The `unit` extension provides the following objects:

```
function avg(unit)
function cbrt(unit)
function dimension(unit)
function max(unit)
function min(unit)
function round(unit)
function sqrt(unit)
function stddev_pop(unit)
function stddev_samp(unit)
function stddev(unit)
function sum(unit)
function unit_is_hashed(cstring)
function unit_reset()
function value(unit)
function variance(unit)
function var_pop(unit)
function var_samp(unit)
operator class unit_ops for access method btree
operator /(double precision,unit)
operator *(double precision,unit)
operator family unit_ops for access method btree
operator ||/(NONE,unit)
operator |/(NONE,unit)
operator -(NONE,unit)
operator @(unit,text)
operator /(unit,double precision)
operator *(unit,double precision)
operator ^(unit,integer)
operator <=(unit,unit)
operator <>(unit,unit)
operator <(unit,unit)
operator =(unit,unit)
operator >=(unit,unit)
operator >(unit,unit)
operator -(unit,unit)
operator /(unit,unit)
operator *(unit,unit)
operator +(unit,unit)
table unit_prefixes
table unit_units
type unit
type unit_accum_t
```

Internal function names and constructor-like functions (`meter(5)`) are omitted
in this list.

Details:

* **function dimension(unit): unit**

  Returns the dimension of a unit value, i.e. its base units with a normalized
  value of 1.

* **function value(unit): double precision**

  Returns the numeric part of a unit value.

* **function round(unit): unit**

  Rounds a unit value to the nearest integer (in base units).

Rounding
--------

Besides the `round(unit)` function, output precision is determined by
PostgreSQL's `extra_float_digits` GUC. Valid values range from -16 to +3.

```
# SET extra_float_digits = -12;
SET
# SELECT 'c'::unit AS lightspeed;
 lightspeed
------------
 300 Mm/s

# SELECT '25m'::unit @ 'ft' AS feet;
 feet
-------
 82 ft
```

References
----------

* https://en.wikipedia.org/wiki/International_System_of_Units
* http://physics.nist.gov/cuu/Units/index.html
* https://en.wikipedia.org/wiki/Binary_prefix
* https://en.wikipedia.org/wiki/United_States_customary_units
* GNU Units: https://www.gnu.org/software/units/
* Similar library for Ada: http://www.dmitry-kazakov.de/ada/units.htm

License
-------

Copyright (C) 2016-2018 Christoph Berg

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

The definitions.units file is
Copyright (C) 1996-2016 Free Software Foundation, Inc.
