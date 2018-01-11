SELECT round(ampere(1.5));
SELECT round(candela(-0.5));
SELECT round(meter(1500.5));

SET extra_float_digits = 0;
SELECT '1|3m'::unit, '25m'::unit @ 'ft', '25m'::unit @@ 'ft';
SET extra_float_digits = 3;
SELECT '1|3m'::unit, '25m'::unit @ 'ft', '25m'::unit @@ 'ft';
SET extra_float_digits = -3;
SELECT '1|3m'::unit, '25m'::unit @ 'ft', '25m'::unit @@ 'ft';
SET extra_float_digits = -12;
SELECT '1|3m'::unit, '25m'::unit @ 'ft', '25m'::unit @@ 'ft';
SET extra_float_digits = -15;
SELECT '1|3m'::unit, '25m'::unit @ 'ft', '25m'::unit @@ 'ft';
