-- транзакция 1
BEGIN;

SELECT *
FROM tds2.orders
WHERE o_orderkey = 1;


END;


-- транзакция 2
BEGIN;

INSERT INTO tds2.orders (
    o_orderkey,
    o_custkey,
    o_orderdate
)
VALUES (
    111111,
    1,
    date'1995-01-01'
);

COMMIT;