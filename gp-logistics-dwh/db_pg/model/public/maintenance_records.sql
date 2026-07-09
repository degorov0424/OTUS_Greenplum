DROP TABLE IF EXISTS public.maintenance_records CASCADE;
CREATE TABLE public.maintenance_records (
    maintenance_id      varchar(20)  NOT NULL,
    truck_id            varchar(16),
    maintenance_date    date,
    maintenance_type    varchar(50),
    odometer_reading    numeric(12,1),
    labor_hours         numeric(8,2),
    labor_cost          numeric(14,2),
    parts_cost          numeric(14,2),
    total_cost          numeric(14,2),
    facility_location   varchar(80),
    downtime_hours      numeric(8,2),
    service_description varchar(255),
    is_deleted              varchar(1),
    created_at          timestamp    NOT NULL DEFAULT now(),
    updated_at          timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_maintenance_records PRIMARY KEY (maintenance_id),
    CONSTRAINT fk_maintenance_records_truck FOREIGN KEY (truck_id)
        REFERENCES public.trucks (truck_id)
);
COMMENT ON TABLE  public.maintenance_records IS 'Источник: ТО/ремонты (';
COMMENT ON COLUMN public.maintenance_records.maintenance_id      IS 'Идентификатор ТО/ремонта';
COMMENT ON COLUMN public.maintenance_records.truck_id            IS 'Грузовик';
COMMENT ON COLUMN public.maintenance_records.maintenance_date    IS 'Дата ТО/ремонта';
COMMENT ON COLUMN public.maintenance_records.maintenance_type    IS 'Тип работ (Inspection/Repair/…)';
COMMENT ON COLUMN public.maintenance_records.odometer_reading    IS 'Показания одометра, миль';
COMMENT ON COLUMN public.maintenance_records.labor_hours         IS 'Трудозатраты, часов';
COMMENT ON COLUMN public.maintenance_records.labor_cost          IS 'Стоимость работ, USD';
COMMENT ON COLUMN public.maintenance_records.parts_cost          IS 'Стоимость запчастей, USD';
COMMENT ON COLUMN public.maintenance_records.total_cost          IS 'Итоговая стоимость, USD';
COMMENT ON COLUMN public.maintenance_records.facility_location   IS 'Место проведения (город)';
COMMENT ON COLUMN public.maintenance_records.downtime_hours      IS 'Простой, часов';
COMMENT ON COLUMN public.maintenance_records.service_description IS 'Описание работ';
COMMENT ON COLUMN public.maintenance_records.created_at          IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.maintenance_records.updated_at          IS 'Тех.колонка источника: момент последнего изменения';
