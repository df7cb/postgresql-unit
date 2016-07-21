-- test input and output
SELECT '1'::unit;
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
