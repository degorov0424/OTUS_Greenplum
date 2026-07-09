DROP TABLE IF EXISTS dds.hub_maintenance;
CREATE TABLE dds.hub_maintenance (
    maintenance_hk varchar(32)  NOT NULL,
    maintenance_bk varchar(20)  NOT NULL,
    load_date      timestamp    NOT NULL,
    source_name    varchar(50)  NOT NULL,
    batch_id       bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (maintenance_hk);
COMMENT ON TABLE  dds.hub_maintenance IS 'Hub: ТО/ремонт';
COMMENT ON COLUMN dds.hub_maintenance.maintenance_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_maintenance.maintenance_bk IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_maintenance.load_date      IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_maintenance.source_name    IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_maintenance.batch_id       IS 'Тех.поле: батч загрузки';
