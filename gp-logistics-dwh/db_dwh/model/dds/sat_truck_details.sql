DROP TABLE IF EXISTS dds.sat_truck_details;
CREATE TABLE dds.sat_truck_details (
    truck_hk            varchar(32)  NOT NULL,
    load_date           timestamp    NOT NULL,
    source_name         varchar(50)  NOT NULL,
    batch_id            bigint,
    hash_diff           varchar(32)  NOT NULL,
    unit_number         varchar(20),
    make                varchar(50),
    model_year          integer,
    vin                 varchar(20),
    acquisition_date    date,
    acquisition_mileage numeric(12,1),
    fuel_type           varchar(30),
    tank_capacity_gallons numeric(8,2),
    status              varchar(30),
    home_terminal       varchar(60)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (truck_hk);
COMMENT ON TABLE  dds.sat_truck_details IS 'Satellite: атрибуты грузовика';
COMMENT ON COLUMN dds.sat_truck_details.truck_hk            IS 'Ссылка на hub_truck';
COMMENT ON COLUMN dds.sat_truck_details.load_date           IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_truck_details.source_name         IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_truck_details.batch_id            IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_truck_details.hash_diff           IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_truck_details.unit_number         IS 'Бортовой номер';
COMMENT ON COLUMN dds.sat_truck_details.make                IS 'Марка';
COMMENT ON COLUMN dds.sat_truck_details.model_year          IS 'Год выпуска';
COMMENT ON COLUMN dds.sat_truck_details.vin                 IS 'VIN';
COMMENT ON COLUMN dds.sat_truck_details.acquisition_date    IS 'Дата приобретения';
COMMENT ON COLUMN dds.sat_truck_details.acquisition_mileage IS 'Пробег при покупке, миль';
COMMENT ON COLUMN dds.sat_truck_details.fuel_type           IS 'Тип топлива';
COMMENT ON COLUMN dds.sat_truck_details.tank_capacity_gallons IS 'Объём бака, галлон';
COMMENT ON COLUMN dds.sat_truck_details.status             IS 'Статус';
COMMENT ON COLUMN dds.sat_truck_details.home_terminal      IS 'Домашний терминал';
