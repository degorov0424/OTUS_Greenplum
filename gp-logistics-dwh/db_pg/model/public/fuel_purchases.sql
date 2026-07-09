DROP TABLE IF EXISTS public.fuel_purchases CASCADE;
CREATE TABLE public.fuel_purchases (
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
    created_at       timestamp    NOT NULL DEFAULT now(),
    updated_at       timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_fuel_purchases PRIMARY KEY (fuel_purchase_id),
    CONSTRAINT fk_fuel_purchases_trip   FOREIGN KEY (trip_id)
        REFERENCES public.trips (trip_id),
    CONSTRAINT fk_fuel_purchases_truck   FOREIGN KEY (truck_id)
        REFERENCES public.trucks (truck_id),
    CONSTRAINT fk_fuel_purchases_driver  FOREIGN KEY (driver_id)
        REFERENCES public.drivers (driver_id)
);
COMMENT ON TABLE  public.fuel_purchases IS 'Источник: заправки ';
COMMENT ON COLUMN public.fuel_purchases.fuel_purchase_id IS 'Идентификатор заправки (бизнес-ключ)';
COMMENT ON COLUMN public.fuel_purchases.trip_id          IS 'Рейс';
COMMENT ON COLUMN public.fuel_purchases.truck_id         IS 'Грузовик';
COMMENT ON COLUMN public.fuel_purchases.driver_id        IS 'Водитель';
COMMENT ON COLUMN public.fuel_purchases.purchase_date    IS 'Дата/время заправки';
COMMENT ON COLUMN public.fuel_purchases.location_city    IS 'Город заправки';
COMMENT ON COLUMN public.fuel_purchases.location_state   IS 'Штат заправки';
COMMENT ON COLUMN public.fuel_purchases.gallons          IS 'Объём, галлон';
COMMENT ON COLUMN public.fuel_purchases.price_per_gallon IS 'Цена за галлон, USD';
COMMENT ON COLUMN public.fuel_purchases.total_cost       IS 'Стоимость, USD';
COMMENT ON COLUMN public.fuel_purchases.fuel_card_number IS 'Номер топливной карты';
COMMENT ON COLUMN public.fuel_purchases.created_at       IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.fuel_purchases.updated_at       IS 'Тех.колонка источника: момент последнего изменения';
