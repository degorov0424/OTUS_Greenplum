DROP TABLE IF EXISTS public.loads CASCADE;
CREATE TABLE public.loads (
    load_id             varchar(20)  NOT NULL,
    customer_id         varchar(16),
    route_id            varchar(16),
    load_date           date,
    load_type           varchar(40),
    weight_lbs          numeric(12,2),
    pieces              integer,
    revenue             numeric(14,2),
    fuel_surcharge      numeric(14,2),
    accessorial_charges numeric(14,2),
    load_status         varchar(30),
    booking_type        varchar(30),
    is_deleted              varchar(1),
    created_at          timestamp    NOT NULL DEFAULT now(),
    updated_at          timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_loads PRIMARY KEY (load_id),
    CONSTRAINT fk_loads_customer FOREIGN KEY (customer_id)
        REFERENCES public.customers (customer_id),
    CONSTRAINT fk_loads_route FOREIGN KEY (route_id)
        REFERENCES public.routes (route_id)
);
COMMENT ON TABLE  public.loads IS 'Источник: заказы/закладки груза';
COMMENT ON COLUMN public.loads.load_id             IS 'Идентификатор заказа';
COMMENT ON COLUMN public.loads.customer_id         IS 'Клиент';
COMMENT ON COLUMN public.loads.route_id            IS 'Маршрут';
COMMENT ON COLUMN public.loads.load_date           IS 'Бизнес-дата заказа';
COMMENT ON COLUMN public.loads.load_type           IS 'Тип груза';
COMMENT ON COLUMN public.loads.weight_lbs          IS 'Вес, фунтов';
COMMENT ON COLUMN public.loads.pieces              IS 'Число мест';
COMMENT ON COLUMN public.loads.revenue             IS 'Выручка, USD';
COMMENT ON COLUMN public.loads.fuel_surcharge      IS 'Топливная надбавка, USD';
COMMENT ON COLUMN public.loads.accessorial_charges IS 'Доп. сборы, USD';
COMMENT ON COLUMN public.loads.load_status         IS 'Статус заказа (Completed/…)';
COMMENT ON COLUMN public.loads.booking_type        IS 'Тип бронирования (Spot/Contract/…)';
COMMENT ON COLUMN public.loads.created_at          IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.loads.updated_at          IS 'Тех.колонка источника: момент последнего изменения';

