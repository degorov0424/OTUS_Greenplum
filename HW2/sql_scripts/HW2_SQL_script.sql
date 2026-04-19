EXPLAIN ANALYZE 
WITH 
  wt_supplier_rev AS (
    SELECT s.s_nationkey,
           s.s_suppkey,
           s.s_name,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS supp_revenue
      FROM tds1.lineitem l
      JOIN tds1.supplier s
        ON s.s_suppkey = l.l_suppkey
     WHERE l.l_shipdate BETWEEN DATE '1997-07-01' AND DATE '1997-07-31'
     GROUP BY s.s_nationkey,
              s.s_suppkey,
              s.s_name
)
SELECT t.region_name,
       t.nation_name,
       t.s_suppkey,
       t.s_name,
       t.supp_revenue,
       t.reg_revenue,
       RANK() OVER (PARTITION BY t.region_name
                        ORDER BY t.supp_revenue DESC) AS supp_region_rank,
       ROUND(100.0 * t.supp_revenue / t.reg_revenue,2)  AS percent_in_region
  FROM ( 
        SELECT sr.*,
               r.r_name AS region_name,
               n.n_name AS nation_name,
               SUM(sr.supp_revenue) OVER (PARTITION BY r.r_regionkey) AS reg_revenue
          FROM wt_supplier_rev sr 
          JOIN tds1.nation n
            ON n.n_nationkey = sr.s_nationkey
          JOIN tds1.region r
            ON r.r_regionkey = n.n_regionkey 
       ) t
 WHERE reg_revenue != 0
 ORDER BY region_name, 
          supp_region_rank;

--Execution time: 118.162 ms

------------------------------------------------

EXPLAIN ANALYZE 
WITH 
  wt_supplier_rev AS (
    SELECT s.s_nationkey,
           s.s_suppkey,
           s.s_name,
           SUM(l.l_extendedprice * (1 - l.l_discount)) AS supp_revenue
      FROM tds2.lineitem l
      JOIN tds2.supplier s
        ON s.s_suppkey = l.l_suppkey
     WHERE l.l_shipdate BETWEEN DATE '1997-07-01' AND DATE '1997-07-31'
     GROUP BY s.s_nationkey,
              s.s_suppkey,
              s.s_name
)
SELECT t.region_name,
       t.nation_name,
       t.s_suppkey,
       t.s_name,
       t.supp_revenue,
       t.reg_revenue,
       RANK() OVER (PARTITION BY t.region_name
                        ORDER BY t.supp_revenue DESC) AS supp_region_rank,
       ROUND(100.0 * t.supp_revenue / t.reg_revenue,2)  AS percent_in_region
  FROM ( 
        SELECT sr.*,
               r.r_name AS region_name,
               n.n_name AS nation_name,
               SUM(sr.supp_revenue) OVER (PARTITION BY r.r_regionkey) AS reg_revenue
          FROM wt_supplier_rev sr 
          JOIN tds2.nation n
            ON n.n_nationkey = sr.s_nationkey
          JOIN tds2.region r
            ON r.r_regionkey = n.n_regionkey 
       ) t
 WHERE reg_revenue != 0
 ORDER BY region_name, 
          supp_region_rank;

-- Execution time: 43.474 ms
