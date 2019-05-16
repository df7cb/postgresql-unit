-- test aggregates

/* revert to pre-12 default for stddev(value()) tests */
SET extra_float_digits = 0;

CREATE TEMP TABLE u (
	u unit
);

-- empty
SELECT sum(u) AS null_sum FROM u;
SELECT min(u) AS null_min FROM u;
SELECT max(u) AS null_max FROM u;
SELECT avg(u) AS null_avg FROM u;
SELECT var_pop(u) AS null_var_pop FROM u;
SELECT var_samp(u) AS null_var_samp FROM u;
SELECT variance(u) AS null_variance FROM u;
SELECT stddev_pop(u) AS null_stddev_pop FROM u;
SELECT stddev_samp(u) AS null_stddev_samp FROM u;
SELECT stddev(u) AS null_stddev FROM u;

-- one NULL row
INSERT INTO u VALUES (NULL);
SELECT sum(u) AS null_sum FROM u;
SELECT min(u) AS null_min FROM u;
SELECT max(u) AS null_max FROM u;
SELECT avg(u) AS null_avg FROM u;
SELECT var_pop(u) AS null_var_pop FROM u;
SELECT var_samp(u) AS null_var_samp FROM u;
SELECT variance(u) AS null_variance FROM u;
SELECT stddev_pop(u) AS null_stddev_pop FROM u;
SELECT stddev_samp(u) AS null_stddev_samp FROM u;
SELECT stddev(u) AS null_stddev FROM u;

-- one non-NULL row
DELETE FROM u;
INSERT INTO u VALUES (meter(5));
SELECT sum(u) AS five_meters FROM u;
SELECT min(u) AS five_meters FROM u;
SELECT max(u) AS five_meters FROM u;
SELECT avg(u) AS five_meters FROM u;
SELECT var_pop(u) AS zero_var_pop FROM u;
SELECT var_samp(u) AS zero_var_samp FROM u;
SELECT variance(u) AS zero_variance FROM u;
SELECT stddev_pop(u) AS zero_stddev_pop FROM u;
SELECT stddev_samp(u) AS zero_stddev_samp FROM u;
SELECT stddev(u) AS zero_stddev FROM u;

-- two rows, matching dimensions
DELETE FROM u;
INSERT INTO u VALUES (meter()), (meter(2));
SELECT sum(u) AS three_meters FROM u;
SELECT min(u) AS one_meter FROM u;
SELECT max(u) AS two_meters FROM u;
SELECT avg(u) AS oneandhalf_meters FROM u;
SELECT var_pop(u) FROM u;
SELECT var_samp(u) FROM u;
SELECT variance(u) FROM u;
SELECT stddev_pop(u) FROM u;
SELECT stddev_samp(u) FROM u;
SELECT stddev(u) FROM u;

DELETE FROM u;
INSERT INTO u VALUES (kilogram(2)), (kilogram());
SELECT sum(u),         sum(value(u))         FROM u;
SELECT min(u),         min(value(u))         FROM u;
SELECT max(u),         max(value(u))         FROM u;
SELECT avg(u),         avg(value(u))         FROM u;
SELECT var_pop(u),     var_pop(value(u))     FROM u;
SELECT var_samp(u),    var_samp(value(u))    FROM u;
SELECT variance(u),    variance(value(u))    FROM u;
SELECT stddev_pop(u),  stddev_pop(value(u))  FROM u;
SELECT stddev_samp(u), stddev_samp(value(u)) FROM u;
SELECT stddev(u),      stddev(value(u))      FROM u;

-- three rows, one NULL
INSERT INTO u VALUES (NULL);
SELECT sum(u) AS three_kilogram FROM u;
SELECT min(u) AS one_kilogram FROM u;
SELECT max(u) AS two_kilogram FROM u;
SELECT avg(u) AS oneandhalf_kilogram FROM u;
SELECT var_pop(u) FROM u;
SELECT var_samp(u) FROM u;
SELECT variance(u) FROM u;
SELECT stddev_pop(u) FROM u;
SELECT stddev_samp(u) FROM u;
SELECT stddev(u) FROM u;

-- two rows, dimension mismatch
DELETE FROM u;
INSERT INTO u VALUES (ampere()), (kilogram(2));
SELECT sum(u) AS error FROM u;
SELECT min(u) AS error FROM u;
SELECT max(u) AS error FROM u;
SELECT avg(u) AS error FROM u;
SELECT var_pop(u) AS error FROM u;
SELECT var_samp(u) AS error FROM u;
SELECT variance(u) AS error FROM u;
SELECT stddev_pop(u) AS error FROM u;
SELECT stddev_samp(u) AS error FROM u;
SELECT stddev(u) AS error FROM u;
