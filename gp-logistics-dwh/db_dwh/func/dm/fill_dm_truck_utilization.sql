-- dm.fill_dm_truck_utilization

CREATE OR REPLACE FUNCTION dm.fill_dm_truck_utilization(
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
    EXECUTE format('ALTER TABLE dm.dm_truck_utilization TRUNCATE PARTITION FOR (%L::date)', p_date_from);

    DROP TABLE IF EXISTS tmp_truck_trip;
    CREATE TEMP TABLE tmp_truck_trip ON COMMIT DROP AS
    WITH trips AS (
        SELECT trip_hk,
               actual_distance_miles,
               fuel_gallons_used
          FROM (SELECT trip_hk,
                       actual_distance_miles,
                       fuel_gallons_used,
                       row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_trip_details
                 WHERE dispatch_date BETWEEN p_date_from AND p_date_to) t
         WHERE rn = 1
    )
    SELECT ltt.truck_hk,
           count(*)::integer                          AS trips_count,
           COALESCE(sum(tc.actual_distance_miles), 0) AS total_distance_miles,
           COALESCE(sum(tc.fuel_gallons_used), 0)     AS total_fuel_gallons
      FROM dds.lnk_trip_truck ltt
      JOIN trips tc
        ON tc.trip_hk = ltt.trip_hk
      LEFT 
	  JOIN (SELECT trip_hk, 
	               is_deleted 
			  FROM (SELECT trip_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_trip_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) st
        ON st.trip_hk = ltt.trip_hk
     WHERE COALESCE(st.is_deleted, 'N') != 'Y'
     GROUP BY ltt.truck_hk
    DISTRIBUTED BY (truck_hk);
    ANALYZE tmp_truck_trip;

    DROP TABLE IF EXISTS tmp_truck_load;
    CREATE TEMP TABLE tmp_truck_load ON COMMIT DROP AS
    SELECT DISTINCT ltt.truck_hk, 
	       ltl.load_hk
      FROM dds.lnk_trip_truck ltt
      JOIN dds.lnk_trip_load ltl
        ON ltl.trip_hk = ltt.trip_hk
    DISTRIBUTED BY (load_hk);
    ANALYZE tmp_truck_load;

    DROP TABLE IF EXISTS tmp_truck_revenue;
    CREATE TEMP TABLE tmp_truck_revenue ON COMMIT DROP AS
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
    SELECT tl.truck_hk,
           COALESCE(sum(lc.revenue), 0) AS total_revenue
      FROM tmp_truck_load tl
      JOIN loads lc
        ON lc.load_hk = tl.load_hk
      LEFT 
	  JOIN (SELECT load_hk, 
	               is_deleted 
			  FROM (SELECT load_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_load_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) sl
        ON sl.load_hk = tl.load_hk
     WHERE COALESCE(sl.is_deleted, 'N') != 'Y'
     GROUP BY tl.truck_hk
    DISTRIBUTED BY (truck_hk);
    ANALYZE tmp_truck_revenue;
    DROP TABLE IF EXISTS tmp_truck_load;  

    DROP TABLE IF EXISTS tmp_truck_fuel;
    CREATE TEMP TABLE tmp_truck_fuel ON COMMIT DROP AS
    WITH fuel AS (
        SELECT fuel_purchase_hk,
               total_cost
          FROM (SELECT fuel_purchase_hk,
                       total_cost,
                       row_number() OVER (PARTITION BY fuel_purchase_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_fuel_purchase_details
                 WHERE purchase_date BETWEEN p_date_from AND v_date_to) t
         WHERE rn = 1
    )
    SELECT lft.truck_hk,
           COALESCE(sum(fc.total_cost), 0) AS total_fuel_cost
      FROM dds.lnk_fuel_truck lft
      JOIN fuel fc
        ON fc.fuel_purchase_hk = lft.fuel_purchase_hk
      LEFT 
	  JOIN (SELECT fuel_purchase_hk, 
	               is_deleted 
			  FROM (SELECT fuel_purchase_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY fuel_purchase_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_fuel_purchase_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) sf
        ON sf.fuel_purchase_hk = lft.fuel_purchase_hk
     WHERE COALESCE(sf.is_deleted, 'N') != 'Y'
     GROUP BY lft.truck_hk
    DISTRIBUTED BY (truck_hk);
    ANALYZE tmp_truck_fuel;

    DROP TABLE IF EXISTS tmp_truck_maint;
    CREATE TEMP TABLE tmp_truck_maint ON COMMIT DROP AS
    WITH maint AS (
        SELECT maintenance_hk,
               total_cost
          FROM (SELECT maintenance_hk,
                       total_cost,
                       row_number() OVER (PARTITION BY maintenance_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_maintenance_details
                 WHERE maintenance_date BETWEEN p_date_from AND p_date_to) t
         WHERE rn = 1
    )
    SELECT lmt.truck_hk,
           count(*)::integer             AS repairs_count,
           COALESCE(sum(mc.total_cost), 0) AS total_maintenance_cost
      FROM dds.lnk_maintenance_truck lmt
      JOIN maint mc
        ON mc.maintenance_hk = lmt.maintenance_hk
      LEFT 
	  JOIN (SELECT maintenance_hk, 
	               is_deleted 
			  FROM (SELECT maintenance_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY maintenance_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_maintenance_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) sm
        ON sm.maintenance_hk = lmt.maintenance_hk
     WHERE COALESCE(sm.is_deleted, 'N') != 'Y'
     GROUP BY lmt.truck_hk
    DISTRIBUTED BY (truck_hk);
    ANALYZE tmp_truck_maint;

    INSERT INTO dm.dm_truck_utilization 
	(
        truck_hk, 
		truck_bk, 
		make, 
		model_year, 
		fuel_type, 
		status, 
		trips_count,
        total_distance_miles, 
		total_revenue, 
		total_fuel_gallons, 
		total_fuel_cost,
        repairs_count, 
		total_maintenance_cost, 
		date_from, 
		date_to, 
		load_date
	)
    WITH wt_sts_truck AS (
        SELECT truck_hk, 
		       is_deleted
          FROM (SELECT truck_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY truck_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_truck_st
                 WHERE load_date <= p_date_to) z
         WHERE rn = 1
    )
    , wt_truck_details AS (
        SELECT truck_hk,
               make,
               model_year,
               fuel_type,
               status
          FROM (SELECT truck_hk,
                       make,
                       model_year,
                       fuel_type,
                       status,
                       row_number() OVER (PARTITION BY truck_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_truck_details) z
         WHERE rn = 1
    )
    SELECT ht.truck_hk,
           ht.truck_bk,
           tc.make,
           tc.model_year,
           tc.fuel_type,
           tc.status,
           COALESCE(tt.trips_count, 0)::integer,
           COALESCE(tt.total_distance_miles, 0),
           COALESCE(tr.total_revenue, 0),
           COALESCE(tt.total_fuel_gallons, 0),
           COALESCE(tf.total_fuel_cost, 0),
           COALESCE(tm.repairs_count, 0)::integer,
           COALESCE(tm.total_maintenance_cost, 0),
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM dds.hub_truck ht
      LEFT
      JOIN wt_truck_details tc
        ON tc.truck_hk = ht.truck_hk
      LEFT
      JOIN tmp_truck_trip tt 
	    ON tt.truck_hk = ht.truck_hk
      LEFT
      JOIN tmp_truck_revenue tr 
	    ON tr.truck_hk = ht.truck_hk
      LEFT
      JOIN tmp_truck_fuel tf 
	    ON tf.truck_hk = ht.truck_hk
      LEFT
      JOIN wt_sts_truck st
        ON st.truck_hk = ht.truck_hk
      LEFT
      JOIN tmp_truck_maint tm 
	    ON tm.truck_hk = ht.truck_hk
     WHERE COALESCE(st.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dm.dm_truck_utilization;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_truck_utilization(date, date)
    IS 'Расчёт dm_truck_utilization за период. Рейсы/пробег/топливо по рейсам, выручка по заказам, топливо, ремонты.';
