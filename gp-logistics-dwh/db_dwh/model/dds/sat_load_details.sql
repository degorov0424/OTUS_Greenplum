DROP TABLE IF EXISTS dds.sat_load_details;
CREATE TABLE dds.sat_load_details (
    load_hk           varchar(32)  NOT NULL,
    load_date         timestamp    NOT NULL,
    source_name       varchar(50)  NOT NULL,
    batch_id          bigint,
    hash_diff         varchar(32)  NOT NULL,
    load_date_value   date,
    load_type         varchar(40),
    weight_lbs        numeric(12,2),
    pieces            integer,
    revenue           numeric(14,2),
    fuel_surcharge    numeric(14,2),
    accessorial_charges numeric(14,2),
    load_status       varchar(30),
    booking_type      varchar(30)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (load_hk)
PARTITION BY RANGE (load_date_value)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_load_details IS 'Satellite: атрибуты заказа';
COMMENT ON COLUMN dds.sat_load_details.load_hk           IS 'Ссылка на hub_load';
COMMENT ON COLUMN dds.sat_load_details.load_date         IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_load_details.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_load_details.batch_id          IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_load_details.hash_diff         IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_load_details.load_date_value   IS 'Бизнес-дата заказа';
COMMENT ON COLUMN dds.sat_load_details.load_type         IS 'Тип груза';
COMMENT ON COLUMN dds.sat_load_details.weight_lbs        IS 'Вес, фунтов';
COMMENT ON COLUMN dds.sat_load_details.pieces            IS 'Число мест';
COMMENT ON COLUMN dds.sat_load_details.revenue           IS 'Выручка, USD';
COMMENT ON COLUMN dds.sat_load_details.fuel_surcharge    IS 'Топливная надбавка, USD';
COMMENT ON COLUMN dds.sat_load_details.accessorial_charges IS 'Доп. сборы, USD';
COMMENT ON COLUMN dds.sat_load_details.load_status       IS 'Статус заказа';
COMMENT ON COLUMN dds.sat_load_details.booking_type      IS 'Тип бронирования';
