DROP TABLE IF EXISTS dds.lnk_trip_trailer;
CREATE TABLE dds.lnk_trip_trailer (
    trip_trailer_hk varchar(32) NOT NULL,
    trip_hk           varchar(32) NOT NULL,
    trailer_hk        varchar(32) NOT NULL,
    load_date         timestamp   NOT NULL,
    source_name       varchar(50) NOT NULL,
    batch_id          bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE  dds.lnk_trip_trailer IS 'Link: Рейс -> Прицеп';
COMMENT ON COLUMN dds.lnk_trip_trailer.trip_trailer_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_trip_trailer.trip_hk           IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_trip_trailer.trailer_hk        IS 'Ссылка на hub_trailer';
COMMENT ON COLUMN dds.lnk_trip_trailer.load_date         IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_trip_trailer.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_trip_trailer.batch_id          IS 'Тех.поле: батч загрузки';
