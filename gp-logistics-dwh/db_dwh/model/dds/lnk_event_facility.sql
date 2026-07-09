DROP TABLE IF EXISTS dds.lnk_event_facility;
CREATE TABLE dds.lnk_event_facility (
    event_facility_hk varchar(32) NOT NULL,
    delivery_event_hk   varchar(32) NOT NULL,
    facility_hk         varchar(32) NOT NULL,
    load_date           timestamp   NOT NULL,
    source_name         varchar(50) NOT NULL,
    batch_id            bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (delivery_event_hk);
COMMENT ON TABLE  dds.lnk_event_facility IS 'Link: Событие доставки -> Объект';
COMMENT ON COLUMN dds.lnk_event_facility.event_facility_hk IS 'Хеш-ключ линк';
COMMENT ON COLUMN dds.lnk_event_facility.delivery_event_hk   IS 'Ссылка на hub_delivery_event';
COMMENT ON COLUMN dds.lnk_event_facility.facility_hk         IS 'Ссылка на hub_facility';
COMMENT ON COLUMN dds.lnk_event_facility.load_date           IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_event_facility.source_name         IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_event_facility.batch_id            IS 'Тех.поле: батч загрузки';
