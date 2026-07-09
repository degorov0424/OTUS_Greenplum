DROP TABLE IF EXISTS dds.hub_fuel_purchase;
CREATE TABLE dds.hub_fuel_purchase (
    fuel_purchase_hk varchar(32)  NOT NULL,
    fuel_purchase_bk varchar(20)  NOT NULL,
    load_date        timestamp    NOT NULL,
    source_name      varchar(50)  NOT NULL,
    batch_id         bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (fuel_purchase_hk);
COMMENT ON TABLE  dds.hub_fuel_purchase IS 'Hub: Заправка';
COMMENT ON COLUMN dds.hub_fuel_purchase.fuel_purchase_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_fuel_purchase.fuel_purchase_bk IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_fuel_purchase.load_date        IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_fuel_purchase.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_fuel_purchase.batch_id         IS 'Тех.поле: батч загрузки';
