-- dm.fill_dm_customer_analysis

CREATE OR REPLACE FUNCTION dm.fill_dm_customer_analysis(
	p_date_from date,
	p_date_to date
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_rows bigint;
BEGIN
    EXECUTE format('ALTER TABLE dm.dm_customer_analysis TRUNCATE PARTITION FOR (%L::date)', p_date_from);

    DROP TABLE IF EXISTS tmp_cust_metrics;
    CREATE TEMP TABLE tmp_cust_metrics ON COMMIT DROP AS
    WITH loads AS (
        SELECT load_hk,
               revenue,
               weight_lbs,
               load_status
          FROM (SELECT load_hk,
                       revenue,
                       weight_lbs,
                       load_status,
                       row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_load_details
                 WHERE load_date_value BETWEEN p_date_from AND p_date_to) t
         WHERE rn = 1
    )
    , wt_sts_load AS (
        SELECT load_hk, is_deleted
          FROM (SELECT load_hk, is_deleted,
                       row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_load_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    SELECT llc.customer_hk,
           count(*)::integer               AS orders_count,
           count(CASE
                   WHEN lc.load_status = 'Completed'
                   THEN 1
                 END)::integer             AS completed_orders,
           COALESCE(sum(lc.revenue), 0)    AS total_revenue,
           COALESCE(sum(lc.weight_lbs), 0) AS total_weight_lbs
      FROM dds.lnk_load_customer llc
      JOIN loads lc
        ON lc.load_hk = llc.load_hk
      LEFT
      JOIN wt_sts_load sl
        ON sl.load_hk = llc.load_hk
     WHERE COALESCE(sl.is_deleted, 'N') != 'Y'
     GROUP BY llc.customer_hk
    DISTRIBUTED BY (customer_hk);
    ANALYZE tmp_cust_metrics;

    INSERT INTO dm.dm_customer_analysis (
        customer_hk, 
		customer_bk, 
		customer_name, 
		customer_type, 
		account_status,
        orders_count, 
		completed_orders, 
		total_revenue, 
		avg_revenue_per_order,
        total_weight_lbs, 
		date_from, 
		date_to, 
		load_date)
    WITH wt_sts_customer AS (
        SELECT customer_hk, is_deleted
          FROM (SELECT customer_hk, is_deleted,
                       row_number() OVER (PARTITION BY customer_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_customer_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_customer_details AS (
        SELECT customer_hk,
               customer_name,
               customer_type,
               account_status
          FROM (SELECT customer_hk,
                       customer_name,
                       customer_type,
                       account_status,
                       row_number() OVER (PARTITION BY customer_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_customer_details) t
         WHERE rn = 1
    )
    SELECT hc.customer_hk,
           hc.customer_bk,
           cc.customer_name,
           cc.customer_type,
           cc.account_status,
           COALESCE(cm.orders_count, 0)::integer,
           COALESCE(cm.completed_orders, 0)::integer,
           COALESCE(cm.total_revenue, 0),
           CASE
             WHEN COALESCE(cm.orders_count, 0) <> 0
             THEN round(COALESCE(cm.total_revenue, 0) / NULLIF(cm.orders_count, 0), 2)
           END,
           COALESCE(cm.total_weight_lbs, 0),
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM dds.hub_customer hc
      LEFT
      JOIN wt_customer_details cc
        ON cc.customer_hk = hc.customer_hk
      LEFT
      JOIN wt_sts_customer sc
        ON sc.customer_hk = hc.customer_hk
      LEFT
      JOIN tmp_cust_metrics cm
        ON cm.customer_hk = hc.customer_hk
     WHERE COALESCE(sc.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    DROP TABLE IF EXISTS tmp_cust_metrics;
	ANALYZE dm.dm_customer_analysis;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_customer_analysis(date, date)
    IS 'Расчёт dm_customer_analysis за период. Метрики по заказам клиента.';
