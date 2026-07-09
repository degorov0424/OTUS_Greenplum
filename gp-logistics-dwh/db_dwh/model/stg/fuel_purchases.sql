DROP TABLE IF EXISTS stg.fuel_purchases;
CREATE TABLE stg.fuel_purchases (
    fuel_purchase_id varchar(20)  NOT NULL,
    trip_id          varchar(20),
    truck_id         varchar(16),
    driver_id        varchar(16),
    purchase_date    timestamp,
    location_city    varchar(80),
    location_state   varchar(10),
    gallons          numeric(10,2),
    price_per_gallon numeric(8,3),
    total_cost       numeric(14,2),
    fuel_card_number varchar(30),
    is_deleted              varchar(1),
    load_date        timestamp    NOT NULL DEFAULT now(),
    source_name      varchar(255),
    batch_id         bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (fuel_purchase_id)
PARTITION BY RANGE (purchase_date)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.fuel_purchases IS 'Stage: заправки';
COMMENT ON COLUMN stg.fuel_purchases.fuel_purchase_id IS 'Идентификатор заправки (бизнес-ключ)';
COMMENT ON COLUMN stg.fuel_purchases.trip_id          IS 'Рейс';
COMMENT ON COLUMN stg.fuel_purchases.truck_id         IS 'Грузовик';
COMMENT ON COLUMN stg.fuel_purchases.driver_id        IS 'Водитель';
COMMENT ON COLUMN stg.fuel_purchases.purchase_date    IS 'Дата/время заправки';
COMMENT ON COLUMN stg.fuel_purchases.location_city    IS 'Город заправки';
COMMENT ON COLUMN stg.fuel_purchases.location_state   IS 'Штат заправки';
COMMENT ON COLUMN stg.fuel_purchases.gallons          IS 'Объём, галлон';
COMMENT ON COLUMN stg.fuel_purchases.price_per_gallon IS 'Цена за галлон, USD';
COMMENT ON COLUMN stg.fuel_purchases.total_cost       IS 'Стоимость, USD';
COMMENT ON COLUMN stg.fuel_purchases.fuel_card_number IS 'Номер топливной карты';
COMMENT ON COLUMN stg.fuel_purchases.load_date        IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.fuel_purchases.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.fuel_purchases.batch_id         IS 'Тех.поле: идентификатор батча';
