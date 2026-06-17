-- Query 1: Retrieve Customer Orders with Order and Customer Details

EXPLAIN ANALYZE
SELECT c.c_name
     , c.c_nationkey
     , c.c_mktsegment
     , c.c_address
     , c.c_phone
     , o.o_orderstatus
     , o.o_totalprice
     , o.o_orderdate
     , o.o_orderpriority
  FROM tds2.customer c
  JOIN tds2.orders o
    ON o.o_custkey = c.c_custkey;
 
 /*
  
QUERY PLAN                                                                                                                                                      |
----------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..1047.41 rows=300001 width=106) (actual time=11.425..198.236 rows=300001 loops=1)                          |
  ->  Hash Join  (cost=0.00..941.04 rows=75001 width=106) (actual time=10.480..108.059 rows=76457 loops=1)                                                      |
        Hash Cond: (orders.o_custkey = customer.c_custkey)                                                                                                      |
        Extra Text: (seg1)   Hash chain length 1.0 avg, 3 max, using 7309 of 131072 buckets.                                                                    |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..451.43 rows=75001 width=34) (actual time=0.024..31.866 rows=76457 loops=1)              |
              Hash Key: orders.o_custkey                                                                                                                        |
              ->  Sequence  (cost=0.00..436.16 rows=75001 width=34) (actual time=2.585..127.401 rows=75163 loops=1)                                             |
                    ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                               |
                          Partitions selected: 84 (out of 84)                                                                                                   |
                    ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..436.16 rows=75001 width=34) (actual time=2.534..117.768 rows=75163 loops=1)|
                          Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                          |
        ->  Hash  (cost=431.71..431.71 rows=7500 width=80) (actual time=9.270..9.270 rows=7530 loops=1)                                                         |
              ->  Seq Scan on customer  (cost=0.00..431.71 rows=7500 width=80) (actual time=1.229..4.464 rows=7530 loops=1)                                     |
Planning time: 20.045 ms                                                                                                                                        |
  (slice0)    Executor memory: 752K bytes.                                                                                                                      |
  (slice1)    Executor memory: 47597K bytes avg x 4 workers, 47610K bytes max (seg2).                                                                           |
  (slice2)    Executor memory: 4035K bytes avg x 4 workers, 4035K bytes max (seg1).  Work_mem: 821K bytes max.                                                  |
Memory used:  128000kB                                                                                                                                          |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                           |
Execution time: 234.556 ms                                                                                                                                      | 
   
  */

-- Query 2: Retrieve Detailed Order Information with Line Items

EXPLAIN ANALYZE
SELECT o.o_orderstatus
     , o.o_totalprice
     , o.o_orderdate
     , o.o_orderpriority
     , l.l_linenumber
     , l.l_quantity
     , l.l_extendedprice
     , l.l_discount
     , l.l_tax
     , l.l_returnflag
     , l.l_linestatus
     , l.l_shipdate
  FROM tds2.orders o
  JOIN tds2.lineitem l
    ON l.l_orderkey = o.o_orderkey;

/*
QUERY PLAN                                                                                                                                                     |
---------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1383.46 rows=1199414 width=63) (actual time=117.507..805.830 rows=1199976 loops=1)                       |
  ->  Hash Join  (cost=0.00..1130.70 rows=299854 width=63) (actual time=125.405..520.540 rows=301217 loops=1)                                                  |
        Hash Cond: (lineitem.l_orderkey = orders.o_orderkey)                                                                                                   |
        Extra Text: (seg2)   Hash chain length 1.1 avg, 5 max, using 65433 of 262144 buckets.                                                                  |
        ->  Sequence  (cost=0.00..453.27 rows=299993 width=41) (actual time=1.404..241.863 rows=301217 loops=1)                                                |
              ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=25 width=4) (never executed)                                  |
                    Partitions selected: 84 (out of 84)                                                                                                        |
              ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..453.27 rows=299993 width=41) (actual time=1.377..214.763 rows=301217 loops=1) |
                    Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                               |
        ->  Hash  (cost=436.16..436.16 rows=75001 width=38) (actual time=123.228..123.228 rows=75163 loops=1)                                                  |
              ->  Sequence  (cost=0.00..436.16 rows=75001 width=38) (actual time=1.185..88.628 rows=75163 loops=1)                                             |
                    ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                              |
                          Partitions selected: 84 (out of 84)                                                                                                  |
                    ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..436.16 rows=75001 width=38) (actual time=1.158..81.609 rows=75163 loops=1)|
                          Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                         |
Planning time: 68.321 ms                                                                                                                                       |
  (slice0)    Executor memory: 169K bytes.                                                                                                                     |
  (slice1)    Executor memory: 155553K bytes avg x 4 workers, 155626K bytes max (seg2).  Work_mem: 5285K bytes max.                                            |
Memory used:  128000kB                                                                                                                                         |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                          |
Execution time: 884.077 ms                                                                                                                                     |
 */ 
 
-- Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship

EXPLAIN ANALYZE
SELECT s.s_name
     , s.s_address
     , s.s_phone
     , s.s_acctbal
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
 QUERY PLAN                                                                                                                           |
-------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1455.78 rows=160000 width=159) (actual time=17.474..99.709 rows=160000 loops=1)|
  ->  Hash Join  (cost=0.00..1370.69 rows=40000 width=159) (actual time=24.464..69.679 rows=40220 loops=1)                           |
        Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)                                                                        |
        Extra Text: (seg0)   Hash chain length 1.0 avg, 2 max, using 1973 of 65536 buckets.                                          |
        ->  Hash Join  (cost=0.00..904.10 rows=40000 width=89) (actual time=22.307..46.024 rows=40220 loops=1)                       |
              Hash Cond: (part.p_partkey = partsupp.ps_partkey)                                                                      |
              Extra Text: (seg0)   Hash chain length 4.1 avg, 8 max, using 9858 of 262144 buckets.                                   |
              ->  Seq Scan on part  (cost=0.00..431.79 rows=10000 width=79) (actual time=0.915..6.404 rows=10055 loops=1)            |
              ->  Hash  (cost=434.48..434.48 rows=40000 width=18) (actual time=20.584..20.584 rows=40220 loops=1)                    |
                    ->  Seq Scan on partsupp  (cost=0.00..434.48 rows=40000 width=18) (actual time=0.864..10.587 rows=40220 loops=1) |
        ->  Hash  (cost=431.17..431.17 rows=2000 width=78) (actual time=2.022..2.022 rows=2000 loops=1)                              |
              ->  Seq Scan on supplier  (cost=0.00..431.17 rows=2000 width=78) (actual time=0.605..1.161 rows=2000 loops=1)          |
Planning time: 87.413 ms                                                                                                             |
  (slice0)    Executor memory: 1770K bytes.                                                                                          |
  (slice1)    Executor memory: 9356K bytes avg x 4 workers, 9356K bytes max (seg1).  Work_mem: 1883K bytes max.                      |
Memory used:  128000kB                                                                                                               |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                |
Execution time: 112.553 ms                                                                                                           |
 */

 
 -- Query 4: Retrieve Comprehensive Customer Order and Line Item Details

EXPLAIN ANALYZE
SELECT c_name
     , c_address
     , c_phone
     , o_orderstatus
     , o_totalprice
     , o_orderdate
     , o_orderpriority
     , o_clerk
     , o_shippriority
     , o_comment
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
    ON l.l_orderkey = o.o_orderkey; 
 
 /*
QUERY PLAN                                                                                                                                                            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..3286.73 rows=1199414 width=265) (actual time=199.992..1406.803 rows=1199976 loops=1)                            |
  ->  Hash Join  (cost=0.00..2223.54 rows=299854 width=265) (actual time=199.348..818.004 rows=301217 loops=1)                                                        |
        Hash Cond: (lineitem.l_orderkey = orders.o_orderkey)                                                                                                          |
        Extra Text: (seg2)   Hash chain length 1.7 avg, 7 max, using 44722 of 65536 buckets.                                                                          |
        ->  Sequence  (cost=0.00..453.27 rows=299993 width=113) (actual time=1.119..335.756 rows=301217 loops=1)                                                      |
              ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=25 width=4) (never executed)                                         |
                    Partitions selected: 84 (out of 84)                                                                                                               |
              ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..453.27 rows=299993 width=113) (actual time=1.085..302.893 rows=301217 loops=1)       |
                    Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                                      |
        ->  Hash  (cost=1028.89..1028.89 rows=75001 width=168) (actual time=198.004..198.004 rows=75163 loops=1)                                                      |
              ->  Hash Join  (cost=0.00..1028.89 rows=75001 width=168) (actual time=27.666..155.755 rows=75163 loops=1)                                               |
                    Hash Cond: (orders.o_custkey = customer.c_custkey)                                                                                                |
                    Extra Text: (seg2)   Hash chain length 1.1 avg, 4 max, using 26786 of 131072 buckets.                                                             |
                    ->  Sequence  (cost=0.00..436.16 rows=75001 width=111) (actual time=0.549..86.940 rows=75163 loops=1)                                             |
                          ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=25 width=4) (never executed)                               |
                                Partitions selected: 84 (out of 84)                                                                                                   |
                          ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..436.16 rows=75001 width=111) (actual time=0.528..61.573 rows=75163 loops=1)|
                                Partitions scanned:  Avg 84.0 (out of 84) x 4 workers.  Max 84 parts (seg0).                                                          |
                    ->  Hash  (cost=459.46..459.46 rows=30000 width=65) (actual time=26.087..26.087 rows=30000 loops=1)                                               |
                          ->  Broadcast Motion 4:4  (slice1; segments: 4)  (cost=0.00..459.46 rows=30000 width=65) (actual time=2.430..15.616 rows=30000 loops=1)     |
                                ->  Seq Scan on customer  (cost=0.00..431.71 rows=7500 width=65) (actual time=1.773..5.596 rows=7530 loops=1)                         |
Planning time: 95.097 ms                                                                                                                                              |
  (slice0)    Executor memory: 712K bytes.                                                                                                                            |
  (slice1)    Executor memory: 617K bytes avg x 4 workers, 617K bytes max (seg1).                                                                                     |
  (slice2)    Executor memory: 266089K bytes avg x 4 workers, 266176K bytes max (seg2).  Work_mem: 15650K bytes max.                                                  |
Memory used:  128000kB                                                                                                                                                |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                                 |
Execution time: 1495.968 ms                                                                                                                                           |
  */
 
 
-- Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details 
 
EXPLAIN ANALYZE
SELECT s.s_name
     , s.s_address
     , s.s_phone
     , s.s_acctbal
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
WHERE s.s_name = 'Supplier#000001000';

/*
QUERY PLAN                                                                                                                        |
----------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1309.03 rows=80 width=149) (actual time=22.541..23.096 rows=80 loops=1)     |
  ->  Hash Join  (cost=0.00..1308.99 rows=20 width=149) (actual time=15.358..21.824 rows=27 loops=1)                              |
        Hash Cond: (part.p_partkey = partsupp.ps_partkey)                                                                         |
        Extra Text: (seg3)   Hash chain length 1.0 avg, 1 max, using 27 of 65536 buckets.                                         |
        ->  Seq Scan on part  (cost=0.00..431.79 rows=10000 width=79) (actual time=0.875..5.597 rows=10055 loops=1)               |
        ->  Hash  (cost=873.47..873.47 rows=20 width=78) (actual time=14.087..14.087 rows=27 loops=1)                             |
              ->  Hash Join  (cost=0.00..873.47 rows=20 width=78) (actual time=1.972..14.069 rows=27 loops=1)                     |
                    Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)                                                         |
                    Extra Text: (seg3)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.                              |
                    ->  Seq Scan on partsupp  (cost=0.00..434.48 rows=40000 width=8) (actual time=0.293..7.363 rows=40220 loops=1)|
                    ->  Hash  (cost=431.24..431.24 rows=1 width=78) (actual time=1.245..1.245 rows=1 loops=1)                     |
                          ->  Seq Scan on supplier  (cost=0.00..431.24 rows=1 width=78) (actual time=0.815..1.239 rows=1 loops=1) |
                                Filter: (s_name = 'Supplier#000001000'::bpchar)                                                   |
Planning time: 98.322 ms                                                                                                          |
  (slice0)    Executor memory: 1562K bytes.                                                                                       |
  (slice1)    Executor memory: 2876K bytes avg x 4 workers, 2876K bytes max (seg1).  Work_mem: 3K bytes max.                      |
Memory used:  128000kB                                                                                                            |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                             |
Execution time: 23.974 ms                                                                                                         |
 */
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 