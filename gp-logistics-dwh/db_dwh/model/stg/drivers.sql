DROP TABLE IF EXISTS stg.drivers;
CREATE TABLE stg.drivers (
    driver_id         varchar(16)  NOT NULL,
    first_name        varchar(60),
    last_name         varchar(60),
    hire_date         date,
    termination_date  date,
    license_number    varchar(50),
    license_state     varchar(10),
    date_of_birth     date,
    home_terminal     varchar(60),
    employment_status varchar(30),
    cdl_class         varchar(10),
    years_experience  integer,
    is_deleted              varchar(1),
    load_date         timestamp    NOT NULL DEFAULT now(),
    source_name       varchar(255),
    batch_id          bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (driver_id);
COMMENT ON TABLE  stg.drivers IS 'Stage: водители ';
COMMENT ON COLUMN stg.drivers.driver_id         IS 'Идентификатор водителя (бизнес-ключ)';
COMMENT ON COLUMN stg.drivers.first_name        IS 'Имя';
COMMENT ON COLUMN stg.drivers.last_name         IS 'Фамилия';
COMMENT ON COLUMN stg.drivers.hire_date         IS 'Дата приёма на работу';
COMMENT ON COLUMN stg.drivers.termination_date  IS 'Дата увольнения';
COMMENT ON COLUMN stg.drivers.license_number    IS 'Номер прав';
COMMENT ON COLUMN stg.drivers.license_state     IS 'Штат выдачи прав';
COMMENT ON COLUMN stg.drivers.date_of_birth     IS 'Дата рождения';
COMMENT ON COLUMN stg.drivers.home_terminal     IS 'Домашний терминал';
COMMENT ON COLUMN stg.drivers.employment_status IS 'Статус занятости';
COMMENT ON COLUMN stg.drivers.cdl_class         IS 'Класс прав CDL';
COMMENT ON COLUMN stg.drivers.years_experience  IS 'Общий водительский стаж, лет';
COMMENT ON COLUMN stg.drivers.load_date         IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.drivers.source_name       IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.drivers.batch_id          IS 'Тех.поле: идентификатор батча';
