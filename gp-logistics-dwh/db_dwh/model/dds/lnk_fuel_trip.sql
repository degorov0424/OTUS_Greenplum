DROP TABLE IF EXISTS dds.lnk_fuel_trip;
CREATE TABLE dds.lnk_fuel_trip (
    fuel_trip_hk     varchar(32) NOT NULL,
    fuel_purchase_hk   varchar(32) NOT NULL,
    trip_hk            varchar(32) NOT NULL,
    load_date          timestamp   NOT NULL,
    source_name        varchar(50) NOT NULL,
    batch_id           bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (fuel_purchase_hk);
COMMENT ON TABLE  dds.lnk_fuel_trip IS 'Link: Заправка -> Рейс';
COMMENT ON COLUMN dds.lnk_fuel_trip.fuel_trip_hk   IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_fuel_trip.fuel_purchase_hk IS 'Ссылка на hub_fuel_purchase';
COMMENT ON COLUMN dds.lnk_fuel_trip.trip_hk          IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_fuel_trip.load_date        IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_fuel_trip.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_fuel_trip.batch_id         IS 'Тех.поле: батч загрузки';
