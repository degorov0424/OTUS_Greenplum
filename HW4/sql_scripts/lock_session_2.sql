-- транзакция 1
BEGIN;

ALTER TABLE tds2.orders 
ADD COLUMN test varchar;

ROLLBACK;

-- транзакция 2
BEGIN;

SELECT *
FROM tds2.orders
WHERE o_orderkey = 1;

UPDATE tds2.orders
SET o_custkey = 2
WHERE o_orderkey = 1;

ROLLBACK;