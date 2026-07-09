DROP TABLE IF EXISTS public.trucks CASCADE;
CREATE TABLE public.trucks (
    truck_id              varchar(16)  NOT NULL,
    unit_number           varchar(20),
    make                  varchar(50),
    model_year            integer,
    vin                   varchar(20),
    acquisition_date      date,
    acquisition_mileage   numeric(12,1),
    fuel_type             varchar(30),
    tank_capacity_gallons numeric(8,2),
    status                varchar(30),
    home_terminal         varchar(60),
    is_deleted              varchar(1),
    created_at            timestamp    NOT NULL DEFAULT now(),
    updated_at            timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_trucks PRIMARY KEY (truck_id)
);
COMMENT ON TABLE  public.trucks IS 'Источник: грузовики';
COMMENT ON COLUMN public.trucks.truck_id              IS 'Идентификатор грузовика';
COMMENT ON COLUMN public.trucks.unit_number           IS 'Бортовой номер';
COMMENT ON COLUMN public.trucks.make                  IS 'Марка';
COMMENT ON COLUMN public.trucks.model_year            IS 'Год выпуска';
COMMENT ON COLUMN public.trucks.vin                   IS 'VIN';
COMMENT ON COLUMN public.trucks.acquisition_date      IS 'Дата приобретения';
COMMENT ON COLUMN public.trucks.acquisition_mileage   IS 'Пробег при покупке, миль';
COMMENT ON COLUMN public.trucks.fuel_type             IS 'Тип топлива';
COMMENT ON COLUMN public.trucks.tank_capacity_gallons IS 'Объём бака, галлон';
COMMENT ON COLUMN public.trucks.status                IS 'Статус';
COMMENT ON COLUMN public.trucks.home_terminal         IS 'Домашний терминал';
COMMENT ON COLUMN public.trucks.created_at            IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.trucks.updated_at            IS 'Тех.колонка источника: момент последнего изменения';
