DROP TABLE IF EXISTS public.trips CASCADE;
CREATE TABLE public.trips (
    trip_id               varchar(20)  NOT NULL,
    load_id               varchar(20),
    driver_id             varchar(16),
    truck_id              varchar(16),
    trailer_id            varchar(16),
    dispatch_date         date,
    actual_distance_miles numeric(10,2),
    actual_duration_hours numeric(8,2),
    fuel_gallons_used     numeric(10,2),
    average_mpg           numeric(6,2),
    idle_time_hours       numeric(8,2),
    trip_status           varchar(30),
    is_deleted              varchar(1),
    created_at            timestamp    NOT NULL DEFAULT now(),
    updated_at            timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_trips PRIMARY KEY (trip_id),
    CONSTRAINT fk_trips_load    FOREIGN KEY (load_id)
        REFERENCES public.loads (load_id),
    CONSTRAINT fk_trips_driver  FOREIGN KEY (driver_id)
        REFERENCES public.drivers (driver_id),
    CONSTRAINT fk_trips_truck   FOREIGN KEY (truck_id)
        REFERENCES public.trucks (truck_id),
    CONSTRAINT fk_trips_trailer FOREIGN KEY (trailer_id)
        REFERENCES public.trailers (trailer_id)
);
COMMENT ON TABLE  public.trips IS 'Источник: рейсы';
COMMENT ON COLUMN public.trips.trip_id               IS 'Идентификатор рейса';
COMMENT ON COLUMN public.trips.load_id               IS 'Заказ';
COMMENT ON COLUMN public.trips.driver_id             IS 'Водитель';
COMMENT ON COLUMN public.trips.truck_id              IS 'Грузовик';
COMMENT ON COLUMN public.trips.trailer_id            IS 'Прицеп';
COMMENT ON COLUMN public.trips.dispatch_date         IS 'Дата отправки';
COMMENT ON COLUMN public.trips.actual_distance_miles IS 'Фактическое расстояние, миль';
COMMENT ON COLUMN public.trips.actual_duration_hours IS 'Фактическая длительность, часов';
COMMENT ON COLUMN public.trips.fuel_gallons_used     IS 'Расход топлива, галлон';
COMMENT ON COLUMN public.trips.average_mpg           IS 'Средний расход, миль/галлон';
COMMENT ON COLUMN public.trips.idle_time_hours       IS 'Время холостого хода, часов';
COMMENT ON COLUMN public.trips.trip_status           IS 'Статус рейса';
COMMENT ON COLUMN public.trips.created_at            IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.trips.updated_at            IS 'Тех.колонка источника: момент последнего изменения';
