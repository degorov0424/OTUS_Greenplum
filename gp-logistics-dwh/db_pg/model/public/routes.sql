DROP TABLE IF EXISTS public.routes CASCADE;
CREATE TABLE public.routes (
    route_id               varchar(16)  NOT NULL,
    origin_city            varchar(80),
    origin_state           varchar(10),
    destination_city       varchar(80),
    destination_state      varchar(10),
    typical_distance_miles numeric(10,2),
    base_rate_per_mile     numeric(8,3),
    fuel_surcharge_rate    numeric(8,3),
    typical_transit_days   integer,
    is_deleted              varchar(1),
    created_at             timestamp    NOT NULL DEFAULT now(),
    updated_at             timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_routes PRIMARY KEY (route_id)
);
COMMENT ON TABLE  public.routes IS 'Источник: маршруты';
COMMENT ON COLUMN public.routes.route_id               IS 'Идентификатор маршрута';
COMMENT ON COLUMN public.routes.origin_city            IS 'Город отправления';
COMMENT ON COLUMN public.routes.origin_state           IS 'Штат отправления';
COMMENT ON COLUMN public.routes.destination_city       IS 'Город назначения';
COMMENT ON COLUMN public.routes.destination_state      IS 'Штат назначения';
COMMENT ON COLUMN public.routes.typical_distance_miles IS 'Типовое расстояние, миль';
COMMENT ON COLUMN public.routes.base_rate_per_mile     IS 'Базовый тариф, USD/миля';
COMMENT ON COLUMN public.routes.fuel_surcharge_rate    IS 'Топливная надбавка, USD/миля';
COMMENT ON COLUMN public.routes.typical_transit_days   IS 'Типовое время в пути, дней';
COMMENT ON COLUMN public.routes.created_at             IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.routes.updated_at             IS 'Тех.колонка источника: момент последнего изменения';
