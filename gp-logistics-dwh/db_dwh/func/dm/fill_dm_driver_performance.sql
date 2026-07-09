CREATE OR REPLACE FUNCTION dm.fill_dm_driver_performance(
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
    EXECUTE format('ALTER TABLE dm.dm_driver_performance TRUNCATE PARTITION FOR (%L::date)', p_date_from);

    DROP TABLE IF EXISTS tmp_drv_metrics;
    CREATE TEMP TABLE tmp_drv_metrics ON COMMIT DROP AS
    WITH trips AS (
        SELECT trip_hk,
               actual_distance_miles,
               fuel_gallons_used,
               idle_time_hours,
               trip_status
          FROM (SELECT trip_hk,
                       actual_distance_miles,
                       fuel_gallons_used,
                       idle_time_hours,
                       trip_status,
                       row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_trip_details
                 WHERE dispatch_date BETWEEN p_date_from AND p_date_to) t
         WHERE rn = 1
    )
    , wt_sts_trip_tmp AS (
        SELECT trip_hk, 
		       is_deleted
          FROM (SELECT trip_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_trip_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    SELECT ltd.driver_hk,
           count(*)::integer                          AS trips_completed,
           COALESCE(sum(tc.actual_distance_miles), 0) AS total_distance_miles,
           COALESCE(sum(tc.fuel_gallons_used), 0)     AS total_fuel_gallons,
           COALESCE(sum(tc.idle_time_hours), 0)       AS total_idle_hours
      FROM dds.lnk_trip_driver ltd
      JOIN trips tc
        ON tc.trip_hk = ltd.trip_hk
      JOIN wt_sts_trip_tmp st
        ON st.trip_hk = ltd.trip_hk
     WHERE tc.trip_status = 'Completed'
       AND COALESCE(st.is_deleted, 'N') != 'Y'
     GROUP BY ltd.driver_hk
    DISTRIBUTED BY (driver_hk);
    ANALYZE tmp_drv_metrics;

    INSERT INTO dm.dm_driver_performance 
	(
        driver_hk, 
		driver_bk, 
		driver_name, 
		employment_status, 
		hire_date, 
		tenure_years,
        years_experience, 
		trips_completed, 
		total_distance_miles, 
		total_fuel_gallons,
        avg_mpg, 
		total_idle_hours, 
		date_from, 
		date_to, 
		load_date
	)
    WITH wt_sts_driver AS (
        SELECT driver_hk, 
		       is_deleted
          FROM (SELECT driver_hk, 
		               is_deleted,
                       row_number() OVER (PARTITION BY driver_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_driver_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_driver_details AS (
        SELECT driver_hk,
               first_name,
               last_name,
               hire_date,
               employment_status,
               years_experience
          FROM (SELECT driver_hk,
                       first_name,
                       last_name,
                       hire_date,
                       employment_status,
                       years_experience,
                       row_number() OVER (PARTITION BY driver_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_driver_details) t
         WHERE rn = 1
    )
    SELECT hd.driver_hk,
           hd.driver_bk,
           dc.first_name || ' ' || dc.last_name,
           dc.employment_status,
           dc.hire_date,
           CASE
             WHEN dc.hire_date IS NOT NULL
             THEN round((current_date - dc.hire_date)::numeric / 365, 2)
           END,
           dc.years_experience,
           COALESCE(m.trips_completed, 0)::integer,
           COALESCE(m.total_distance_miles, 0),
           COALESCE(m.total_fuel_gallons, 0),
           CASE
             WHEN COALESCE(m.total_fuel_gallons, 0) > 0
             THEN round(COALESCE(m.total_distance_miles, 0)::numeric / NULLIF(m.total_fuel_gallons, 0), 2)
           END,
           COALESCE(m.total_idle_hours, 0),
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM dds.hub_driver hd
      LEFT
      JOIN wt_driver_details dc
        ON dc.driver_hk = hd.driver_hk
      LEFT
      JOIN wt_sts_driver sd
        ON sd.driver_hk = hd.driver_hk
      LEFT
      JOIN tmp_drv_metrics m
        ON m.driver_hk = hd.driver_hk
     WHERE COALESCE(sd.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    DROP TABLE IF EXISTS tmp_drv_metrics;
	ANALYZE dm.dm_driver_performance;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_driver_performance(date, date)
    IS 'Расчёт dm_driver_performance за период. Метрики по завершённым рейсам.';
