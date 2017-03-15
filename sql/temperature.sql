SELECT * FROM unit_units WHERE name IN (
	'K', 'kelvin',
	'℃', '°C', 'degC', 'degcelsius',
	'℉', '°F', 'degF', 'degfahrenheit',
	'°R', 'degR', 'degrankine', 'degreerankine', 'degreesrankine', 'tempR', 'temprankine',
	'degreaumur')
ORDER BY name COLLATE "C";

-- Kelvin
SELECT '0 K'::unit, 'K'::unit, '1 K'::unit, '273.15 K'::unit;

-- Celsius
SELECT '-273.15 ℃'::unit, '0 ℃'::unit, '1 ℃'::unit, '℃'::unit;
SELECT '-273.15 °C'::unit, '0 °C'::unit, '1 °C'::unit, '°C'::unit;
SELECT '-273.15 degC'::unit, '0 degC'::unit, '1 degC'::unit, 'degC'::unit;
SELECT '-273.15 degcelsius'::unit, '0 degcelsius'::unit, '1 degcelsius'::unit, 'degcelsius'::unit;

-- Fahrenheit
SELECT '-459.670000000000016 ℉'::unit, '0 ℉'::unit, '1 ℉'::unit, '℉'::unit;
SELECT '-459.670000000000016 °F'::unit, '0 °F'::unit, '1 °F'::unit, '°F'::unit;
SELECT '-459.670000000000016 degF'::unit, '0 degF'::unit, '1 degF'::unit, 'degF'::unit;
SELECT '-459.670000000000016 degfahrenheit'::unit, '0 degfahrenheit'::unit, '1 degfahrenheit'::unit, 'degfahrenheit'::unit;

-- Rankine
SELECT '491.67 degR'::unit, '0 degR'::unit, '1 degR'::unit, 'degR'::unit;

-- Réaumur
SELECT '-218.519999999999982 degreaumur'::unit, '0 degreaumur'::unit, '1 degreaumur'::unit, 'degreaumur'::unit;

SELECT '0 K'::unit @ 'K', '0 K'::unit @ '°C', '0 K'::unit @ '°F', '0 K'::unit @ '°R', '0 K'::unit @ 'degreaumur';
SELECT '273.15 K'::unit @ 'K', '273.15 K'::unit @ '°C', '273.15 K'::unit @ '°F', '273.15 K'::unit @ '°R', '273.15 K'::unit @ 'degreaumur';
