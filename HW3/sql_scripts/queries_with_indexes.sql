-- Query 1: Retrieve Customer Orders with Order and Customer Details

EXPLAIN ANALYZE
SELECT c.c_custkey
     , c.c_name
     , c.c_nationkey
     , c.c_mktsegment
     , c.c_address
     , c.c_phone
     , o.o_orderkey
     , o.o_orderstatus
     , o.o_totalprice
     , o.o_orderdate
     , o.o_orderpriority
  FROM tds2.customer c
  JOIN tds2.orders o
    ON o.o_custkey = c.c_custkey
 WHERE o.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31';
 
 /*
QUERY PLAN                                                                                                                                                           |
---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..903.71 rows=45544 width=118) (actual time=36.617..59.701 rows=45535 loops=1)                                   |
  ->  Hash Join  (cost=0.00..885.74 rows=11386 width=118) (actual time=35.768..49.393 rows=11730 loops=1)                                                            |
        Hash Cond: (customer.c_custkey = orders.o_custkey)                                                                                                           |
        Extra Text: (seg1)   Hash chain length 2.7 avg, 12 max, using 4370 of 262144 buckets.                                                                        |
        ->  Seq Scan on customer  (cost=0.00..431.71 rows=7500 width=80) (actual time=0.770..4.624 rows=7530 loops=1)                                                |
        ->  Hash  (cost=434.54..434.54 rows=11386 width=42) (actual time=33.707..33.707 rows=11730 loops=1)                                                          |
              ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..434.54 rows=11386 width=42) (actual time=2.005..29.966 rows=11730 loops=1)             |
                    Hash Key: orders.o_custkey                                                                                                                       |
                    ->  Sequence  (cost=0.00..433.05 rows=11386 width=42) (actual time=3.612..25.617 rows=11566 loops=1)                                             |
                          ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                              |
                                Partitions selected: 12 (out of 84)                                                                                                  |
                          ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..433.05 rows=11386 width=42) (actual time=3.505..23.751 rows=11566 loops=1)|
                                Filter: ((o_orderdate >= '1992-01-01'::date) AND (o_orderdate <= '1992-12-31'::date))                                                |
                                Partitions scanned:  Avg 12.0 (out of 84) x 4 workers.  Max 12 parts (seg0).                                                         |
Planning time: 78.034 ms                                                                                                                                             |
  (slice0)    Executor memory: 880K bytes.                                                                                                                           |
  (slice1)    Executor memory: 8482K bytes avg x 4 workers, 8498K bytes max (seg2).                                                                                  |
  (slice2)    Executor memory: 5059K bytes avg x 4 workers, 5059K bytes max (seg2).  Work_mem: 914K bytes max.                                                       |
Memory used:  128000kB                                                                                                                                               |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                                |
Execution time: 74.269 ms                                                                                                                                            |              
  */

-- Query 2: Retrieve Detailed Order Information with Line Items

EXPLAIN ANALYZE
SELECT o.o_orderkey
     , o.o_custkey
     , o.o_orderstatus
     , o.o_totalprice
     , o.o_orderdate
     , o.o_orderpriority
     , l.l_linenumber
     , l.l_partkey
     , l.l_suppkey
     , l.l_quantity
     , l.l_extendedprice
     , l.l_discount
     , l.l_tax
     , l.l_returnflag
     , l.l_linestatus
     , l.l_shipdate
  FROM tds2.orders o
  JOIN tds2.lineitem l
    ON l.l_orderkey = o.o_orderkey
 WHERE o.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31';

/*
QUERY PLAN                                                                                                                                                     |
---------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1065.22 rows=182083 width=83) (actual time=47.271..1030.979 rows=182141 loops=1)                         |
  ->  Hash Join  (cost=0.00..1014.67 rows=45521 width=83) (actual time=61.921..709.907 rows=46509 loops=1)                                                     |
        Hash Cond: (lineitem.l_orderkey = orders.o_orderkey)                                                                                                   |
        Extra Text: (seg2)   Hash chain length 1.0 avg, 3 max, using 11329 of 262144 buckets.                                                                  |
        ->  Sequence  (cost=0.00..453.27 rows=299993 width=49) (actual time=1.826..470.713 rows=301217 loops=1)                                                |
              ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=25 width=4) (never executed)                                  |
                    Partitions selected: 84 (out of 84)                                                                                                        |
              ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..453.27 rows=299993 width=49) (actual time=1.801..207.141 rows=301217 loops=1) |
                    Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                               |
        ->  Hash  (cost=433.05..433.05 rows=11386 width=42) (actual time=30.876..30.876 rows=11566 loops=1)                                                    |
              ->  Sequence  (cost=0.00..433.05 rows=11386 width=42) (actual time=0.929..22.744 rows=11566 loops=1)                                             |
                    ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                              |
                          Partitions selected: 12 (out of 84)                                                                                                  |
                    ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..433.05 rows=11386 width=42) (actual time=0.903..19.846 rows=11566 loops=1)|
                          Filter: ((o_orderdate >= '1992-01-01'::date) AND (o_orderdate <= '1992-12-31'::date))                                                |
                          Partitions scanned:  Avg 12.0 (out of 84) x 4 workers.  Max 12 parts (seg0).                                                         |
Planning time: 93.089 ms                                                                                                                                       |
  (slice0)    Executor memory: 178K bytes.                                                                                                                     |
  (slice1)    Executor memory: 123617K bytes avg x 4 workers, 123695K bytes max (seg2).  Work_mem: 901K bytes max.                                             |
Memory used:  128000kB                                                                                                                                         |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                          |
Execution time: 1048.178 ms                                                                                                                                    |
 */ 
 
-- Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship

EXPLAIN ANALYZE
SELECT s.s_suppkey
     , s.s_name
     , s.s_nationkey
     , s.s_address
     , s.s_phone
     , s.s_acctbal
     , p.p_partkey
     , p.p_name
     , p.p_brand
     , p.p_type
     , p.p_size
     , p.p_retailprice
     , ps.ps_availqty
     , ps.ps_supplycost
  FROM tds2.partsupp ps
  JOIN tds2.supplier s
    ON s.s_suppkey = ps.ps_suppkey
  JOIN tds2.part p
    ON p.p_partkey = ps.ps_partkey; 

/*
QUERY PLAN                                                                                                                            |
--------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1464.58 rows=159821 width=171) (actual time=16.735..120.913 rows=160000 loops=1)|
  ->  Hash Join  (cost=0.00..1373.17 rows=39956 width=171) (actual time=26.656..74.381 rows=40220 loops=1)                            |
        Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)                                                                         |
        Extra Text: (seg0)   Hash chain length 1.0 avg, 2 max, using 1973 of 65536 buckets.                                           |
        ->  Hash Join  (cost=0.00..904.65 rows=39956 width=93) (actual time=24.133..52.163 rows=40220 loops=1)                        |
              Hash Cond: (part.p_partkey = partsupp.ps_partkey)                                                                       |
              Extra Text: (seg0)   Hash chain length 4.1 avg, 8 max, using 9858 of 262144 buckets.                                    |
              ->  Seq Scan on part  (cost=0.00..431.79 rows=10000 width=79) (actual time=0.836..11.977 rows=10055 loops=1)            |
              ->  Hash  (cost=434.48..434.48 rows=40000 width=18) (actual time=21.720..21.720 rows=40220 loops=1)                     |
                    ->  Seq Scan on partsupp  (cost=0.00..434.48 rows=40000 width=18) (actual time=0.604..11.180 rows=40220 loops=1)  |
        ->  Hash  (cost=431.17..431.17 rows=2000 width=82) (actual time=2.377..2.377 rows=2000 loops=1)                               |
              ->  Seq Scan on supplier  (cost=0.00..431.17 rows=2000 width=82) (actual time=0.778..1.441 rows=2000 loops=1)           |
Planning time: 98.640 ms                                                                                                              |
  (slice0)    Executor memory: 1866K bytes.                                                                                           |
  (slice1)    Executor memory: 9468K bytes avg x 4 workers, 9468K bytes max (seg0).  Work_mem: 1883K bytes max.                       |
Memory used:  128000kB                                                                                                                |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                 |
Execution time: 130.774 ms                                                                                                            |
 */

 
 -- Query 4: Retrieve Comprehensive Customer Order and Line Item Details

EXPLAIN ANALYZE
SELECT c_custkey
     , c_name
     , c_address
     , c_nationkey
     , c_phone
     , o_orderkey
     , o_orderstatus
     , o_totalprice
     , o_orderdate
     , o_orderpriority
     , o_clerk
     , o_shippriority
     , o_comment
     , l_partkey
     , l_suppkey
     , l_linenumber
     , l_quantity
     , l_extendedprice
     , l_discount
     , l_tax
     , l_returnflag
     , l_linestatus
     , l_shipdate
     , l_commitdate
     , l_receiptdate
     , l_shipinstruct
     , l_shipmode
     , l_comment
  FROM tds2.customer c
  JOIN tds2.orders o
    ON o.o_custkey = c.c_custkey
  JOIN tds2.lineitem l
    ON l.l_orderkey = o.o_orderkey
 WHERE o.o_orderdate BETWEEN DATE '1992-01-01' AND DATE '1992-12-31'; 
 
 /*
QUERY PLAN                                                                                                                                                                        |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice3; segments: 4)  (cost=0.00..1799.70 rows=182083 width=289) (actual time=98.271..923.286 rows=182141 loops=1)                                            |
  ->  Hash Join  (cost=0.00..1623.68 rows=45521 width=289) (actual time=107.318..866.173 rows=46509 loops=1)                                                                      |
        Hash Cond: (lineitem.l_orderkey = orders.o_orderkey)                                                                                                                      |
        Extra Text: (seg2)   Hash chain length 1.1 avg, 4 max, using 10642 of 65536 buckets.                                                                                      |
        ->  Sequence  (cost=0.00..453.27 rows=299993 width=121) (actual time=9.375..395.530 rows=301217 loops=1)                                                                  |
              ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=25 width=4) (never executed)                                                     |
                    Partitions selected: 84 (out of 84)                                                                                                                           |
              ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..453.27 rows=299993 width=121) (actual time=9.339..283.688 rows=301217 loops=1)                   |
                    Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                                                  |
        ->  Hash  (cost=899.67..899.67 rows=11386 width=176) (actual time=67.013..67.013 rows=11566 loops=1)                                                                      |
              ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..899.67 rows=11386 width=176) (actual time=9.590..62.992 rows=11566 loops=1)                         |
                    Hash Key: orders.o_orderkey                                                                                                                                   |
                    ->  Hash Join  (cost=0.00..893.40 rows=11386 width=176) (actual time=10.783..38.055 rows=11730 loops=1)                                                       |
                          Hash Cond: (orders.o_custkey = customer.c_custkey)                                                                                                      |
                          Extra Text: (seg1)   Hash chain length 1.0 avg, 3 max, using 7309 of 131072 buckets.                                                                    |
                          ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..438.46 rows=11386 width=111) (actual time=0.031..13.930 rows=11730 loops=1)             |
                                Hash Key: orders.o_custkey                                                                                                                        |
                                ->  Sequence  (cost=0.00..434.51 rows=11386 width=111) (actual time=3.265..37.314 rows=11566 loops=1)                                             |
                                      ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                               |
                                            Partitions selected: 12 (out of 84)                                                                                                   |
                                      ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..434.51 rows=11386 width=111) (actual time=3.238..35.391 rows=11566 loops=1)|
                                            Filter: ((o_orderdate >= '1992-01-01'::date) AND (o_orderdate <= '1992-12-31'::date))                                                 |
                                            Partitions scanned:  Avg 12.0 (out of 84) x 4 workers.  Max 12 parts (seg0).                                                          |
                          ->  Hash  (cost=431.71..431.71 rows=7500 width=69) (actual time=9.153..9.153 rows=7530 loops=1)                                                         |
                                ->  Seq Scan on customer  (cost=0.00..431.71 rows=7500 width=69) (actual time=1.293..4.692 rows=7530 loops=1)                                     |
Planning time: 136.910 ms                                                                                                                                                         |
  (slice0)    Executor memory: 807K bytes.                                                                                                                                        |
  (slice1)    Executor memory: 12506K bytes avg x 4 workers, 12526K bytes max (seg2).                                                                                             |
  (slice2)    Executor memory: 3907K bytes avg x 4 workers, 3907K bytes max (seg1).  Work_mem: 726K bytes max.                                                                    |
  (slice3)    Executor memory: 167207K bytes avg x 4 workers, 167281K bytes max (seg2).  Work_mem: 2498K bytes max.                                                               |
Memory used:  128000kB                                                                                                                                                            |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                                             |
Execution time: 948.886 ms                                                                                                                                                        |
  */
 
 
-- Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details 
 
EXPLAIN ANALYZE
SELECT s.s_suppkey
     , s.s_name
     , s.s_address
     , s.s_nationkey
     , s.s_phone
     , s.s_acctbal
     , p.p_partkey
     , p.p_name
     , p.p_brand
     , p.p_type
     , p.p_size
     , p.p_retailprice
FROM tds2.supplier s
JOIN tds2.partsupp ps
  ON ps.ps_suppkey = s.s_suppkey
JOIN tds2.part p
  ON p.p_partkey = ps.ps_partkey
WHERE s.s_suppkey = 1000;

/*
QUERY PLAN                                                                                                                                    |
----------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1168.86 rows=78 width=161) (actual time=16.560..30.296 rows=80 loops=1)                 |
  ->  Hash Join  (cost=0.00..1168.82 rows=20 width=161) (actual time=3.239..29.717 rows=27 loops=1)                                           |
        Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)                                                                                 |
        Extra Text: (seg3)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.                                                      |
        ->  Nested Loop  (cost=0.00..780.83 rows=20 width=83) (actual time=1.664..28.027 rows=27 loops=1)                                     |
              Join Filter: true                                                                                                               |
              ->  Bitmap Heap Scan on partsupp  (cost=0.00..388.09 rows=20 width=8) (actual time=0.623..1.530 rows=27 loops=1)                |
                    Recheck Cond: (ps_suppkey = 1000)                                                                                         |
                    ->  Bitmap Index Scan on idx_partsupp_suppkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.024..0.024 rows=27 loops=1)|
                          Index Cond: (ps_suppkey = 1000)                                                                                     |
              ->  Bitmap Heap Scan on part  (cost=0.00..392.73 rows=1 width=79) (actual time=0.038..0.979 rows=1 loops=27)                    |
                    Recheck Cond: (p_partkey = partsupp.ps_partkey)                                                                           |
                    ->  Bitmap Index Scan on idx_part_partkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.000..0.006 rows=1 loops=27)    |
                          Index Cond: (p_partkey = partsupp.ps_partkey)                                                                       |
        ->  Hash  (cost=387.97..387.97 rows=1 width=82) (actual time=1.361..1.361 rows=1 loops=1)                                             |
              ->  Bitmap Heap Scan on supplier  (cost=0.00..387.97 rows=1 width=82) (actual time=1.304..1.357 rows=1 loops=1)                 |
                    Recheck Cond: (s_suppkey = 1000)                                                                                          |
                    ->  Bitmap Index Scan on idx_supplier_suppkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.011..0.011 rows=1 loops=1) |
                          Index Cond: (s_suppkey = 1000)                                                                                      |
Planning time: 100.077 ms                                                                                                                     |
  (slice0)    Executor memory: 234K bytes.                                                                                                    |
  (slice1)    Executor memory: 6429K bytes avg x 4 workers, 7423K bytes max (seg3).  Work_mem: 17K bytes max.                                 |
  (slice2)                                                                                                                                    |
Memory used:  128000kB                                                                                                                        |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                         |
Execution time: 30.891 ms                                                                                                                     |
 */
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 