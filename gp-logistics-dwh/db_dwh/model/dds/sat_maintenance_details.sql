DROP TABLE IF EXISTS dds.sat_maintenance_details;
CREATE TABLE dds.sat_maintenance_details (
    maintenance_hk    varchar(32)  NOT NULL,
    load_date         timestamp    NOT NULL,
    source_name       varchar(50)  NOT NULL,
    batch_id          bigint,
    hash_diff         varchar(32)  NOT NULL,
    maintenance_date  date,
    maintenance_type  varchar(50),
    odometer_reading  numeric(12,1),
    labor_hours       numeric(8,2),
    labor_cost        numeric(14,2),
    parts_cost        numeric(14,2),
    total_cost        numeric(14,2),
    facility_location varchar(80),
    downtime_hours    numeric(8,2),
    service_description varchar(255)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (maintenance_hk)
PARTITION BY RANGE (maintenance_date)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_maintenance_details IS 'Satellite: метрики ТО/ремонта';
COMMENT ON COLUMN dds.sat_maintenance_details.maintenance_hk    IS 'Ссылка на hub_maintenance';
COMMENT ON COLUMN dds.sat_maintenance_details.load_date         IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_maintenance_details.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_maintenance_details.batch_id          IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_maintenance_details.hash_diff         IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_maintenance_details.maintenance_date  IS 'Дата ТО/ремонта';
COMMENT ON COLUMN dds.sat_maintenance_details.maintenance_type  IS 'Тип работ';
COMMENT ON COLUMN dds.sat_maintenance_details.odometer_reading  IS 'Показания одометра, миль';
COMMENT ON COLUMN dds.sat_maintenance_details.labor_hours       IS 'Трудозатраты, часов';
COMMENT ON COLUMN dds.sat_maintenance_details.labor_cost        IS 'Стоимость работ, USD';
COMMENT ON COLUMN dds.sat_maintenance_details.parts_cost        IS 'Стоимость запчастей, USD';
COMMENT ON COLUMN dds.sat_maintenance_details.total_cost        IS 'Итоговая стоимость, USD';
COMMENT ON COLUMN dds.sat_maintenance_details.facility_location IS 'Место проведения';
COMMENT ON COLUMN dds.sat_maintenance_details.downtime_hours    IS 'Простой, часов';
COMMENT ON COLUMN dds.sat_maintenance_details.service_description IS 'Описание работ';
