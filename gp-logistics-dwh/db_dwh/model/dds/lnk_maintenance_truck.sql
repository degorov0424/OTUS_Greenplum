DROP TABLE IF EXISTS dds.lnk_maintenance_truck;
CREATE TABLE dds.lnk_maintenance_truck (
    maintenance_truck_hk varchar(32) NOT NULL,
    maintenance_hk         varchar(32) NOT NULL,
    truck_hk               varchar(32) NOT NULL,
    load_date              timestamp   NOT NULL,
    source_name            varchar(50) NOT NULL,
    batch_id               bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (maintenance_hk);
COMMENT ON TABLE  dds.lnk_maintenance_truck IS 'Link: Ремонт -> Грузовик';
COMMENT ON COLUMN dds.lnk_maintenance_truck.maintenance_truck_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_maintenance_truck.maintenance_hk         IS 'Ссылка на hub_maintenance';
COMMENT ON COLUMN dds.lnk_maintenance_truck.truck_hk               IS 'Ссылка на hub_truck';
COMMENT ON COLUMN dds.lnk_maintenance_truck.load_date              IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_maintenance_truck.source_name            IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_maintenance_truck.batch_id               IS 'Тех.поле: батч загрузки';
