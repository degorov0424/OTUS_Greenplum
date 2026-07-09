DROP TABLE IF EXISTS public.drivers CASCADE;
CREATE TABLE public.drivers (
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
    created_at        timestamp    NOT NULL DEFAULT now(),
    updated_at        timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_drivers PRIMARY KEY (driver_id)
);
COMMENT ON TABLE  public.drivers IS 'Источник: водители';
COMMENT ON COLUMN public.drivers.driver_id         IS 'Идентификатор водителя';
COMMENT ON COLUMN public.drivers.first_name        IS 'Имя';
COMMENT ON COLUMN public.drivers.last_name         IS 'Фамилия';
COMMENT ON COLUMN public.drivers.hire_date         IS 'Дата приёма на работу';
COMMENT ON COLUMN public.drivers.termination_date  IS 'Дата увольнения';
COMMENT ON COLUMN public.drivers.license_number    IS 'Номер водительских прав';
COMMENT ON COLUMN public.drivers.license_state     IS 'Штат выдачи прав';
COMMENT ON COLUMN public.drivers.date_of_birth     IS 'Дата рождения';
COMMENT ON COLUMN public.drivers.home_terminal     IS 'Домашний терминал';
COMMENT ON COLUMN public.drivers.employment_status IS 'Статус занятости (Active/Terminated/…)';
COMMENT ON COLUMN public.drivers.cdl_class         IS 'Класс прав CDL (A/B/C)';
COMMENT ON COLUMN public.drivers.years_experience  IS 'Общий водительский стаж, лет';
COMMENT ON COLUMN public.drivers.created_at        IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.drivers.updated_at        IS 'Тех.колонка источника: момент последнего изменения';
