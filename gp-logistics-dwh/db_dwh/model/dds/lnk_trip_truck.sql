DROP TABLE IF EXISTS dds.lnk_trip_truck;
CREATE TABLE dds.lnk_trip_truck (
    trip_truck_hk varchar(32) NOT NULL,
    trip_hk         varchar(32) NOT NULL,
    truck_hk        varchar(32) NOT NULL,
    load_date       timestamp   NOT NULL,
    source_name     varchar(50) NOT NULL,
    batch_id        bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE  dds.lnk_trip_truck IS 'Link: Рейс -> Грузовик';
COMMENT ON COLUMN dds.lnk_trip_truck.trip_truck_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_trip_truck.trip_hk         IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_trip_truck.truck_hk        IS 'Ссылка на hub_truck';
COMMENT ON COLUMN dds.lnk_trip_truck.load_date       IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_trip_truck.source_name     IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_trip_truck.batch_id        IS 'Тех.поле: батч загрузки';
