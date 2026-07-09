DROP TABLE IF EXISTS dds.hub_load;
CREATE TABLE dds.hub_load (
    load_hk     varchar(32)  NOT NULL,
    load_bk     varchar(20)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (load_hk);
COMMENT ON TABLE  dds.hub_load IS 'Hub: Заказ';
COMMENT ON COLUMN dds.hub_load.load_hk     IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_load.load_bk     IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_load.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_load.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_load.batch_id    IS 'Тех.поле: батч загрузки';
