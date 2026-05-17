---------------------------------
-- проверка неповторяемого чтения
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181585.13
Теперь запускаем обновление этой записи из session_2.sql в другой сессии 
 */

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181685.13
Значение изменилось, т.к READ COMMITTED допускает non-repeatable read
 */
END;
-- завершаем транзакцию


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181685.13
Теперь запускаем обновление этой записи из session_2.sql в другой сессии 
 */

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181685.13
Значение не изменилось, т.к REPEATABLE READ защищает от non-repeatable read
 */
END;
-- завершаем транзакцию




-------------------------------------------
-- обновление одной строки в разных сессиях
-------------------------------------------

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181885.13
запускаем обновление записи из session_2.sql в другой сессии
 */


UPDATE tds2.orders
SET o_totalprice = o_totalprice + 100
WHERE o_orderkey = 1;
-- возникает ошибка SQL Error [0A000]: ERROR: updates on append-only tables are not supported in serializable transactions
ROLLBACK;
-- откат транзакции


SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 181985.13
запускаем обновление записи из session_2.sql в другой сессии
 */


UPDATE tds2.orders
SET o_totalprice = o_totalprice + 100
WHERE o_orderkey = 1;
-- обновление завершилось без ошибок

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 182185.13
Применились оба обновления
 */
END;

 /*
  так же был проведен аналогичный тест, но в сессии 2 выполнялся update без commit, для проверки блокировки. 
  В результате, обновление в сессии 1 зависало. 
  После выполнения commit в сессии 2, обновление в сессии 1 завершалось либо успешно (READ COMMITTED), либо ошибкой (REPEATABLE READ) 
  */



---------------------------------
-- грязное чтение
---------------------------------


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 182385.13
Теперь запускаем обновление этой записи из session_2.sql в другой сессии, но не выполняем commit 
 */

SELECT o_orderkey, o_totalprice
FROM tds2.orders
WHERE o_orderkey = 1;
/*
Результат: o_orderkey = 1; o_totalprice = 182385.13
Значение не изменилось, т.к READ UNCOMMITTED в Greenplum работает так же, как и READ COMMITTED и не допускает dirty read
 */
END;
-- завершаем транзакцию



---------------------------------
-- фантомное чтение
---------------------------------

-- предварительно создаем таблицу

DROP TABLE IF EXISTS tds2.test;

CREATE TABLE tds2.test (
    id int,
    amount numeric(12,2)
)
DISTRIBUTED BY (id);

INSERT INTO tds2.test VALUES
(1, 50000),
(2, 120000),
(3, 180000);

SELECT *
FROM tds2.test
ORDER BY id;

-- проверка

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;

SELECT count(*) AS cnt
FROM tds2.test
WHERE amount > 100000;

/*
Результат: cnt = 2
Запускаем вставку новой записи из session_2.sql (Скрипт 2) в другой сессии 
 */

SELECT count(*) AS cnt
FROM tds2.test
WHERE amount > 100000;

/*
Результат: cnt = 3
Появилась новая строка, READ COMMITTED допускает такое поведение
 */
END;

-- удаляем добавленную запись
DELETE FROM tds2.test WHERE id = 4;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;

SELECT count(*) AS cnt
FROM tds2.test
WHERE amount > 100000;

/*
Результат: cnt = 2
Запускаем вставку новой записи из session_2.sql (Скрипт 2) в другой сессии 
 */

SELECT count(*) AS cnt
FROM tds2.test
WHERE amount > 100000;

/*
Результат: cnt = 2
Использование REPEATABLE READ исключает фантомное чтение, т.к продолжается работа на снимке данных, полученном в начале транзакции.
 */
END;


