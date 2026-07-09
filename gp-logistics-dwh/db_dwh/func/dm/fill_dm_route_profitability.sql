-- dm.fill_dm_route_profitability

CREATE OR REPLACE FUNCTION dm.fill_dm_route_profitability(
	p_date_from date,
	p_date_to date
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_rows    bigint;
    v_date_to date := p_date_to + 1;
BEGIN
    EXECUTE format('ALTER TABLE dm.dm_route_profitability TRUNCATE PARTITION FOR (%L::date)', p_date_from);


    DROP TABLE IF EXISTS tmp_period_trips;
    CREATE TEMP TABLE tmp_period_trips ON COMMIT DROP AS
    SELECT trip_hk
      FROM (SELECT trip_hk,
                   row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
              FROM dds.sat_trip_details
             WHERE dispatch_date BETWEEN p_date_from AND p_date_to) t
     WHERE rn = 1
    DISTRIBUTED BY (trip_hk);
    ANALYZE tmp_period_trips;


    DROP TABLE IF EXISTS tmp_tl;
    CREATE TEMP TABLE tmp_tl ON COMMIT DROP AS
    SELECT pt.trip_hk, 
	       ltl.load_hk
      FROM tmp_period_trips pt
      JOIN dds.lnk_trip_load ltl
        ON ltl.trip_hk = pt.trip_hk
    DISTRIBUTED BY (load_hk);
    ANALYZE tmp_tl;
    DROP TABLE IF EXISTS tmp_period_trips;   


    DROP TABLE IF EXISTS tmp_route_trips;
    CREATE TEMP TABLE tmp_route_trips ON COMMIT DROP AS
    SELECT llr.route_hk,
           count(DISTINCT tl.trip_hk)::integer AS trips_count
      FROM tmp_tl tl
      JOIN dds.lnk_load_route llr
        ON llr.load_hk = tl.load_hk
     GROUP BY llr.route_hk
    DISTRIBUTED BY (route_hk);
    ANALYZE tmp_route_trips;
    DROP TABLE IF EXISTS tmp_tl;         


    DROP TABLE IF EXISTS tmp_route_revenue;
    CREATE TEMP TABLE tmp_route_revenue ON COMMIT DROP AS
    WITH loads AS (
        SELECT load_hk,
               revenue
          FROM (SELECT load_hk,
                       revenue,
                       row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_load_details
                 WHERE load_date_value BETWEEN p_date_from AND p_date_to) t
         WHERE rn = 1
    )
    SELECT llr.route_hk,
           COALESCE(sum(lc.revenue), 0) AS total_revenue
      FROM dds.lnk_load_route llr
      JOIN loads lc
        ON lc.load_hk = llr.load_hk
      LEFT 
	  JOIN (SELECT load_hk, 
	               is_deleted 
			  FROM (SELECT load_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_load_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) sl
        ON sl.load_hk = llr.load_hk
     WHERE COALESCE(sl.is_deleted, 'N') != 'Y'
     GROUP BY llr.route_hk
    DISTRIBUTED BY (route_hk);
    ANALYZE tmp_route_revenue;



    DROP TABLE IF EXISTS tmp_period_fuel;
    CREATE TEMP TABLE tmp_period_fuel ON COMMIT DROP AS
    SELECT fuel_purchase_hk,
           total_cost
      FROM (SELECT fuel_purchase_hk,
                   total_cost,
                   row_number() OVER (PARTITION BY fuel_purchase_hk ORDER BY load_date DESC) AS rn
              FROM dds.sat_fuel_purchase_details
             WHERE purchase_date BETWEEN p_date_from AND v_date_to) t
     WHERE rn = 1
    DISTRIBUTED BY (fuel_purchase_hk);
    ANALYZE tmp_period_fuel;


    DROP TABLE IF EXISTS tmp_ft;
    CREATE TEMP TABLE tmp_ft ON COMMIT DROP AS
    SELECT pf.fuel_purchase_hk, 
	       lft.trip_hk, 
		   pf.total_cost
      FROM tmp_period_fuel pf
      JOIN dds.lnk_fuel_trip lft
        ON lft.fuel_purchase_hk = pf.fuel_purchase_hk
    DISTRIBUTED BY (trip_hk);
    ANALYZE tmp_ft;
    DROP TABLE IF EXISTS tmp_period_fuel;  


    DROP TABLE IF EXISTS tmp_ftl;
    CREATE TEMP TABLE tmp_ftl ON COMMIT DROP AS
    SELECT ft.trip_hk, 
	       ft.total_cost,
           ft.fuel_purchase_hk,		   
		   ltl.load_hk
      FROM tmp_ft ft
      JOIN dds.lnk_trip_load ltl
        ON ltl.trip_hk = ft.trip_hk
    DISTRIBUTED BY (load_hk);
    ANALYZE tmp_ftl;
    DROP TABLE IF EXISTS tmp_ft;   


    DROP TABLE IF EXISTS tmp_route_fuel_cost;
    CREATE TEMP TABLE tmp_route_fuel_cost ON COMMIT DROP AS
    SELECT llr.route_hk,
           COALESCE(sum(ftl.total_cost), 0) AS total_fuel_cost
      FROM tmp_ftl ftl
      JOIN dds.lnk_load_route llr
        ON llr.load_hk = ftl.load_hk
      LEFT 
	  JOIN (SELECT fuel_purchase_hk, 
	               is_deleted 
			  FROM (SELECT fuel_purchase_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY fuel_purchase_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_fuel_purchase_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) sf
        ON sf.fuel_purchase_hk = ftl.fuel_purchase_hk
     WHERE COALESCE(sf.is_deleted, 'N') != 'Y'
     GROUP BY llr.route_hk
    DISTRIBUTED BY (route_hk);
    ANALYZE tmp_route_fuel_cost;
    DROP TABLE IF EXISTS tmp_ftl;        


    INSERT INTO dm.dm_route_profitability 
	(
        route_hk, 
		route_bk, 
		origin_city, 
		origin_state, 
		destination_city, 
		destination_state,
        typical_distance_miles, 
		trips_count, 
		total_revenue, 
		total_fuel_cost, 
		profit,
        profit_margin_pct, 
		date_from, 
		date_to, 
		load_date
	)
    WITH wt_sts_route AS (
        SELECT route_hk, 
		       is_deleted
          FROM (SELECT route_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY route_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_route_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_route_details AS (
        SELECT route_hk,
               origin_city,
               origin_state,
               destination_city,
               destination_state,
               typical_distance_miles
          FROM (SELECT route_hk,
                       origin_city,
                       origin_state,
                       destination_city,
                       destination_state,
                       typical_distance_miles,
                       row_number() OVER (PARTITION BY route_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_route_details) t
         WHERE rn = 1
    )
    SELECT hr.route_hk,
           hr.route_bk,
           rc.origin_city,
           rc.origin_state,
           rc.destination_city,
           rc.destination_state,
           rc.typical_distance_miles,
           COALESCE(rt.trips_count, 0)::integer,
           COALESCE(rr.total_revenue, 0),
           COALESCE(rf.total_fuel_cost, 0),
           COALESCE(rr.total_revenue, 0) - COALESCE(rf.total_fuel_cost, 0),
           CASE
             WHEN COALESCE(rr.total_revenue, 0) <> 0
             THEN round((COALESCE(rr.total_revenue, 0) - COALESCE(rf.total_fuel_cost, 0)) * 100.0
                        / NULLIF(rr.total_revenue, 0), 2)
           END,
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM dds.hub_route hr
      LEFT
      JOIN wt_route_details rc
        ON rc.route_hk = hr.route_hk
      LEFT
      JOIN tmp_route_trips     rt 
	    ON rt.route_hk = hr.route_hk
      LEFT
      JOIN tmp_route_revenue   rr 
	    ON rr.route_hk = hr.route_hk
      LEFT
      JOIN wt_sts_route sr
        ON sr.route_hk = hr.route_hk
      LEFT
      JOIN tmp_route_fuel_cost rf 
	    ON rf.route_hk = hr.route_hk
     WHERE COALESCE(sr.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dm.dm_route_profitability;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_route_profitability(date, date)
    IS 'Расчёт dm_route_profitability за период.';
