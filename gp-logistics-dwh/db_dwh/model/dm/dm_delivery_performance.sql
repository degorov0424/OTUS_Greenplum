DROP TABLE IF EXISTS dm.dm_delivery_performance;
CREATE TABLE dm.dm_delivery_performance (
    route_hk             varchar(32)  NOT NULL,
    route_bk             varchar(16)  NOT NULL,
    origin_city          varchar(80),
    destination_city     varchar(80),
    total_events         integer,
    pickup_count         integer,
    delivery_count       integer,
    on_time_count        integer,
    on_time_pct          numeric(6,2),
    avg_detention_minutes numeric(10,2),
    date_from            date         NOT NULL,
    date_to              date         NOT NULL,
    load_date            timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dm.dm_delivery_performance IS 'Витрина: доставки по маршруту';
COMMENT ON COLUMN dm.dm_delivery_performance.route_hk              IS 'Ключ';
COMMENT ON COLUMN dm.dm_delivery_performance.route_bk              IS 'Бизнес-ключ';
COMMENT ON COLUMN dm.dm_delivery_performance.origin_city           IS 'Город отправления';
COMMENT ON COLUMN dm.dm_delivery_performance.destination_city      IS 'Город назначения';
COMMENT ON COLUMN dm.dm_delivery_performance.total_events          IS 'Всего событий доставки за период';
COMMENT ON COLUMN dm.dm_delivery_performance.pickup_count          IS 'Событий Pickup за период';
COMMENT ON COLUMN dm.dm_delivery_performance.delivery_count        IS 'Событий Delivery за период';
COMMENT ON COLUMN dm.dm_delivery_performance.on_time_count         IS 'Своевременных событий за период';
COMMENT ON COLUMN dm.dm_delivery_performance.on_time_pct           IS 'Доля своевременных, %';
COMMENT ON COLUMN dm.dm_delivery_performance.avg_detention_minutes IS 'Средний простой, минут';
COMMENT ON COLUMN dm.dm_delivery_performance.date_from             IS 'Начало периода';
COMMENT ON COLUMN dm.dm_delivery_performance.date_to               IS 'Конец периода';
COMMENT ON COLUMN dm.dm_delivery_performance.load_date             IS 'Тех.поле: момент пересчёта витрины';
