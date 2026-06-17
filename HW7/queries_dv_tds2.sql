-- Query 1: Retrieve Customer Orders with Order and Customer Details

EXPLAIN ANALYZE 
 SELECT c.c_name
      , c.c_mktsegment
      , c.c_address
      , c.c_phone
      , o.o_orderstatus
      , o.o_totalprice
      , o.o_orderdate
      , o.o_orderpriority
   FROM dv_tds.link_customer_order co
   JOIN dv_tds.sat_customer c
     ON co.customer_hk = c.customer_hk
   JOIN dv_tds.sat_order o
     ON co.order_hk = o.order_hk;
/*
QUERY PLAN                                                                                                                                           |
-----------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..1653.37 rows=300001 width=102) (actual time=57.988..301.022 rows=300003 loops=1)               |
  ->  Hash Join  (cost=0.00..1551.01 rows=75001 width=102) (actual time=56.927..208.852 rows=76313 loops=1)                                          |
        Hash Cond: (link_customer_order.customer_hk = sat_customer.customer_hk)                                                                      |
        Extra Text: (seg1)   Hash chain length 1.1 avg, 3 max, using 7125 of 65536 buckets.                                                          |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..1056.15 rows=75001 width=63) (actual time=40.266..116.664 rows=76313 loops=1)|
              Hash Key: link_customer_order.customer_hk                                                                                              |
              ->  Hash Join  (cost=0.00..1041.37 rows=75001 width=63) (actual time=71.845..211.276 rows=75447 loops=1)                               |
                    Hash Cond: (link_customer_order.order_hk = sat_order.order_hk)                                                                   |
                    Extra Text: (seg2)   Hash chain length 1.3 avg, 7 max, using 57294 of 131072 buckets.                                            |
                    ->  Seq Scan on link_customer_order  (cost=0.00..436.49 rows=75001 width=66) (actual time=0.584..30.020 rows=75445 loops=1)      |
                    ->  Hash  (cost=439.54..439.54 rows=75001 width=63) (actual time=69.055..69.055 rows=75445 loops=1)                              |
                          ->  Seq Scan on sat_order  (cost=0.00..439.54 rows=75001 width=63) (actual time=2.225..28.687 rows=75445 loops=1)          |
        ->  Hash  (cost=432.08..432.08 rows=7500 width=105) (actual time=15.613..15.613 rows=7543 loops=1)                                           |
              ->  Seq Scan on sat_customer  (cost=0.00..432.08 rows=7500 width=105) (actual time=1.459..7.066 rows=7543 loops=1)                     |
Planning time: 27.943 ms                                                                                                                             |
  (slice0)    Executor memory: 1480K bytes.                                                                                                          |
  (slice1)    Executor memory: 18508K bytes avg x 4 workers, 18508K bytes max (seg0).  Work_mem: 7073K bytes max.                                    |
  (slice2)    Executor memory: 3336K bytes avg x 4 workers, 3336K bytes max (seg0).  Work_mem: 1022K bytes max.                                      |
Memory used:  128000kB                                                                                                                               |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                |
Execution time: 333.286 ms                                                                                                                           |
*/

-- Query 2: Retrieve Detailed Order Information with Line Items

EXPLAIN ANALYZE
SELECT so.o_orderstatus
     , so.o_totalprice
     , so.o_orderdate
     , so.o_orderpriority
     , lol.line_number
     , sol.l_quantity
     , sol.l_extendedprice
     , sol.l_discount
     , sol.l_tax
     , sol.l_returnflag
     , sol.l_linestatus
     , sol.l_shipdate
  FROM dv_tds.link_order_line lol
  JOIN dv_tds.sat_order_line sol
    ON lol.order_line_hk = sol.order_line_hk
  JOIN dv_tds.sat_order so 
    ON so.order_hk = lol.order_hk; 

/*
 
 QUERY PLAN                                                                                                                                              |
--------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..2593.56 rows=1199969 width=63) (actual time=414.185..1443.463 rows=1199976 loops=1)               |
  ->  Hash Join  (cost=0.00..2340.68 rows=299993 width=63) (actual time=413.433..1186.355 rows=301676 loops=1)                                          |
        Hash Cond: (link_order_line.order_hk = sat_order.order_hk)                                                                                      |
        Extra Text: (seg2)   Hash chain length 1.3 avg, 7 max, using 57294 of 131072 buckets.                                                           |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..1647.25 rows=299993 width=66) (actual time=325.715..727.916 rows=301669 loops=1)|
              Hash Key: link_order_line.order_hk                                                                                                        |
              ->  Hash Join  (cost=0.00..1585.28 rows=299993 width=66) (actual time=469.797..1190.542 rows=300473 loops=1)                              |
                    Hash Cond: (link_order_line.order_line_hk = sat_order_line.order_line_hk)                                                           |
                    Extra Text: (seg3)   Hash chain length 2.6 avg, 12 max, using 117745 of 131072 buckets.                                             |
                    ->  Seq Scan on link_order_line  (cost=0.00..459.38 rows=299993 width=70) (actual time=0.658..124.169 rows=300473 loops=1)          |
                    ->  Hash  (cost=465.81..465.81 rows=299993 width=62) (actual time=467.815..467.815 rows=300473 loops=1)                             |
                          ->  Seq Scan on sat_order_line  (cost=0.00..465.81 rows=299993 width=62) (actual time=1.750..309.642 rows=300473 loops=1)     |
        ->  Hash  (cost=439.54..439.54 rows=75001 width=63) (actual time=86.657..86.657 rows=75445 loops=1)                                             |
              ->  Seq Scan on sat_order  (cost=0.00..439.54 rows=75001 width=63) (actual time=1.097..35.434 rows=75445 loops=1)                         |
Planning time: 30.222 ms                                                                                                                                |
  (slice0)    Executor memory: 1866K bytes.                                                                                                             |
  (slice1)    Executor memory: 51790K bytes avg x 4 workers, 51790K bytes max (seg0).  Work_mem: 30411K bytes max.                                      |
  (slice2)    Executor memory: 18250K bytes avg x 4 workers, 18250K bytes max (seg0).  Work_mem: 7073K bytes max.                                       |
Memory used:  128000kB                                                                                                                                  |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                   |
Execution time: 1532.740 ms                                                                                                                             |
 
 */

-- Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship

EXPLAIN ANALYZE
SELECT ss.s_name
     , ss.s_address
     , ss.s_phone
     , ss.s_acctbal
     , sp.p_name
     , sp.p_brand
     , sp.p_type
     , sp.p_size
     , sp.p_retailprice
     , sps.ps_availqty
     , sps.ps_supplycost
  FROM dv_tds.link_part_supplier lps
  JOIN dv_tds.sat_supplier ss 
    ON ss.supplier_hk = lps.supplier_hk 
  JOIN dv_tds.sat_part sp
    ON lps.part_hk = sp.part_hk 
  JOIN dv_tds.sat_part_supplier sps
    ON sps.part_supplier_hk = lps.part_supplier_hk; 

/*
 
QUERY PLAN                                                                                                                                           |
-----------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..2007.99 rows=159937 width=159) (actual time=30.348..195.688 rows=160000 loops=1)               |
  ->  Hash Join  (cost=0.00..1922.93 rows=39985 width=159) (actual time=29.480..131.423 rows=40204 loops=1)                                          |
        Hash Cond: (link_part_supplier.part_hk = sat_part.part_hk)                                                                                   |
        Extra Text: (seg1)   Hash chain length 1.1 avg, 3 max, using 9295 of 65536 buckets.                                                          |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..1431.07 rows=40000 width=117) (actual time=15.404..76.012 rows=40204 loops=1)|
              Hash Key: link_part_supplier.part_hk                                                                                                   |
              ->  Hash Join  (cost=0.00..1416.42 rows=40000 width=117) (actual time=38.982..148.104 rows=40123 loops=1)                              |
                    Hash Cond: (link_part_supplier.part_supplier_hk = sat_part_supplier.part_supplier_hk)                                            |
                    Extra Text: (seg0)   Hash chain length 1.3 avg, 6 max, using 30000 of 65536 buckets.                                             |
                    ->  Hash Join  (cost=0.00..907.03 rows=40000 width=140) (actual time=4.385..58.148 rows=40123 loops=1)                           |
                          Hash Cond: (link_part_supplier.supplier_hk = sat_supplier.supplier_hk)                                                     |
                          Extra Text: (seg0)   Hash chain length 1.0 avg, 3 max, using 1928 of 32768 buckets.                                        |
                          ->  Seq Scan on link_part_supplier  (cost=0.00..433.97 rows=40000 width=99) (actual time=0.921..21.769 rows=40123 loops=1) |
                          ->  Hash  (cost=431.27..431.27 rows=2000 width=107) (actual time=3.152..3.152 rows=2000 loops=1)                           |
                                ->  Seq Scan on sat_supplier  (cost=0.00..431.27 rows=2000 width=107) (actual time=0.882..1.629 rows=2000 loops=1)   |
                    ->  Hash  (cost=436.41..436.41 rows=40000 width=43) (actual time=33.964..33.964 rows=40123 loops=1)                              |
                          ->  Seq Scan on sat_part_supplier  (cost=0.00..436.41 rows=40000 width=43) (actual time=0.930..13.837 rows=40123 loops=1)  |
        ->  Hash  (cost=432.28..432.28 rows=10000 width=108) (actual time=13.869..13.869 rows=10051 loops=1)                                         |
              ->  Seq Scan on sat_part  (cost=0.00..432.28 rows=10000 width=108) (actual time=1.092..7.497 rows=10051 loops=1)                       |
Planning time: 62.730 ms                                                                                                                             |
  (slice0)    Executor memory: 1976K bytes.                                                                                                          |
  (slice1)    Executor memory: 11081K bytes avg x 4 workers, 11081K bytes max (seg0).  Work_mem: 2822K bytes max.                                    |
  (slice2)    Executor memory: 5576K bytes avg x 4 workers, 5576K bytes max (seg0).  Work_mem: 1412K bytes max.                                      |
Memory used:  128000kB                                                                                                                               |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                |
Execution time: 208.633 ms                                                                                                                           |
 
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
     , line_number
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
  FROM dv_tds.link_customer_order lco
  JOIN dv_tds.link_order_line lol 
    ON lco.order_hk = lol.order_hk 
  JOIN dv_tds.sat_order_line sol 
    ON sol.order_line_hk = lol.order_line_hk 
  JOIN dv_tds.sat_order so 
    ON so.order_hk = lco.order_hk 
  JOIN dv_tds.sat_customer sc 
    ON sc.customer_hk = lco.customer_hk; 
/*
 
 QUERY PLAN                                                                                                                                                       |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice3; segments: 4)  (cost=0.00..5453.33 rows=1199969 width=265) (actual time=632.134..2423.765 rows=1199990 loops=1)                       |
  ->  Hash Join  (cost=0.00..4389.65 rows=299993 width=265) (actual time=630.383..1672.762 rows=301690 loops=1)                                                  |
        Hash Cond: ((link_order_line.order_hk = link_customer_order.order_hk) AND (link_order_line.order_hk = sat_order.order_hk))                               |
        Extra Text: (seg2)   Hash chain length 2.6 avg, 10 max, using 29453 of 32768 buckets.                                                                    |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..1896.80 rows=299993 width=138) (actual time=0.017..469.976 rows=301669 loops=1)          |
              Hash Key: link_order_line.order_hk                                                                                                                 |
              ->  Hash Join  (cost=0.00..1767.23 rows=299993 width=138) (actual time=502.273..1282.708 rows=300473 loops=1)                                      |
                    Hash Cond: (sat_order_line.order_line_hk = link_order_line.order_line_hk)                                                                    |
                    Extra Text: (seg3)   Hash chain length 4.6 avg, 16 max, using 64870 of 65536 buckets.                                                        |
                    ->  Seq Scan on sat_order_line  (cost=0.00..465.81 rows=299993 width=134) (actual time=3.760..276.580 rows=300473 loops=1)                   |
                    ->  Hash  (cost=459.38..459.38 rows=299993 width=70) (actual time=497.670..497.670 rows=300473 loops=1)                                      |
                          ->  Seq Scan on link_order_line  (cost=0.00..459.38 rows=299993 width=70) (actual time=1.034..317.527 rows=300473 loops=1)             |
        ->  Hash  (cost=1715.17..1715.17 rows=75001 width=226) (actual time=629.942..629.942 rows=75447 loops=1)                                                 |
              ->  Hash Join  (cost=0.00..1715.17 rows=75001 width=226) (actual time=140.211..518.645 rows=75447 loops=1)                                         |
                    Hash Cond: (link_customer_order.customer_hk = sat_customer.customer_hk)                                                                      |
                    Extra Text: (seg2)   Hash chain length 1.5 avg, 6 max, using 19563 of 32768 buckets.                                                         |
                    ->  Hash Join  (cost=0.00..1094.55 rows=75001 width=198) (actual time=75.818..382.352 rows=75447 loops=1)                                    |
                          Hash Cond: (sat_order.order_hk = link_customer_order.order_hk)                                                                         |
                          Extra Text: (seg2)   Hash chain length 1.7 avg, 8 max, using 44843 of 65536 buckets.                                                   |
                          ->  Seq Scan on sat_order  (cost=0.00..439.54 rows=75001 width=132) (actual time=1.495..244.240 rows=75445 loops=1)                    |
                          ->  Hash  (cost=436.49..436.49 rows=75001 width=66) (actual time=73.527..73.527 rows=75445 loops=1)                                    |
                                ->  Seq Scan on link_customer_order  (cost=0.00..436.49 rows=75001 width=66) (actual time=0.476..29.404 rows=75445 loops=1)      |
                    ->  Hash  (cost=472.20..472.20 rows=30000 width=94) (actual time=60.793..60.793 rows=30000 loops=1)                                          |
                          ->  Broadcast Motion 4:4  (slice2; segments: 4)  (cost=0.00..472.20 rows=30000 width=94) (actual time=2.145..41.962 rows=30000 loops=1)|
                                ->  Seq Scan on sat_customer  (cost=0.00..432.08 rows=7500 width=94) (actual time=0.856..4.775 rows=7543 loops=1)                |
Planning time: 130.585 ms                                                                                                                                        |
  (slice0)    Executor memory: 3511K bytes.                                                                                                                      |
  (slice1)    Executor memory: 51921K bytes avg x 4 workers, 51921K bytes max (seg0).  Work_mem: 28170K bytes max.                                               |
  (slice2)    Executor memory: 624K bytes avg x 4 workers, 624K bytes max (seg0).                                                                                |
  (slice3)    Executor memory: 62040K bytes avg x 4 workers, 68184K bytes max (seg2).  Work_mem: 19970K bytes max.                                               |
Memory used:  128000kB                                                                                                                                           |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                                            |
Execution time: 2531.562 ms                                                                                                                                      |
 
 */


-- Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details 
 
EXPLAIN ANALYZE
SELECT ss.s_name
     , ss.s_address
     , ss.s_phone
     , ss.s_acctbal
     , sp.p_name
     , sp.p_brand
     , sp.p_type
     , sp.p_size
     , sp.p_retailprice
  FROM dv_tds.link_part_supplier lps
  JOIN dv_tds.sat_supplier ss 
    ON ss.supplier_hk = lps.supplier_hk 
  JOIN dv_tds.sat_part sp 
    ON sp.part_hk = lps.part_hk 
 WHERE ss.s_name = 'Supplier#000001000'

/*
 
QUERY PLAN                                                                                                                                          |
----------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..1315.58 rows=80 width=149) (actual time=34.357..43.745 rows=80 loops=1)                       |
  ->  Hash Join  (cost=0.00..1315.54 rows=20 width=149) (actual time=28.536..42.780 rows=22 loops=1)                                                |
        Hash Cond: (sat_part.part_hk = link_part_supplier.part_hk)                                                                                  |
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 22 of 65536 buckets.                                                           |
        ->  Seq Scan on sat_part  (cost=0.00..432.28 rows=10000 width=108) (actual time=1.069..11.559 rows=10051 loops=1)                           |
        ->  Hash  (cost=878.79..878.79 rows=20 width=107) (actual time=27.058..27.058 rows=22 loops=1)                                              |
              ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..878.79 rows=20 width=107) (actual time=16.053..27.039 rows=22 loops=1)|
                    Hash Key: link_part_supplier.part_hk                                                                                            |
                    ->  Hash Join  (cost=0.00..878.79 rows=20 width=107) (actual time=5.088..23.716 rows=26 loops=1)                                |
                          Hash Cond: (link_part_supplier.supplier_hk = sat_supplier.supplier_hk)                                                    |
                          Extra Text: (seg3)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.                                          |
                          ->  Seq Scan on link_part_supplier  (cost=0.00..433.97 rows=40000 width=66) (actual time=0.358..8.555 rows=40123 loops=1) |
                          ->  Hash  (cost=431.34..431.34 rows=1 width=107) (actual time=1.073..1.073 rows=1 loops=1)                                |
                                ->  Seq Scan on sat_supplier  (cost=0.00..431.34 rows=1 width=107) (actual time=0.769..1.069 rows=1 loops=1)        |
                                      Filter: (s_name = 'Supplier#000001000'::bpchar)                                                               |
Planning time: 58.356 ms                                                                                                                            |
  (slice0)    Executor memory: 1560K bytes.                                                                                                         |
  (slice1)    Executor memory: 1593K bytes avg x 4 workers, 1593K bytes max (seg0).  Work_mem: 1K bytes max.                                        |
  (slice2)    Executor memory: 1480K bytes avg x 4 workers, 1480K bytes max (seg0).  Work_mem: 3K bytes max.                                        |
Memory used:  128000kB                                                                                                                              |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                               |
Execution time: 55.072 ms                                                                                                                           |
 
 */