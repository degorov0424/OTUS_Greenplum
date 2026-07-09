DROP TABLE IF EXISTS dds.sat_fuel_purchase_details;
CREATE TABLE dds.sat_fuel_purchase_details (
    fuel_purchase_hk varchar(32)  NOT NULL,
    load_date        timestamp    NOT NULL,
    source_name      varchar(50)  NOT NULL,
    batch_id         bigint,
    hash_diff        varchar(32)  NOT NULL,
    purchase_date    timestamp,
    location_city    varchar(80),
    location_state   varchar(10),
    gallons          numeric(10,2),
    price_per_gallon numeric(8,3),
    total_cost       numeric(14,2),
    fuel_card_number varchar(30)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (fuel_purchase_hk)
PARTITION BY RANGE (purchase_date)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_fuel_purchase_details IS 'Satellite: метрики заправки';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.fuel_purchase_hk IS 'Ссылка на hub_fuel_purchase';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.load_date        IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.batch_id         IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.hash_diff        IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.purchase_date    IS 'Дата/время заправки';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.location_city    IS 'Город заправки';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.location_state   IS 'Штат заправки';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.gallons          IS 'Объём, галлон';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.price_per_gallon IS 'Цена за галлон, USD';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.total_cost       IS 'Стоимость, USD';
COMMENT ON COLUMN dds.sat_fuel_purchase_details.fuel_card_number IS 'Номер топливной карты';
