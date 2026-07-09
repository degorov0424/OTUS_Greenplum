DROP TABLE IF EXISTS stg.trucks;
CREATE TABLE stg.trucks (
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
    load_date             timestamp    NOT NULL DEFAULT now(),
    source_name           varchar(255),
    batch_id              bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (truck_id);
COMMENT ON TABLE  stg.trucks IS 'Stage: грузовики';
COMMENT ON COLUMN stg.trucks.truck_id              IS 'Идентификатор грузовика';
COMMENT ON COLUMN stg.trucks.unit_number           IS 'Бортовой номер';
COMMENT ON COLUMN stg.trucks.make                  IS 'Марка';
COMMENT ON COLUMN stg.trucks.model_year            IS 'Год выпуска';
COMMENT ON COLUMN stg.trucks.vin                   IS 'VIN';
COMMENT ON COLUMN stg.trucks.acquisition_date      IS 'Дата приобретения';
COMMENT ON COLUMN stg.trucks.acquisition_mileage   IS 'Пробег при покупке, миль';
COMMENT ON COLUMN stg.trucks.fuel_type             IS 'Тип топлива';
COMMENT ON COLUMN stg.trucks.tank_capacity_gallons IS 'Объём бака, галлон';
COMMENT ON COLUMN stg.trucks.status                IS 'Статус';
COMMENT ON COLUMN stg.trucks.home_terminal         IS 'Домашний терминал';
COMMENT ON COLUMN stg.trucks.load_date             IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.trucks.source_name           IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.trucks.batch_id              IS 'Тех.поле: идентификатор батча';
