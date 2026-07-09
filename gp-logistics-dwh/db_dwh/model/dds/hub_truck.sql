DROP TABLE IF EXISTS dds.hub_truck;
CREATE TABLE dds.hub_truck (
    truck_hk    varchar(32)  NOT NULL,
    truck_bk    varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (truck_hk);
COMMENT ON TABLE  dds.hub_truck IS 'Hub: Грузовик';
COMMENT ON COLUMN dds.hub_truck.truck_hk    IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_truck.truck_bk    IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_truck.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_truck.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_truck.batch_id    IS 'Тех.поле: батч загрузки';
