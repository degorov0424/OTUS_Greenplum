DROP TABLE IF EXISTS dds.sat_trip_details;
CREATE TABLE dds.sat_trip_details (
    trip_hk            varchar(32)  NOT NULL,
    load_date          timestamp    NOT NULL,
    source_name        varchar(50)  NOT NULL,
    batch_id           bigint,
    hash_diff          varchar(32)  NOT NULL,
    dispatch_date      date,
    actual_distance_miles numeric(10,2),
    actual_duration_hours numeric(8,2),
    fuel_gallons_used  numeric(10,2),
    average_mpg        numeric(6,2),
    idle_time_hours    numeric(8,2),
    trip_status        varchar(30)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk)
PARTITION BY RANGE (dispatch_date)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_trip_details IS 'Satellite: метрики рейса';
COMMENT ON COLUMN dds.sat_trip_details.trip_hk            IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.sat_trip_details.load_date          IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_trip_details.source_name        IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_trip_details.batch_id           IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_trip_details.hash_diff          IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_trip_details.dispatch_date      IS 'Дата отправки';
COMMENT ON COLUMN dds.sat_trip_details.actual_distance_miles IS 'Фактическое расстояние, миль';
COMMENT ON COLUMN dds.sat_trip_details.actual_duration_hours IS 'Фактическая длительность, часов';
COMMENT ON COLUMN dds.sat_trip_details.fuel_gallons_used  IS 'Расход топлива, галлон';
COMMENT ON COLUMN dds.sat_trip_details.average_mpg        IS 'Средний расход, миль/галлон';
COMMENT ON COLUMN dds.sat_trip_details.idle_time_hours    IS 'Время холостого хода, часов';
COMMENT ON COLUMN dds.sat_trip_details.trip_status        IS 'Статус рейса';
