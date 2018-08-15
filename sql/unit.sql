-- test input and output
SELECT '1'::unit; -- unit_in
SELECT unit(1); -- dbl2unit
CREATE TEMP TABLE u (u unit);
INSERT INTO u VALUES ('1');
SELECT * FROM u;

-- test constructors
SELECT meter();
SELECT meter(2.0) AS two_meters;
SELECT kilogram();
SELECT kilogram(3.0) AS three_kilogram;
SELECT second();
SELECT second(4.0) AS four_seconds;
SELECT ampere();
SELECT ampere(5.0) AS five_ampere;
SELECT kelvin();
SELECT kelvin(6.0) AS six_kelvin;
SELECT mole();
SELECT mole(7.0) AS seven_mole;
SELECT candela();
SELECT candela(8.0) AS eight_candela;
SELECT byte();
SELECT byte(9.0) AS nine_byte;

-- test dimensionless scales
SELECT unit(0) AS zero, unit(1e-6) AS "1e-6", unit(0.001) AS "0.001", unit(1.0) AS "1", unit(1000.0) AS "1000";
-- test SI prefixes
SELECT meter(0) AS zero, meter(1e-6) AS "µm", meter(0.001) AS mm, meter(1.0) AS m, meter(1000.0) AS km;
SELECT kilogram(0) AS zero, kilogram(1e-6) AS mg, kilogram(0.001) AS g, kilogram(1.0) AS kg, kilogram(1000.0) AS "Mg";
-- test combined units (exactly one unit with exponent 1 in numerator)
SELECT meter(0)/second() AS zero, meter(1e-6)/second() AS "µm", meter(0.001)/second() AS mm, meter(1.0)/second() AS m, meter(1000.0)/second() AS km;
SELECT kilogram(0)/second() AS zero, kilogram(1e-6)/second() AS mg, kilogram(0.001)/second() AS g, kilogram(1.0)/second() AS kg, kilogram(1000.0)/second() AS "Mg";

-- test parser
SELECT '1 m'::unit;
SELECT '-1 m/s'::unit;
SELECT '10 dm^3'::unit, '10l'::unit;
SELECT '9.81 kg*m/s^2'::unit, '9.81 kg*m/s*s'::unit, '9.81 kg*m/s/s'::unit;
SELECT '1 foobar'::unit AS error;

-- special values
SELECT '-0'::unit, -'0'::unit, '-0 m'::unit, -'0 m'::unit;
SELECT 'infinity'::unit, 'Infinity m'::unit, 'inf A'::unit;
SELECT '-infinity'::unit, '-Infinity m'::unit, 'Inf A'::unit;
SELECT 'nan'::unit, 'NaN'::unit;

-- test parser arithmetic
SELECT '1|10'::unit, '1|10 m'::unit;
SELECT '2 m + 3 m - 4 m'::unit, '6 m - 3 m - 2 m'::unit, '6 m - 3 m + 1 m'::unit;
SELECT '2 m * 3 m'::unit, '2 m / 3 m'::unit, '10 m / 5 m / 2 m'::unit;
SELECT '2 m^2 + 3 m * 4 m'::unit, '2 m * 3 m / 4 m * 5 m'::unit;
SELECT '2 m * (1 m + 3 m)'::unit;
SELECT '- m'::unit, '/ m'::unit;
SELECT '4+5'::unit, '4-5'::unit, '4(-5)'::unit, '4*5'::unit, '4/5'::unit;

-- problematic cases
SELECT '1 cd'::unit AS candela; -- candela vs centiday
SELECT '1 Pa'::unit AS pascal; -- pascal vs petayear
SELECT '1 yg'::unit AS yoctogram, '1.00001 yg'::unit AS actual_yoctogram; -- "yg" had rounding problems in the past
SELECT '1 min'::unit AS minute; -- minute vs milliinch
SELECT '1 ft'::unit AS foot; -- foot vs femtotonne
SELECT '1 yd'::unit AS yard; -- yard vs yoctoday

-- units whose definition changed between v2 and 3
SELECT 'a'::unit AS are;
SELECT 'da'::unit AS day;
SELECT 'rad'::unit AS radiation;

-- check which prefix/unit combinations produce other dimensions (parser conflicts)
SELECT
  p, u, (p||u)::unit
FROM
  prefixes CROSS JOIN units
WHERE
  u <> 'kg' AND
  dimension(u::unit) != dimension((p||u)::unit) AND
  p||u NOT IN ('dat') -- skip ambiguous unit
ORDER BY lower(p) COLLATE "C", lower(u) COLLATE "C";
