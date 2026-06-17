CREATE SCHEMA IF NOT EXISTS dm;
DROP MATERIALIZED VIEW IF EXISTS dm.mv_sales_monthly;
DROP TABLE IF EXISTS dm.dm_sales;
CREATE TABLE dm.dm_sales 
WITH (
    appendoptimized=true,
    orientation=column,
    compresstype=zstd,
    compresslevel=2
)
AS
SELECT ho.order_bk                                    AS order_id
     , so.o_orderdate
     , so.o_orderstatus
     , so.o_orderpriority
     , so.o_totalprice
     , hc.customer_bk                                 AS customer_id
     , sc.c_name
     , sc.c_mktsegment
     , sn.n_name                                      AS customer_nation
     , sr.r_name                                      AS customer_region
     , hp.part_bk                                     AS part_id
     , sp.p_name
     , sp.p_brand
     , sp.p_type
     , hs.supplier_bk                                 AS supplier_id
     , ss.s_name                                      AS supplier_name
     , lol.line_number
     , sol.l_quantity
     , sol.l_extendedprice
     , sol.l_discount
     , sol.l_tax
     , sol.l_extendedprice * (1 - sol.l_discount)     AS net_amount
  FROM dv_tds.link_order_line lol
  JOIN dv_tds.hub_order ho
    ON lol.order_hk = ho.order_hk
  JOIN dv_tds.sat_order so
    ON ho.order_hk = so.order_hk
  JOIN dv_tds.link_customer_order lco
    ON ho.order_hk = lco.order_hk
  JOIN dv_tds.hub_customer hc
    ON lco.customer_hk = hc.customer_hk
  JOIN dv_tds.sat_customer sc
    ON hc.customer_hk = sc.customer_hk
  JOIN dv_tds.link_customer_nation lcn
    ON hc.customer_hk = lcn.customer_hk
  JOIN dv_tds.hub_nation hn
    ON lcn.nation_hk = hn.nation_hk
  JOIN dv_tds.sat_nation sn
    ON hn.nation_hk = sn.nation_hk
  JOIN dv_tds.link_nation_region lnr
    ON hn.nation_hk = lnr.nation_hk
  JOIN dv_tds.hub_region hr
    ON lnr.region_hk = hr.region_hk
  JOIN dv_tds.sat_region sr
    ON hr.region_hk = sr.region_hk
  JOIN dv_tds.hub_part hp
    ON lol.part_hk = hp.part_hk
  JOIN dv_tds.sat_part sp
    ON hp.part_hk = sp.part_hk
  JOIN dv_tds.hub_supplier hs
    ON lol.supplier_hk = hs.supplier_hk
  JOIN dv_tds.sat_supplier ss
    ON hs.supplier_hk = ss.supplier_hk
  JOIN dv_tds.sat_order_line sol
    ON lol.order_line_hk = sol.order_line_hk

DISTRIBUTED BY (order_id);

DROP MATERIALIZED VIEW IF EXISTS dm.mv_sales_monthly;
CREATE MATERIALIZED VIEW dm.mv_sales_monthly AS
SELECT date_trunc('month', o_orderdate)::DATE AS month_dt
     , customer_region
     , p_brand
     , SUM(net_amount) AS sales_amount
     , COUNT(*) AS sales_cnt
  FROM dm.dm_sales
 GROUP BY date_trunc('month', o_orderdate)::DATE
        , customer_region
        , p_brand
DISTRIBUTED RANDOMLY;


REFRESH MATERIALIZED VIEW dm.mv_sales_monthly;

EXPLAIN ANALYZE
SELECT month_dt
     , customer_region
     , p_brand
     , sales_amount
     , sales_cnt
FROM dm.mv_sales_monthly
WHERE p_brand = 'Brand#54';

/*
QUERY PLAN                                                                                                                 |
---------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..431.19 rows=400 width=36) (actual time=1.186..1.305 rows=400 loops=1)|
  ->  Seq Scan on mv_sales_monthly  (cost=0.00..431.14 rows=100 width=36) (actual time=0.023..0.641 rows=113 loops=1)      |
        Filter: ((p_brand)::text = 'Brand#54'::text)                                                                       |
Planning time: 12.541 ms                                                                                                   |
  (slice0)    Executor memory: 87K bytes.                                                                                  |
  (slice1)    Executor memory: 59K bytes avg x 4 workers, 59K bytes max (seg0).                                            |
Memory used:  128000kB                                                                                                     |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                      |
Execution time: 1.872 ms                                                                                                   |                                                                                                      |
 */

EXPLAIN ANALYZE
SELECT date_trunc('month', o_orderdate)::DATE AS month_dt
     , customer_region
     , p_brand
     , SUM(net_amount) AS sales_amount
     , COUNT(*) AS sales_cnt
 FROM dm.dm_sales
WHERE p_brand = 'Brand#54'
GROUP BY date_trunc('month', o_orderdate)::DATE
        , customer_region
        , p_brand;
/*
QUERY PLAN                                                                                                                                        |
--------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..484.42 rows=6767 width=36) (actual time=131.352..131.465 rows=400 loops=1)                  |
  ->  HashAggregate  (cost=0.00..483.60 rows=1692 width=36) (actual time=130.923..130.977 rows=115 loops=1)                                       |
        Group Key: (date(date_trunc('month'::text, (o_orderdate)::timestamp with time zone))), customer_region, p_brand                           |
        Extra Text: (seg3)   Hash chain length 3.8 avg, 7 max, using 30 of 32 buckets; total 0 expansions.                                        |
                                                                                                                                                  |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..482.94 rows=1692 width=36) (actual time=114.917..130.271 rows=460 loops=1)|
              Hash Key: (date(date_trunc('month'::text, (o_orderdate)::timestamp with time zone))), customer_region, p_brand                      |
              ->  Result  (cost=0.00..482.75 rows=1692 width=36) (actual time=112.685..113.033 rows=399 loops=1)                                  |
                    ->  HashAggregate  (cost=0.00..482.75 rows=1692 width=36) (actual time=112.684..112.980 rows=399 loops=1)                     |
                          Group Key: date(date_trunc('month'::text, (o_orderdate)::timestamp with time zone)), customer_region, p_brand           |
                          Extra Text: (seg1)   Hash chain length 3.2 avg, 9 max, using 123 of 128 buckets; total 2 expansions.                    |
                                                                                                                                                  |
                          ->  Result  (cost=0.00..478.39 rows=11361 width=28) (actual time=1.016..103.651 rows=11825 loops=1)                     |
                                ->  Seq Scan on dm_sales  (cost=0.00..476.94 rows=11361 width=28) (actual time=0.998..93.218 rows=11825 loops=1)  |
                                      Filter: ((p_brand)::text = 'Brand#54'::text)                                                                |
Planning time: 80.875 ms                                                                                                                          |
  (slice0)    Executor memory: 552K bytes.                                                                                                        |
  (slice1)    Executor memory: 1008K bytes avg x 4 workers, 1012K bytes max (seg1).                                                               |
  (slice2)    Executor memory: 240K bytes avg x 4 workers, 240K bytes max (seg0).                                                                 |
Memory used:  128000kB                                                                                                                            |
Optimizer: Pivotal Optimizer (GPORCA)                                                                                                             |
Execution time: 132.476 ms                                                                                                                        |                                                                                                                     |                                                                                                                             |
 */

DO $$ 
DECLARE
    v_start_time   TIMESTAMP;
    v_middle_time  TIMESTAMP;
    v_finish_time  TIMESTAMP;
BEGIN

    v_start_time := clock_timestamp();
    
    REFRESH MATERIALIZED VIEW dm.mv_sales_monthly;

    PERFORM month_dt
          , customer_region
          , p_brand
          , sales_amount
          , sales_cnt
       FROM dm.mv_sales_monthly
      WHERE p_brand = 'Brand#54'; 
    
    v_middle_time := clock_timestamp();
    
    PERFORM date_trunc('month', o_orderdate)::DATE AS month_dt
          , customer_region
          , p_brand
          , SUM(net_amount) AS sales_amount
          , COUNT(*) AS sales_cnt
       FROM dm.dm_sales
      WHERE p_brand = 'Brand#54'
      GROUP BY date_trunc('month', o_orderdate)::DATE
            , customer_region
            , p_brand;
    
    v_finish_time := clock_timestamp();
    
    RAISE NOTICE 'Время выполнения запроса к материализованному представлению: %', (v_middle_time - v_start_time);
    RAISE NOTICE 'Время выполнения запроса к витрине: %', (v_finish_time - v_middle_time);
    RAISE NOTICE 'Общее время выполнения: %', (v_finish_time - v_start_time);
END $$;


SELECT c_name
     , SUM(net_amount) AS sales
     , RANK() OVER (ORDER BY SUM(net_amount) DESC) AS sales_rank
FROM dm.dm_sales
GROUP BY c_name;


WITH monthly_sales AS
(SELECT date_trunc('month', o_orderdate)::DATE AS month_dt
      , SUM(net_amount) AS sales
    FROM dm.dm_sales
    GROUP BY date_trunc('month', o_orderdate)::DATE
)
SELECT month_dt
     , sales
     , LAG(sales) OVER (ORDER BY month_dt) AS prev_month
     , sales - LAG(sales) OVER (ORDER BY month_dt) AS growth
FROM monthly_sales;


SELECT *
  FROM ( SELECT customer_region
              , p_brand
              , SUM(net_amount) AS sales
              , ROW_NUMBER() OVER( PARTITION BY customer_region
                                       ORDER BY SUM(net_amount) DESC) AS rn

          FROM dm.dm_sales
         GROUP BY customer_region, p_brand
       ) t
WHERE rn <= 3;