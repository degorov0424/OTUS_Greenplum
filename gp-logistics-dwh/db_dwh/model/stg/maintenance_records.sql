DROP TABLE IF EXISTS stg.maintenance_records;
CREATE TABLE stg.maintenance_records (
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
    load_date           timestamp    NOT NULL DEFAULT now(),
    source_name         varchar(255),
    batch_id            bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (maintenance_id)
PARTITION BY RANGE (maintenance_date)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.maintenance_records IS 'Stage: ТО/ремонты ';
COMMENT ON COLUMN stg.maintenance_records.maintenance_id      IS 'Идентификатор ТО/ремонта';
COMMENT ON COLUMN stg.maintenance_records.truck_id            IS 'Грузовик';
COMMENT ON COLUMN stg.maintenance_records.maintenance_date    IS 'Дата ТО/ремонта';
COMMENT ON COLUMN stg.maintenance_records.maintenance_type    IS 'Тип работ';
COMMENT ON COLUMN stg.maintenance_records.odometer_reading    IS 'Показания одометра, миль';
COMMENT ON COLUMN stg.maintenance_records.labor_hours         IS 'Трудозатраты, часов';
COMMENT ON COLUMN stg.maintenance_records.labor_cost          IS 'Стоимость работ, USD';
COMMENT ON COLUMN stg.maintenance_records.parts_cost          IS 'Стоимость запчастей, USD';
COMMENT ON COLUMN stg.maintenance_records.total_cost          IS 'Итоговая стоимость, USD';
COMMENT ON COLUMN stg.maintenance_records.facility_location   IS 'Место проведения';
COMMENT ON COLUMN stg.maintenance_records.downtime_hours      IS 'Простой, часов';
COMMENT ON COLUMN stg.maintenance_records.service_description IS 'Описание работ';
COMMENT ON COLUMN stg.maintenance_records.load_date           IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.maintenance_records.source_name         IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.maintenance_records.batch_id            IS 'Тех.поле: идентификатор батча';
