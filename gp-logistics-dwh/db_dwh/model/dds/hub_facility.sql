DROP TABLE IF EXISTS dds.hub_facility;
CREATE TABLE dds.hub_facility (
    facility_hk varchar(32)  NOT NULL,
    facility_bk varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (facility_hk);
COMMENT ON TABLE  dds.hub_facility IS 'Hub: Объект инфраструктуры';
COMMENT ON COLUMN dds.hub_facility.facility_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_facility.facility_bk IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_facility.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_facility.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_facility.batch_id    IS 'Тех.поле: батч загрузки';
