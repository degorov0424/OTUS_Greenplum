DROP TABLE IF EXISTS dds.sat_driver_details;
CREATE TABLE dds.sat_driver_details (
    driver_hk        varchar(32)  NOT NULL,
    load_date        timestamp    NOT NULL,
    source_name      varchar(50)  NOT NULL,
    batch_id         bigint,
    hash_diff        varchar(32)  NOT NULL,
    first_name       varchar(60),
    last_name        varchar(60),
    hire_date        date,
    termination_date date,
    license_number   varchar(50),
    license_state    varchar(10),
    date_of_birth    date,
    home_terminal    varchar(60),
    employment_status varchar(30),
    cdl_class        varchar(10),
    years_experience integer
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (driver_hk);
COMMENT ON TABLE  dds.sat_driver_details IS 'Satellite: атрибуты водителя';
COMMENT ON COLUMN dds.sat_driver_details.driver_hk         IS 'Ссылка на hub_driver';
COMMENT ON COLUMN dds.sat_driver_details.load_date         IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_driver_details.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_driver_details.batch_id          IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_driver_details.hash_diff         IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_driver_details.first_name        IS 'Имя';
COMMENT ON COLUMN dds.sat_driver_details.last_name         IS 'Фамилия';
COMMENT ON COLUMN dds.sat_driver_details.hire_date         IS 'Дата приёма на работу';
COMMENT ON COLUMN dds.sat_driver_details.termination_date  IS 'Дата увольнения';
COMMENT ON COLUMN dds.sat_driver_details.license_number    IS 'Номер прав';
COMMENT ON COLUMN dds.sat_driver_details.license_state     IS 'Штат выдачи прав';
COMMENT ON COLUMN dds.sat_driver_details.date_of_birth     IS 'Дата рождения';
COMMENT ON COLUMN dds.sat_driver_details.home_terminal     IS 'Домашний терминал';
COMMENT ON COLUMN dds.sat_driver_details.employment_status IS 'Статус занятости';
COMMENT ON COLUMN dds.sat_driver_details.cdl_class         IS 'Класс прав CDL';
COMMENT ON COLUMN dds.sat_driver_details.years_experience  IS 'Общий водительский стаж, лет';
