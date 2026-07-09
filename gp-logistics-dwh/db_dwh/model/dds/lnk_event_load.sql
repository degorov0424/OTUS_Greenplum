DROP TABLE IF EXISTS dds.lnk_event_load;
CREATE TABLE dds.lnk_event_load (
    event_load_hk     varchar(32) NOT NULL,
    delivery_event_hk   varchar(32) NOT NULL,
    load_hk             varchar(32) NOT NULL,
    load_date           timestamp   NOT NULL,
    source_name         varchar(50) NOT NULL,
    batch_id            bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (delivery_event_hk);
COMMENT ON TABLE  dds.lnk_event_load IS 'Link: Событие доставки -> Заказ';
COMMENT ON COLUMN dds.lnk_event_load.event_load_hk   IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_event_load.delivery_event_hk IS 'Ссылка на hub_delivery_event';
COMMENT ON COLUMN dds.lnk_event_load.load_hk           IS 'Ссылка на hub_load';
COMMENT ON COLUMN dds.lnk_event_load.load_date         IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_event_load.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_event_load.batch_id          IS 'Тех.поле: батч загрузки';
