DROP TABLE IF EXISTS dds.hub_delivery_event;
CREATE TABLE dds.hub_delivery_event (
    delivery_event_hk varchar(32)  NOT NULL,
    delivery_event_bk varchar(20)  NOT NULL,
    load_date         timestamp    NOT NULL,
    source_name       varchar(50)  NOT NULL,
    batch_id          bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (delivery_event_hk);
COMMENT ON TABLE  dds.hub_delivery_event IS 'Hub: Событие доставки';
COMMENT ON COLUMN dds.hub_delivery_event.delivery_event_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_delivery_event.delivery_event_bk IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_delivery_event.load_date         IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_delivery_event.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_delivery_event.batch_id          IS 'Тех.поле: батч загрузки';
