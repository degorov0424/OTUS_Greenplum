DROP TABLE IF EXISTS dds.lnk_trip_load;
CREATE TABLE dds.lnk_trip_load (
    trip_load_hk varchar(32) NOT NULL,
    trip_hk        varchar(32) NOT NULL,
    load_hk        varchar(32) NOT NULL,
    load_date      timestamp   NOT NULL,
    source_name    varchar(50) NOT NULL,
    batch_id       bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE  dds.lnk_trip_load IS 'Link: Рейс -> Заказ';
COMMENT ON COLUMN dds.lnk_trip_load.trip_load_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_trip_load.trip_hk        IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_trip_load.load_hk        IS 'Ссылка на hub_load';
COMMENT ON COLUMN dds.lnk_trip_load.load_date      IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_trip_load.source_name    IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_trip_load.batch_id       IS 'Тех.поле: батч загрузки';
