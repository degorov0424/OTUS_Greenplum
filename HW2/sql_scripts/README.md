# HW 2

## 1.Скопировал датасеты с хоста в заранее созданную директорию в docker контейнере

```bash
 docker cp /home/degorov/customer.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/datasets/customer.tbl
 docker cp /home/degorov/nation.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/nation.tbl
 docker cp /home/degorov/partsupp.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/partsupp.tbl
 docker cp /home/degorov/region.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/region.tbl
 docker cp /home/degorov/lineitem.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/lineitem.tbl
 docker cp /home/degorov/orders.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/orders.tbl
 docker cp /home/degorov/part.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/part.tbl
 docker cp /home/degorov/supplier.tbl vldbuk/gpdb_demo_repo:gpdb_demo:/home/gpadmin/supplier.tbl
```
---

## 2. Обрезал pipe в конце каждой строки во всех файлах

```bash
sed 's/.$//' customer.tbl > custumer.tbl_
sed 's/.$//' lineitem.tbl > lineitem.tbl_
sed 's/.$//' nation.tbl > nation.tbl_
sed 's/.$//' orders.tbl > orders.tbl_
sed 's/.$//' partsupp.tbl > partsupp.tbl_
sed 's/.$//' part.tbl > part.tbl_
sed 's/.$//' supplier.tbl > supplier.tbl_
sed 's/.$//' region.tbl > region.tbl_
```

---

## 3. Создал таблицы и заполнил данными

Создал схему `tds1` и в ней создал таблицы скриптом `tds1_tables.sql`.
В скрипт так же добавил команды `COPY`, для вставки данных из csv.

```sql
copy tds1.customer from '/home/gpadmin/datasets/customer.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.lineitem from '/home/gpadmin/datasets/lineitem.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.nation from '/home/gpadmin/datasets/nation.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.orders from '/home/gpadmin/datasets/orders.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.part from '/home/gpadmin/datasets/part.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.partsupp from '/home/gpadmin/datasets/partsupp.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.region from '/home/gpadmin/datasets/region.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds1.supplier from '/home/gpadmin/datasets/supplier.tbl_' WITH (FORMAT csv, DELIMITER '|');
```

Т.к далее по заданию, необходимо сравнить результат с партициями и без, создал схему `tds2` и такие же таблицы, но добавил партицирование для `tds2.lineitem` и `tds2.orders`(скрипт `tds2_tables.sql`). 

---

## 4. Составил запрос и замерил время выполнения

Время выполнения замерял с помощью `EXPLAIN ANALYZE`. 
Запросы и время выполнения в скрипте `HW2_SQL_script.sql`.
