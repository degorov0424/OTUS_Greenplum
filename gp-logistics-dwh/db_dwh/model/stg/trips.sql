DROP TABLE IF EXISTS stg.trips;
CREATE TABLE stg.trips (
    trip_id               varchar(20)  NOT NULL,
    load_id               varchar(20),
    driver_id             varchar(16),
    truck_id              varchar(16),
    trailer_id            varchar(16),
    dispatch_date         date,
    actual_distance_miles numeric(10,2),
    actual_duration_hours numeric(8,2),
    fuel_gallons_used     numeric(10,2),
    average_mpg           numeric(6,2),
    idle_time_hours       numeric(8,2),
    trip_status           varchar(30),
    is_deleted              varchar(1),
    load_date             timestamp    NOT NULL DEFAULT now(),
    source_name           varchar(255),
    batch_id              bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_id)
PARTITION BY RANGE (dispatch_date)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.trips IS 'Stage: рейсы';
COMMENT ON COLUMN stg.trips.trip_id               IS 'Идентификатор рейса';
COMMENT ON COLUMN stg.trips.load_id               IS 'Заказ';
COMMENT ON COLUMN stg.trips.driver_id             IS 'Водитель';
COMMENT ON COLUMN stg.trips.truck_id              IS 'Грузовик';
COMMENT ON COLUMN stg.trips.trailer_id            IS 'Прицеп';
COMMENT ON COLUMN stg.trips.dispatch_date         IS 'Дата отправки';
COMMENT ON COLUMN stg.trips.actual_distance_miles IS 'Фактическое расстояние, миль';
COMMENT ON COLUMN stg.trips.actual_duration_hours IS 'Фактическая длительность, часов';
COMMENT ON COLUMN stg.trips.fuel_gallons_used     IS 'Расход топлива, галлон';
COMMENT ON COLUMN stg.trips.average_mpg           IS 'Средний расход, миль/галлон';
COMMENT ON COLUMN stg.trips.idle_time_hours       IS 'Время холостого хода, часов';
COMMENT ON COLUMN stg.trips.trip_status           IS 'Статус рейса';
COMMENT ON COLUMN stg.trips.load_date             IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.trips.source_name           IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.trips.batch_id              IS 'Тех.поле: идентификатор батча';
