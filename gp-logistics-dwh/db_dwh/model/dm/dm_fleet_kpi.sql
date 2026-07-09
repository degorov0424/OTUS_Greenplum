DROP TABLE IF EXISTS dm.dm_fleet_kpi;
CREATE TABLE dm.dm_fleet_kpi (
    date_from               date         NOT NULL,
    date_to                 date         NOT NULL,
    total_trips             integer,
    active_drivers          integer,
    active_trucks           integer,
    total_distance_miles    numeric(18,2),
    total_fuel_gallons     numeric(18,2),
    total_revenue           numeric(18,2),
    total_fuel_cost         numeric(18,2),
    total_profit            numeric(18,2),
    profit_margin_pct       numeric(7,2),
    total_incidents         integer,
    total_claims            numeric(18,2),
    total_maintenance_cost  numeric(18,2),
    load_date               timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );

COMMENT ON TABLE dm.dm_fleet_kpi IS 'KPI по парку';
