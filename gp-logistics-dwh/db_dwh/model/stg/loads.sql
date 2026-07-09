DROP TABLE IF EXISTS stg.loads;
CREATE TABLE stg.loads (
    load_id             varchar(20)  NOT NULL,
    customer_id         varchar(16),
    route_id            varchar(16),
    load_date_value     date,
    load_type           varchar(40),
    weight_lbs          numeric(12,2),
    pieces              integer,
    revenue             numeric(14,2),
    fuel_surcharge      numeric(14,2),
    accessorial_charges numeric(14,2),
    load_status         varchar(30),
    booking_type        varchar(30),
    is_deleted              varchar(1),
    load_date           timestamp    NOT NULL DEFAULT now(),
    source_name         varchar(255),
    batch_id            bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (load_id)
PARTITION BY RANGE (load_date_value)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.loads IS 'Stage: заказы';
COMMENT ON COLUMN stg.loads.load_id             IS 'Идентификатор заказа';
COMMENT ON COLUMN stg.loads.customer_id         IS 'Клиент';
COMMENT ON COLUMN stg.loads.route_id            IS 'Маршрут';
COMMENT ON COLUMN stg.loads.load_date_value     IS 'Бизнес-дата заказа';
COMMENT ON COLUMN stg.loads.load_type           IS 'Тип груза';
COMMENT ON COLUMN stg.loads.weight_lbs          IS 'Вес, фунтов';
COMMENT ON COLUMN stg.loads.pieces              IS 'Число мест';
COMMENT ON COLUMN stg.loads.revenue             IS 'Выручка, USD';
COMMENT ON COLUMN stg.loads.fuel_surcharge      IS 'Топливная надбавка, USD';
COMMENT ON COLUMN stg.loads.accessorial_charges IS 'Доп. сборы, USD';
COMMENT ON COLUMN stg.loads.load_status         IS 'Статус заказа';
COMMENT ON COLUMN stg.loads.booking_type        IS 'Тип бронирования';
COMMENT ON COLUMN stg.loads.load_date           IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.loads.source_name         IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.loads.batch_id            IS 'Тех.поле: идентификатор батча';
