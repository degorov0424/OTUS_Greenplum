-- Скрипт 1
BEGIN;

UPDATE tds2.orders
SET o_totalprice = o_totalprice + 100
WHERE o_orderkey = 1;

COMMIT;
END;


-- Скрипт 2

BEGIN;

INSERT INTO tds2.test (
    id,
    amount
)
VALUES (
    4,
    150000
);

COMMIT;


