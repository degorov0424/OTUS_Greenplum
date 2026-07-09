DROP TABLE IF EXISTS dds.sat_delivery_event_details;
CREATE TABLE dds.sat_delivery_event_details (
    delivery_event_hk varchar(32)  NOT NULL,
    load_date         timestamp    NOT NULL,
    source_name       varchar(50)  NOT NULL,
    batch_id          bigint,
    hash_diff         varchar(32)  NOT NULL,
    event_type        varchar(40),
    facility_id_raw   varchar(16),
    scheduled_datetime timestamp,
    actual_datetime   timestamp,
    detention_minutes integer,
    on_time_flag      boolean,
    location_city     varchar(80),
    location_state    varchar(10)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (delivery_event_hk)
PARTITION BY RANGE (actual_datetime)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_delivery_event_details IS 'Satellite: атрибуты события доставки';
COMMENT ON COLUMN dds.sat_delivery_event_details.delivery_event_hk IS 'Ссылка на hub_delivery_event';
COMMENT ON COLUMN dds.sat_delivery_event_details.load_date         IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_delivery_event_details.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_delivery_event_details.batch_id          IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_delivery_event_details.hash_diff         IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_delivery_event_details.event_type        IS 'Тип события (Pickup/Delivery/…)';
COMMENT ON COLUMN dds.sat_delivery_event_details.facility_id_raw   IS 'facility_id из источника';
COMMENT ON COLUMN dds.sat_delivery_event_details.scheduled_datetime IS 'Плановые дата/время';
COMMENT ON COLUMN dds.sat_delivery_event_details.actual_datetime   IS 'Фактические дата/время';
COMMENT ON COLUMN dds.sat_delivery_event_details.detention_minutes IS 'Простой, минут';
COMMENT ON COLUMN dds.sat_delivery_event_details.on_time_flag      IS 'Признак "вовремя"';
COMMENT ON COLUMN dds.sat_delivery_event_details.location_city     IS 'Город события';
COMMENT ON COLUMN dds.sat_delivery_event_details.location_state    IS 'Штат события';
