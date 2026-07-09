CREATE OR REPLACE FUNCTION dm.fill_dm_trip_facts(
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
    EXECUTE format('ALTER TABLE dm.dm_trip_facts TRUNCATE PARTITION FOR (%L::date)', p_date_from);


    DROP TABLE IF EXISTS tmp_trips;
    CREATE TEMP TABLE tmp_trips ON COMMIT DROP AS
    SELECT trip_hk,
           dispatch_date,
           actual_distance_miles,
           actual_duration_hours,
           fuel_gallons_used,
           average_mpg,
           idle_time_hours,
           trip_status
      FROM (SELECT trip_hk,
                   dispatch_date,
                   actual_distance_miles,
                   actual_duration_hours,
                   fuel_gallons_used,
                   average_mpg,
                   idle_time_hours,
                   trip_status,
                   row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
              FROM dds.sat_trip_details
             WHERE dispatch_date BETWEEN p_date_from AND p_date_to
               AND trip_status = 'Completed') t
     WHERE rn = 1
    DISTRIBUTED BY (trip_hk);
    ANALYZE tmp_trips;

   
    DROP TABLE IF EXISTS tmp_trip_load;
    CREATE TEMP TABLE tmp_trip_load ON COMMIT DROP AS
    SELECT DISTINCT t.trip_hk, 
	       ltl.load_hk
      FROM tmp_trips t
      JOIN dds.lnk_trip_load ltl
        ON ltl.trip_hk = t.trip_hk
    DISTRIBUTED BY (load_hk);
    ANALYZE tmp_trip_load;

   
    DROP TABLE IF EXISTS tmp_trip_load_denorm;
    CREATE TEMP TABLE tmp_trip_load_denorm ON COMMIT DROP AS
    WITH loads_revenue AS (
        SELECT load_hk,
               revenue
          FROM (SELECT load_hk,
                       revenue,
                       row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_load_details) t
         WHERE rn = 1
    )
    , wt_route AS (
        SELECT route_hk,
               origin_city || ' → ' || destination_city AS route_name
          FROM (SELECT route_hk, origin_city, destination_city,
                       row_number() OVER (PARTITION BY route_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_route_details) t
         WHERE rn = 1
    )
    , wt_customer AS (
        SELECT customer_hk,
               customer_name
          FROM (SELECT customer_hk, customer_name,
                       row_number() OVER (PARTITION BY customer_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_customer_details) t
         WHERE rn = 1
    )
    SELECT tl.trip_hk,
           lr.route_hk,
           rc.route_name,
           lc.customer_hk,
           cu.customer_name,
           rev.revenue
      FROM tmp_trip_load tl
      LEFT
      JOIN dds.lnk_load_route lr
        ON lr.load_hk = tl.load_hk
      LEFT
      JOIN wt_route rc
        ON rc.route_hk = lr.route_hk
      LEFT
      JOIN dds.lnk_load_customer lc
        ON lc.load_hk = tl.load_hk
      LEFT
      JOIN wt_customer cu
        ON cu.customer_hk = lc.customer_hk
      LEFT
      JOIN loads_revenue rev
        ON rev.load_hk = tl.load_hk
    DISTRIBUTED BY (trip_hk);
    ANALYZE tmp_trip_load_denorm;

    INSERT INTO dm.dm_trip_facts 
	(
        trip_hk, 
		trip_bk, 
		dispatch_date,
        driver_hk, 
		driver_name,
        truck_hk, 
		truck_bk, 
		make,
        load_hk, 
		load_bk,
        route_hk, 
		route_name,
        customer_hk, 
		customer_name,
        actual_distance_miles, 
		actual_duration_hours, 
		fuel_gallons_used,
        average_mpg, 
		idle_time_hours, 
		trip_status, 
		revenue,
        date_from, 
		date_to, 
		load_date
	)
    WITH wt_sts_trip AS (
        SELECT trip_hk, 
		       is_deleted
          FROM (SELECT trip_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_trip_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_sts_driver AS (
        SELECT driver_hk, 
		       is_deleted
          FROM (SELECT driver_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY driver_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_driver_st 
				 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_sts_load AS (
        SELECT load_hk, 
		       is_deleted
          FROM (SELECT load_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY load_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_load_st 
				 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_sts_truck AS (
        SELECT truck_hk, 
		       is_deleted
          FROM (SELECT truck_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY truck_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_truck_st 
				 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_driver AS (
        SELECT driver_hk, 
		       first_name || ' ' || last_name AS driver_name
          FROM (SELECT driver_hk, 
		               first_name, 
					   last_name,
                       row_number() OVER (PARTITION BY driver_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_driver_details) t
         WHERE rn = 1
    )
    , wt_truck AS (
        SELECT truck_hk, 
		       make
          FROM (SELECT truck_hk, 
		               make,
                       row_number() OVER (PARTITION BY truck_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_truck_details) t
         WHERE rn = 1
    )
    SELECT t.trip_hk,
           ht.trip_bk,
           t.dispatch_date,
           td.driver_hk,
           dn.driver_name,
           tt.truck_hk,
           htr.truck_bk,
           tr.make,
           tload.load_hk,
           hl.load_bk,
           dld.route_hk,
           dld.route_name,
           dld.customer_hk,
           dld.customer_name,
           t.actual_distance_miles,
           t.actual_duration_hours,
           t.fuel_gallons_used,
           t.average_mpg,
           t.idle_time_hours,
           t.trip_status,
           dld.revenue,
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM tmp_trips t
      LEFT
      JOIN dds.hub_trip ht
        ON ht.trip_hk = t.trip_hk
      LEFT
      JOIN dds.lnk_trip_driver td
        ON td.trip_hk = t.trip_hk
      LEFT
      JOIN wt_driver dn
        ON dn.driver_hk = td.driver_hk
      LEFT
      JOIN dds.lnk_trip_truck tt
        ON tt.truck_hk = t.trip_hk
      LEFT
      JOIN dds.hub_truck htr
        ON htr.truck_hk = tt.truck_hk
      LEFT
      JOIN wt_truck tr
        ON tr.truck_hk = tt.truck_hk
      LEFT
      JOIN tmp_trip_load tload
        ON tload.trip_hk = t.trip_hk
      LEFT
      JOIN dds.hub_load hl
        ON hl.load_hk = tload.load_hk
      LEFT
      JOIN wt_sts_trip st
        ON st.trip_hk = t.trip_hk
      LEFT
      JOIN tmp_trip_load_denorm dld
        ON dld.trip_hk = t.trip_hk
      LEFT 
	  JOIN wt_sts_driver sdn 
	    ON sdn.driver_hk = td.driver_hk
      LEFT 
	  JOIN wt_sts_load sld 
	    ON sld.load_hk   = tload.load_hk
      LEFT 
	  JOIN wt_sts_truck str 
	    ON str.truck_hk  = tt.truck_hk
     WHERE COALESCE(st.is_deleted, 'N') != 'Y'
       AND COALESCE(sdn.is_deleted, 'N') != 'Y'
       AND COALESCE(sld.is_deleted, 'N') != 'Y'
       AND COALESCE(str.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dm.dm_trip_facts;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_trip_facts(date, date)
    IS 'Расчёт dm_trip_facts за период. Факт-витрина выполненных рейсов';
