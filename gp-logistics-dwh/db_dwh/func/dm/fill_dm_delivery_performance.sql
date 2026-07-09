-- dm.fill_dm_delivery_performance

CREATE OR REPLACE FUNCTION dm.fill_dm_delivery_performance(
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
    EXECUTE format('ALTER TABLE dm.dm_delivery_performance TRUNCATE PARTITION FOR (%L::date)', p_date_from);

    DROP TABLE IF EXISTS tmp_events;
    CREATE TEMP TABLE tmp_events ON COMMIT DROP AS
    SELECT e.delivery_event_hk,
           e.event_type,
           e.on_time_flag,
           e.detention_minutes
      FROM (SELECT delivery_event_hk,
                   event_type,
                   on_time_flag,
                   detention_minutes,
                   row_number() OVER (PARTITION BY delivery_event_hk ORDER BY load_date DESC) AS rn
              FROM dds.sat_delivery_event_details
             WHERE actual_datetime BETWEEN p_date_from AND v_date_to) e
     WHERE rn = 1
    DISTRIBUTED BY (delivery_event_hk);
    ANALYZE tmp_events;

    DROP TABLE IF EXISTS tmp_event_trip;
    CREATE TEMP TABLE tmp_event_trip ON COMMIT DROP AS
    SELECT e.delivery_event_hk, 
	       et.trip_hk, 
		   e.event_type, 
		   e.on_time_flag, 
		   e.detention_minutes
      FROM tmp_events e
      JOIN dds.lnk_event_trip et
        ON et.delivery_event_hk = e.delivery_event_hk
      LEFT 
	  JOIN (SELECT trip_hk, 
	               is_deleted 
			  FROM (SELECT trip_hk, 
			               is_deleted,
                           row_number() OVER (PARTITION BY trip_hk ORDER BY load_date DESC) rn
                      FROM dds.sat_trip_st 
					 WHERE load_date <= p_date_to) t 
			 WHERE rn=1) st
        ON st.trip_hk = et.trip_hk
     WHERE COALESCE(st.is_deleted, 'N') != 'Y'
    DISTRIBUTED BY (trip_hk);
    ANALYZE tmp_event_trip;
    DROP TABLE IF EXISTS tmp_events;    

    DROP TABLE IF EXISTS tmp_event_load;
    CREATE TEMP TABLE tmp_event_load ON COMMIT DROP AS
    SELECT et.delivery_event_hk, 
	       et.event_type, 
		   et.on_time_flag, 
		   et.detention_minutes, 
		   tl.load_hk
      FROM tmp_event_trip et
      JOIN dds.lnk_trip_load tl
        ON tl.trip_hk = et.trip_hk
    DISTRIBUTED BY (load_hk);
    ANALYZE tmp_event_load;
    DROP TABLE IF EXISTS tmp_event_trip; 

    DROP TABLE IF EXISTS tmp_route_events;
    CREATE TEMP TABLE tmp_route_events ON COMMIT DROP AS
    SELECT llr.route_hk,
           count(*)::integer AS total_events,
           count(CASE
                   WHEN el.event_type = 'Pickup'
                   THEN 1
                 END)::integer   AS pickup_count,
           count(CASE
                   WHEN el.event_type = 'Delivery'
                   THEN 1
                 END)::integer AS delivery_count,
           count(CASE
                   WHEN el.on_time_flag
                   THEN 1
                 END)::integer  AS on_time_count,
           avg(el.detention_minutes)  AS avg_detention_minutes
      FROM tmp_event_load el
      JOIN dds.lnk_load_route llr
        ON llr.load_hk = el.load_hk
     GROUP BY llr.route_hk
    DISTRIBUTED BY (route_hk);
    ANALYZE tmp_route_events;
    DROP TABLE IF EXISTS tmp_event_load;      

    INSERT INTO dm.dm_delivery_performance 
	(
        route_hk, 
		route_bk, 
		origin_city, 
		destination_city, 
		total_events, 
		pickup_count,
        delivery_count, 
		on_time_count, 
		on_time_pct, 
		avg_detention_minutes, 
		date_from, 
		date_to, 
		load_date
	)
    WITH wt_sts_event AS (
        SELECT delivery_event_hk, is_deleted
          FROM (SELECT delivery_event_hk, is_deleted,
                       row_number() OVER (PARTITION BY delivery_event_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_delivery_event_st
                 WHERE load_date <= p_date_to) t
         WHERE rn = 1
    )
    , wt_route_details AS (
        SELECT route_hk,
               origin_city,
               destination_city
          FROM (SELECT route_hk,
                       origin_city,
                       destination_city,
                       row_number() OVER (PARTITION BY route_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_route_details) t
         WHERE rn = 1
    )
    SELECT hr.route_hk,
           hr.route_bk,
           rc.origin_city,
           rc.destination_city,
           COALESCE(re.total_events, 0)::integer,
           COALESCE(re.pickup_count, 0)::integer,
           COALESCE(re.delivery_count, 0)::integer,
           COALESCE(re.on_time_count, 0)::integer,
           CASE
             WHEN COALESCE(re.total_events, 0) > 0
             THEN round(100.0 * COALESCE(re.on_time_count, 0) / NULLIF(re.total_events, 0), 2)
           END,
           re.avg_detention_minutes,
           p_date_from,
           p_date_to,
           clock_timestamp()
      FROM dds.hub_route hr
      LEFT
      JOIN wt_route_details rc
        ON rc.route_hk = hr.route_hk
      LEFT
      JOIN tmp_route_events re
        ON re.route_hk = hr.route_hk;
    
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    DROP TABLE IF EXISTS tmp_route_events;
	ANALYZE dm.dm_delivery_performance;
	
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_delivery_performance(date, date)
    IS 'Расчёт dm_delivery_performance за период. Своевременность доставки по маршруту.';
