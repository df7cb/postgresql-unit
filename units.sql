CREATE TEMP TABLE units (u) AS
  VALUES
	-- unity
	('1'::unit),
	-- base units
	(meter()),
	(kilogram()),
	(second()),
	(ampere()),
	(kelvin()),
	(mole()),
	(candela()),
	(byte()),
	-- coherent derived units
	(hertz()),
	(newton()),
	(pascal()),
	(joule()),
	(watt()),
	(coulomb()),
	(volt()),
	(farad()),
	(ohm()),
	(siemens()),
	(weber()),
	(tesla()),
	(henry()),
	(lux()),
	(katal());
