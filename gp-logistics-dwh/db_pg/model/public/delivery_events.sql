DROP TABLE IF EXISTS public.delivery_events CASCADE;
CREATE TABLE public.delivery_events (
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
    created_at         timestamp    NOT NULL DEFAULT now(),
    updated_at         timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_delivery_events PRIMARY KEY (event_id),
    CONSTRAINT fk_delivery_events_load     FOREIGN KEY (load_id)
        REFERENCES public.loads (load_id),
    CONSTRAINT fk_delivery_events_trip     FOREIGN KEY (trip_id)
        REFERENCES public.trips (trip_id),
    CONSTRAINT fk_delivery_events_facility FOREIGN KEY (facility_id)
        REFERENCES public.facilities (facility_id)
);
COMMENT ON TABLE  public.delivery_events IS 'Источник: события доставки';
COMMENT ON COLUMN public.delivery_events.event_id           IS 'Идентификатор события (бизнес-ключ)';
COMMENT ON COLUMN public.delivery_events.load_id            IS 'Заказ';
COMMENT ON COLUMN public.delivery_events.trip_id            IS 'Рейс';
COMMENT ON COLUMN public.delivery_events.event_type         IS 'Тип события (Pickup/Delivery/…)';
COMMENT ON COLUMN public.delivery_events.facility_id        IS 'Объект';
COMMENT ON COLUMN public.delivery_events.scheduled_datetime IS 'Плановые дата/время';
COMMENT ON COLUMN public.delivery_events.actual_datetime    IS 'Фактические дата/время';
COMMENT ON COLUMN public.delivery_events.detention_minutes  IS 'Простой, минут';
COMMENT ON COLUMN public.delivery_events.on_time_flag       IS 'Признак "вовремя"';
COMMENT ON COLUMN public.delivery_events.location_city      IS 'Город события';
COMMENT ON COLUMN public.delivery_events.location_state     IS 'Штат события';
COMMENT ON COLUMN public.delivery_events.created_at         IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.delivery_events.updated_at         IS 'Тех.колонка источника: момент последнего изменения';
