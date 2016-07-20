-- test aggregates

CREATE TEMP TABLE u (
	u unit
);

SELECT sum(u) AS null_sum FROM u;
SELECT min(u) AS null_min FROM u;
SELECT max(u) AS null_max FROM u;

INSERT INTO u VALUES (meter()), (meter(2));
SELECT sum(u) AS three_meters FROM u;
SELECT min(u) AS one_meter FROM u;
SELECT max(u) AS two_meters FROM u;

DELETE FROM u;
INSERT INTO u VALUES (kilogram(2)), (kilogram());
SELECT sum(u) AS three_kilogram FROM u;
SELECT min(u) AS one_kilogram FROM u;
SELECT max(u) AS two_kilogram FROM u;

DELETE FROM u;
INSERT INTO u VALUES (ampere()), (kilogram(2));
SELECT sum(u) AS error FROM u;
SELECT min(u) AS error FROM u;
SELECT max(u) AS error FROM u;
