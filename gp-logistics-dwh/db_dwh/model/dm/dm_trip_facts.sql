DROP TABLE IF EXISTS dm.dm_trip_facts;
CREATE TABLE dm.dm_trip_facts (
    trip_hk               varchar(32)  NOT NULL,
    trip_bk               varchar(20)  NOT NULL,
    dispatch_date         date,
    driver_hk             varchar(32),
    driver_name           varchar(121),
    truck_hk              varchar(32),
    truck_bk              varchar(16),
    make                  varchar(50),
    load_hk               varchar(32),
    load_bk               varchar(20),
    route_hk              varchar(32),
    route_name            varchar(170),
    customer_hk           varchar(32),
    customer_name         varchar(150),
    actual_distance_miles numeric(10,2),
    actual_duration_hours numeric(8,2),
    fuel_gallons_used     numeric(10,2),
    average_mpg           numeric(6,2),
    idle_time_hours       numeric(8,2),
    trip_status           varchar(30),
    revenue               numeric(14,2),
    date_from             date         NOT NULL,
    date_to               date         NOT NULL,
    load_date             timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );

COMMENT ON TABLE dm.dm_trip_facts IS 'Факт-витрина: выполненные рейсы за период';
