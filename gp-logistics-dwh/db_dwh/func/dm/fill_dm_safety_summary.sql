-- dm.fill_dm_safety_summary

CREATE OR REPLACE FUNCTION dm.fill_dm_safety_summary(
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
    EXECUTE format('ALTER TABLE dm.dm_safety_summary TRUNCATE PARTITION FOR (%L::date)', p_date_from);


    DROP TABLE IF EXISTS tmp_incidents;
    CREATE TEMP TABLE tmp_incidents ON COMMIT DROP AS
	WITH wt_incident_details AS (
	  SELECT incident_hk,
			 at_fault_flag,
			 preventable_flag,
			 injury_flag,
			 vehicle_damage_cost,
			 cargo_damage_cost,
			 claim_amount
	    FROM (SELECT incident_hk,
				     at_fault_flag,
				     preventable_flag,
				     injury_flag,
				     vehicle_damage_cost,
				     cargo_damage_cost,
				     claim_amount,
				     row_number() OVER (PARTITION BY incident_hk ORDER BY load_date DESC) AS rn
			    FROM dds.sat_incident_details
			   WHERE incident_date BETWEEN p_date_from AND v_date_to) t
	   WHERE rn = 1
	) 
    SELECT i.incident_hk,
           i.at_fault_flag,
           i.preventable_flag,
           i.injury_flag,
           i.vehicle_damage_cost,
           i.cargo_damage_cost,
           i.claim_amount
      FROM wt_incident_details i
      LEFT 
	  JOIN (SELECT incident_hk, 
	               is_deleted
            FROM (SELECT incident_hk, 
			             is_deleted,
                         row_number() OVER (PARTITION BY incident_hk ORDER BY load_date DESC) AS rn
                    FROM dds.sat_incident_st
                   WHERE load_date <= p_date_to) t2
           WHERE rn = 1
            ) si 
	    ON si.incident_hk = i.incident_hk
    WHERE COALESCE(si.is_deleted, 'N') != 'Y'
    DISTRIBUTED BY (incident_hk);
    ANALYZE tmp_incidents;


    DROP TABLE IF EXISTS tmp_drv_incidents;
    CREATE TEMP TABLE tmp_drv_incidents ON COMMIT DROP AS
    SELECT id.driver_hk,
           count(*)::integer AS incidents_count,
           count(CASE
                   WHEN i.at_fault_flag
                   THEN 1
                 END)::integer   AS at_fault_count,
           count(CASE
                   WHEN i.preventable_flag
                   THEN 1
                 END)::integer AS preventable_count,
           count(CASE
                   WHEN i.injury_flag
                   THEN 1
                 END)::integer  AS injury_count,
           COALESCE(sum(i.vehicle_damage_cost), 0) AS total_vehicle_damage,
           COALESCE(sum(i.cargo_damage_cost), 0)   AS total_cargo_damage,
           COALESCE(sum(i.claim_amount), 0)        AS total_claims
      FROM dds.lnk_incident_driver id
      JOIN tmp_incidents i
        ON i.incident_hk = id.incident_hk
     GROUP BY id.driver_hk
    DISTRIBUTED BY (driver_hk);
    ANALYZE tmp_drv_incidents;
    DROP TABLE IF EXISTS tmp_incidents;      

    INSERT INTO dm.dm_safety_summary 
	(
        driver_hk, 
		driver_bk, 
		driver_name, 
		incidents_count, 
		at_fault_count, 
		preventable_count,
        injury_count, 
		total_vehicle_damage, 
		total_cargo_damage, 
		total_claims, 
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
               last_name
          FROM (SELECT driver_hk,
                       first_name,
                       last_name,
                       row_number() OVER (PARTITION BY driver_hk ORDER BY load_date DESC) AS rn
                  FROM dds.sat_driver_details) t
         WHERE rn = 1
    )
    SELECT hd.driver_hk,
           hd.driver_bk,
           dc.first_name || ' ' || dc.last_name,
           COALESCE(di.incidents_count, 0)::integer,
           COALESCE(di.at_fault_count, 0)::integer,
           COALESCE(di.preventable_count, 0)::integer,
           COALESCE(di.injury_count, 0)::integer,
           COALESCE(di.total_vehicle_damage, 0),
           COALESCE(di.total_cargo_damage, 0),
           COALESCE(di.total_claims, 0),
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
      JOIN tmp_drv_incidents di
        ON di.driver_hk = hd.driver_hk
     WHERE COALESCE(sd.is_deleted, 'N') != 'Y';

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    ANALYZE dm.dm_safety_summary;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_safety_summary(date, date)
    IS 'Расчёт dm_safety_summary за период. Инциденты/ущерб по водителю.';
