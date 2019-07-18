SI Units for PostgreSQL
=======================
Christoph Berg <cb@df7cb.de>

**postgresql-unit** implements a *PostgreSQL datatype for
[SI units](https://en.wikipedia.org/wiki/International_System_of_Units), plus byte*.
The eight base units can be combined to arbitrarily complex derived units using
operators defined in the PostgreSQL type system. SI and
[IEC binary](https://en.wikipedia.org/wiki/Binary_prefix) prefixes are
used for input and output, and quantities can be converted to arbitrary scale.

Unit and prefix definitions are retrieved from database tables, and new
definitions can be added at run time. The extension comes with over 2500 units
and over 100 prefixes found in the [definitions.units file](definitions.units)
in [*GNU Units*](https://www.gnu.org/software/units/).

Requires PostgreSQL 9.5 or later (uses *HASH_BLOBS*), flex, and bison 3 (the
pre-built grammar files are used if only bison 2 is available).

[Changelog](NEWS.md)

[![Build Status](https://travis-ci.org/df7cb/postgresql-unit.svg?branch=master)](https://travis-ci.org/df7cb/postgresql-unit)

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
* operators: **+, -, *, /, ^**, conversion to arbitrary scale (**@, @@**)
* aggregate functions
* range type

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

# SELECT '1 kilosecond'::unit AS time;
    time
------------
 00:16:40 s

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

# SELECT unitrange('earthradius_polar', 'earthradius_equatorial') AS earthradius;
               earthradius
-----------------------------------------
 ["6.35675174834046 Mm","6.37813649 Mm")
```

Installation
------------

* Homepage: https://github.com/df7cb/postgresql-unit
* Debian package: https://tracker.debian.org/pkg/postgresql-unit
* Arch package: https://aur.archlinux.org/packages/postgresql-unit/

To compile from source, install the PostgreSQL server headers, `flex`, and
`bison`. Example on Debian:

```
sudo apt-get install build-essential postgresql-server-dev-10 flex bison
make PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config
sudo make install PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config
```

Docker
------

To try out this extension, there is an easy way with docker.

This is a [multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/) ontop of the [official postgres docker image](https://hub.docker.com/_/postgres).

You can easily switch the PostgreSQL Version in the [Dockerfile](docker/Dockerfile).

```
docker build -t postgresql-unit docker/

docker run --name postgresql-unit -p 127.0.0.1:5432:5432 -d postgresql-unit

# wait a few seconds for the database to setup...
docker exec -itu postgres postgresql-unit psql
psql (11.4 (Debian 11.4-1.pgdg90+1))
Type "help" for help.

postgres=# SELECT '2 m/s'::unit@'km/h';
 ?column?
----------
 7.2 km/h
(1 row)
```
or connect with your favorite database client to `127.0.0.1:5432` (user: `postgres` pw: `postgres`).

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

* `unit.time_output_custom`:
  Set to on to output time unit values greater or equal to 60 s using minutes,
  hours, days, and julianyears instead of seconds with SI prefixes.
  (Default: on)

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

This is also the format used in binary mode in the PostgreSQL wire protocol.

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

The [definitions.units](definitions.units) file is an interesting read on its
own due to extensive comments explaining the history and origin of the units
covered.

The `unit_load()` function can be used to reload the `unit_prefixes.data` and
`unit_units.data` files from disk. Extension upgrades use it to load newly
added or changed definitions, but it is also user-callable. User-defined
entries are preserved.

User-Defined Prefixes and Units
-------------------------------

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
* use `hh:mm:ss[.sss]` for time values, e.g. `10:05:30 s`

*Note: This covers the unit input parser for expressions like
`'1|2 m / h'::unit`. PostgreSQL operators on type unit values are a separate
layer; PostgreSQL's operator precedence applies there.*

Output Syntax
-------------

Internally, unit values are always stored in base units. On output, values are
generally formatted as `+-N x*y/z*w` where `+-N` is a floating point number,
and `x*y/z*w` is a set of base units with exponents. Specific combinations of
base units are formatted differently (unless `unit.output_base_units` is set):

* Time (seconds) is formatted as `N commonyear + hh:mm:ss.sss s` if the
  value is at least one minute, and `unit.time_output_custom` is set (the
  default). Otherwise, time is formatted as by the next rules.

* If the set of base units matches one of the following well-known derived units,
  output is formatted using SI prefixes and that unit.

  | Unit | Name    | Dimension                             | Units  | Base Units         |
  | ---- | ------- | ------------------------------------- | ------ | ------------------ |
  | Hz   | hertz   | frequency                             |        | s^-1               |
  | N    | newton  | force, weight                         |        | kg·m·s^-2          |
  | Pa   | pascal  | pressure, stress                      | N/m^2  | kg·m^-1·s^-2       |
  | J    | joule   | energy, work, heat                    | N·m    | kg·m^2·s^-2        |
  | W    | watt    | power, radiant flux                   | J/s    | kg·m^2·s^-3        |
  | C    | coulomb | electric charge                       |        | s·A                |
  | V    | volt    | voltage                               | W/A    | kg·m^2·s^-3·A^-1   |
  | F    | farad   | electric capacitance                  | C/V    | kg^-1·m^-2·s^4·A^2 |
  | Ω    | ohm     | electric resistance, impedance        | V/A    | kg·m^2·s^-3·A^-2   |
  | S    | siemens | electrical conductance                | A/V    | kg^-1·m^-2·s^3·A^2 |
  | Wb   | weber   | magnetic flux                         | V·s    | kg·m^2·s^-2·A^-1   |
  | T    | tesla   | magnetic flux density                 | Wb/m^2 | kg·s^-2·A^-1       |
  | H    | henry   | inductance                            | Wb/A   | kg·m^2·s^-2·A^-2   |
  | lx   | lux     | illuminance                           | lm/m^2 | m^-2·cd            |
  | Gy   | gray    | absorbed dose (of ionizing radiation) | J/kg   | m^2·s^-2           |
  | kat  | katal   | catalytic activity                    |        | mol·s^-1           |

  *Note:* this does not preserve the input dimension, e.g. `N m` (torque) is
  converted to `J` (energy).

* If the dimension numerator is exactly a base unit (with exponent 1), output
  is formatted using SI prefixes and that unit, followed by the denominator
  units, if any.

  * If that unit is Bytes, and `unit.byte_output_iec` is set, IEC prefixes are
    used instead.

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
           Objects in extension "unit"
                Object description
--------------------------------------------------
 function ampere(double precision)
 function au(double precision)
 function avg(unit)
 function becquerel(double precision)
 function byte(double precision)
 function candela(double precision)
 function cbrt(unit)
 function celsius(double precision)
 function coulomb(double precision)
 function day(double precision)
 function dbl_unit_div(double precision,unit)
 function dbl_unit_mul(double precision,unit)
 function decibel(double precision)
 function degree_arc(double precision)
 function dimension(unit)
 function farad(double precision)
 function gray(double precision)
 function hectare(double precision)
 function henry(double precision)
 function hertz(double precision)
 function hour(double precision)
 function joule(double precision)
 function katal(double precision)
 function kelvin(double precision)
 function kilogram(double precision)
 function liter(double precision)
 function lumen(double precision)
 function lux(double precision)
 function max(unit)
 function meter(double precision)
 function min(unit)
 function minute_arc(double precision)
 function minute(double precision)
 function mole(double precision)
 function newton(double precision)
 function ohm(double precision)
 function pascal(double precision)
 function radian(double precision)
 function round(unit)
 function second_arc(double precision)
 function second(double precision)
 function siemens(double precision)
 function sievert(double precision)
 function sqrt(unit)
 function stddev_pop(unit)
 function stddev_samp(unit)
 function stddev(unit)
 function steradian(double precision)
 function sum(unit)
 function tesla(double precision)
 function tonne(double precision)
 function unit_accum(unit_accum_t,unit)
 function unit_add(unit,unit)
 function unit_at_double(unit,text)
 function unit_at(unit,text)
 function unit_avg(unit_accum_t)
 function unit_cmp(unit,unit)
 function unit_dbl_div(unit,double precision)
 function unit_dbl_mul(unit,double precision)
 function unit_diff(unit,unit)
 function unit_div(unit,unit)
 function unit(double precision)
 function unit_eq(unit,unit)
 function unit_ge(unit,unit)
 function unit_greatest(unit,unit)
 function unit_gt(unit,unit)
 function unit_in(cstring)
 function unit_is_hashed(cstring)
 function unit_least(unit,unit)
 function unit_le(unit,unit)
 function unit_load()
 function unit_lt(unit,unit)
 function unit_mul(unit,unit)
 function unit_neg(unit)
 function unit_ne(unit,unit)
 function unit_out(unit)
 function unit_pow(unit,integer)
 function unitrange(unit,unit)
 function unitrange(unit,unit,text)
 function unit_recv(internal)
 function unit_reset()
 function unit_send(unit)
 function unit_stddev_pop(unit_accum_t)
 function unit_stddev_samp(unit_accum_t)
 function unit_strict_cmp(unit,unit)
 function unit_strict_eq(unit,unit)
 function unit_strict_ge(unit,unit)
 function unit_strict_gt(unit,unit)
 function unit_strict_le(unit,unit)
 function unit_strict_lt(unit,unit)
 function unit_strict_ne(unit,unit)
 function unit_sub(unit,unit)
 function unit_var_pop(unit_accum_t)
 function unit_var_samp(unit_accum_t)
 function value(unit)
 function variance(unit)
 function var_pop(unit)
 function var_samp(unit)
 function volt(double precision)
 function watt(double precision)
 function weber(double precision)
 operator class unit_ops for access method btree
 operator class unit_strict_ops for access method btree
 operator /(double precision,unit)
 operator *(double precision,unit)
 operator family unit_ops for access method btree
 operator family unit_strict_ops for access method btree
 operator ||/(NONE,unit)
 operator |/(NONE,unit)
 operator -(NONE,unit)
 operator /(unit,double precision)
 operator *(unit,double precision)
 operator ^(unit,integer)
 operator @(unit,text)
 operator @@(unit,text)
 operator <<=(unit,unit)
 operator <<>>(unit,unit)
 operator <<(unit,unit)
 operator <=(unit,unit)
 operator <>(unit,unit)
 operator <(unit,unit)
 operator ==(unit,unit)
 operator =(unit,unit)
 operator >=(unit,unit)
 operator >>=(unit,unit)
 operator >>(unit,unit)
 operator >(unit,unit)
 operator -(unit,unit)
 operator /(unit,unit)
 operator *(unit,unit)
 operator +(unit,unit)
 table unit_prefixes
 table unit_units
 type unit
 type unit_accum_t
 type unitrange
(136 rows)

```

Details:

* **dimension(unit): unit**

  Returns the dimension of a unit value, i.e. its base units with a normalized
  value of 1.

* **value(unit): double precision**

  Returns the numeric part of a unit value.

* **round(unit): unit**

  Rounds a unit value to the nearest integer (in base units).

* **unit @ text: text** -- scale conversion, output with unit

  Converts a unit value on the left side to the scale of the unit on the right
  side. The units must have the same dimension. The unit on the right side can
  include a numeric component (`num unit`), in which case the output is of the
  form `val * num unit`.

* **unit @@ text: double precision** -- scale conversion, value output only

  Same as the `@` operator, but returns the value of the scaled unit as
  double precision number.

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

*Note*: Starting with PostgreSQL 12, the default value for `extra_float_digits`
is 1, so all printed float values are exact. This makes many converted units
(like inch to meters) have a lengthy decimal representation ending in ...0001
or ...9997. In order to restore the "nice" display behavior, e_f_t=1 is
internally converted to e_f_t=0 in these PostgreSQL versions. Values returned
as floats (like from the `value()` function and the `@@` operator) will still
have the "new" representation; set e_f_t=0 to disable. Set e_f_t to 2 or 3 to
force the new, exact representation.

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

Copyright (C) 2016-2019 Christoph Berg

The definitions.units file is
Copyright (C) 1996-2018 Free Software Foundation, Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
