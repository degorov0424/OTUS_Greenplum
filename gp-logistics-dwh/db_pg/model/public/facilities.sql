DROP TABLE IF EXISTS public.facilities CASCADE;
CREATE TABLE public.facilities (
    facility_id     varchar(16)  NOT NULL,
    facility_name   varchar(150),
    facility_type   varchar(50),
    city            varchar(80),
    state           varchar(10),
    latitude        numeric(9,6),
    longitude       numeric(9,6),
    dock_doors      integer,
    operating_hours varchar(40),
    is_deleted              varchar(1),
    created_at      timestamp    NOT NULL DEFAULT now(),
    updated_at      timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id)
);
COMMENT ON TABLE  public.facilities IS 'Источник: объекты инфраструктуры';
COMMENT ON COLUMN public.facilities.facility_id     IS 'Идентификатор объекта (бизнес-ключ)';
COMMENT ON COLUMN public.facilities.facility_name   IS 'Наименование объекта';
COMMENT ON COLUMN public.facilities.facility_type   IS 'Тип (Cross-Dock/Warehouse/…)';
COMMENT ON COLUMN public.facilities.city            IS 'Город';
COMMENT ON COLUMN public.facilities.state           IS 'Штат';
COMMENT ON COLUMN public.facilities.latitude        IS 'Широта';
COMMENT ON COLUMN public.facilities.longitude       IS 'Долгота';
COMMENT ON COLUMN public.facilities.dock_doors      IS 'Число доковых ворот';
COMMENT ON COLUMN public.facilities.operating_hours IS 'Часы работы (24/7/…)';
COMMENT ON COLUMN public.facilities.created_at      IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.facilities.updated_at      IS 'Тех.колонка источника: момент последнего изменения';

