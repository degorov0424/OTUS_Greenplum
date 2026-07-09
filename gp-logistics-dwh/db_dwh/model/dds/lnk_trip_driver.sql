DROP TABLE IF EXISTS dds.lnk_trip_driver;
CREATE TABLE dds.lnk_trip_driver (
    trip_driver_hk varchar(32) NOT NULL,
    trip_hk          varchar(32) NOT NULL,
    driver_hk        varchar(32) NOT NULL,
    load_date        timestamp   NOT NULL,
    source_name      varchar(50) NOT NULL,
    batch_id         bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE  dds.lnk_trip_driver IS 'Link: Рейс -> Водитель';
COMMENT ON COLUMN dds.lnk_trip_driver.trip_driver_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_trip_driver.trip_hk          IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_trip_driver.driver_hk        IS 'Ссылка на hub_driver';
COMMENT ON COLUMN dds.lnk_trip_driver.load_date        IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_trip_driver.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_trip_driver.batch_id         IS 'Тех.поле: батч загрузки';
