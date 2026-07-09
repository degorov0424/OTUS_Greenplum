DROP TABLE IF EXISTS stg.delivery_events;
CREATE TABLE stg.delivery_events (
    event_id           varchar(20)  NOT NULL,
    load_id            varchar(20),
    trip_id            varchar(20),
    event_type         varchar(40),
    facility_id        varchar(16),
    scheduled_datetime timestamp,
    actual_datetime    timestamp,
    detention_minutes  integer,
    on_time_flag       boolean,
    location_city      varchar(80),
    location_state     varchar(10),
    is_deleted              varchar(1),
    load_date          timestamp    NOT NULL DEFAULT now(),
    source_name        varchar(255),
    batch_id           bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (event_id)
PARTITION BY RANGE (actual_datetime)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.delivery_events IS 'Stage: события доставки ';
COMMENT ON COLUMN stg.delivery_events.event_id           IS 'Идентификатор события (бизнес-ключ)';
COMMENT ON COLUMN stg.delivery_events.load_id            IS 'Заказ';
COMMENT ON COLUMN stg.delivery_events.trip_id            IS 'Рейс';
COMMENT ON COLUMN stg.delivery_events.event_type         IS 'Тип события (Pickup/Delivery/…)';
COMMENT ON COLUMN stg.delivery_events.facility_id        IS 'Объект (ссылка)';
COMMENT ON COLUMN stg.delivery_events.scheduled_datetime IS 'Плановые дата/время';
COMMENT ON COLUMN stg.delivery_events.actual_datetime    IS 'Фактические дата/время';
COMMENT ON COLUMN stg.delivery_events.detention_minutes  IS 'Простой, минут';
COMMENT ON COLUMN stg.delivery_events.on_time_flag       IS 'Признак "вовремя"';
COMMENT ON COLUMN stg.delivery_events.location_city      IS 'Город события';
COMMENT ON COLUMN stg.delivery_events.location_state     IS 'Штат события';
COMMENT ON COLUMN stg.delivery_events.load_date          IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.delivery_events.source_name        IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.delivery_events.batch_id           IS 'Тех.поле: идентификатор батча';
