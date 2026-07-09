CREATE OR REPLACE FUNCTION dm.fill_dm_fleet_kpi(
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
    EXECUTE format('ALTER TABLE dm.dm_fleet_kpi TRUNCATE PARTITION FOR (%L::date)', p_date_from);

    INSERT INTO dm.dm_fleet_kpi 
	(
        date_from, 
		date_to, 
		total_trips, 
		active_drivers, 
		active_trucks,
        total_distance_miles, 
		total_fuel_gallons, 
		total_revenue, 
		total_fuel_cost,
        total_profit, 
		profit_margin_pct, 
		total_incidents, 
		total_claims,
        total_maintenance_cost, 
		load_date
		)
	WITH wt_driver_performance AS (
		SELECT sum(trips_completed)::int as total_trips,
               count(DISTINCT driver_hk) as active_drivers,
               sum(total_distance_miles) as total_distance_miles,
			   sum(total_fuel_gallons)   as total_fuel_gallons
		  FROM dm.dm_driver_performance 
		 WHERE date_from = p_date_from
	),
	wt_truck_utilization AS (
	    SELECT count(DISTINCT truck_hk)    as active_trucks,
               sum(total_maintenance_cost) as total_maintenance_cost		
		  FROM dm.dm_truck_utilization  
		 WHERE date_from = p_date_from
	),
	wt_route_profitability AS (
	    SELECT CASE 
			     WHEN total_revenue != 0
                 THEN round(total_profit * 100.0
                           / total_revenue, 2)
               END			                        as profit_margin_pct,
			   total_revenue,
			   total_fuel_cost,
			   total_profit
		  FROM ( SELECT sum(total_revenue)            as total_revenue,
					    sum(total_fuel_cost)          as total_fuel_cost,
					    sum(profit)                   as total_profit                  
				   FROM dm.dm_route_profitability 
				  WHERE date_from = p_date_from) t
	),
	wt_safety_summary AS (
		SELECT sum(incidents_count)::int as total_incidents,
               sum(total_claims)         as total_claims		
		  FROM dm.dm_safety_summary     
		 WHERE date_from = p_date_from
	) 
    SELECT p_date_from
         , p_date_to
         , total_trips 
		 , active_drivers 
		 , active_trucks
         , total_distance_miles
		 , total_fuel_gallons 
		 , total_revenue
		 , total_fuel_cost
         , total_profit
		 , profit_margin_pct 
		 , total_incidents 
		 , total_claims
         , total_maintenance_cost
         , clock_timestamp()
	  FROM wt_driver_performance d 
      LEFT
	  JOIN wt_truck_utilization u 
	    ON 1=1
	  LEFT
	  JOIN wt_route_profitability r 
	    ON 1=1
	  LEFT
	  JOIN wt_safety_summary s 
	    ON 1=1
    ;
    GET DIAGNOSTICS v_rows = ROW_COUNT;
	ANALYZE dm.dm_fleet_kpi;
    RETURN v_rows;
END;
$$;
COMMENT ON FUNCTION dm.fill_dm_fleet_kpi(date, date)
    IS 'Расчёт KPI за месяц.';
