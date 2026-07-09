DROP TABLE IF EXISTS dds.hub_trip;
CREATE TABLE dds.hub_trip (
    trip_hk     varchar(32)  NOT NULL,
    trip_bk     varchar(20)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE  dds.hub_trip IS 'Hub: Рейс';
COMMENT ON COLUMN dds.hub_trip.trip_hk     IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_trip.trip_bk     IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_trip.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_trip.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_trip.batch_id    IS 'Тех.поле: батч загрузки';
