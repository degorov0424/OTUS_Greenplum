DROP TABLE IF EXISTS dds.hub_driver;
CREATE TABLE dds.hub_driver (
    driver_hk   varchar(32)  NOT NULL,
    driver_bk   varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (driver_hk);
COMMENT ON TABLE  dds.hub_driver IS 'Hub: Водитель';
COMMENT ON COLUMN dds.hub_driver.driver_hk   IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_driver.driver_bk   IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_driver.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_driver.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_driver.batch_id    IS 'Тех.поле: батч загрузки';
