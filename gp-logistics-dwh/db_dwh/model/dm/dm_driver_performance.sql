DROP TABLE IF EXISTS dm.dm_driver_performance;
CREATE TABLE dm.dm_driver_performance (
    driver_hk            varchar(32)  NOT NULL,
    driver_bk            varchar(16)  NOT NULL,
    driver_name          varchar(121),
    employment_status    varchar(30),
    hire_date            date,
    tenure_years         numeric(5,2),
    years_experience     integer,
    trips_completed      integer,
    total_distance_miles numeric(16,2),
    total_fuel_gallons   numeric(16,2),
    avg_mpg              numeric(8,2),
    total_idle_hours     numeric(14,2),
    date_from            date         NOT NULL,
    date_to              date         NOT NULL,
    load_date            timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dm.dm_driver_performance IS 'Витрина: эффективность водителей';
COMMENT ON COLUMN dm.dm_driver_performance.driver_hk            IS 'Ключ';
COMMENT ON COLUMN dm.dm_driver_performance.driver_bk            IS 'Бизнес-ключ';
COMMENT ON COLUMN dm.dm_driver_performance.driver_name          IS 'ФИО водителя';
COMMENT ON COLUMN dm.dm_driver_performance.employment_status    IS 'Статус занятости';
COMMENT ON COLUMN dm.dm_driver_performance.hire_date            IS 'Дата приёма на работу';
COMMENT ON COLUMN dm.dm_driver_performance.tenure_years         IS 'Стаж в компании, лет';
COMMENT ON COLUMN dm.dm_driver_performance.years_experience     IS 'Общий водительский опыт, лет';
COMMENT ON COLUMN dm.dm_driver_performance.trips_completed      IS 'Число выполненных рейсов за период';
COMMENT ON COLUMN dm.dm_driver_performance.total_distance_miles IS 'Суммарный пробег за период, миль';
COMMENT ON COLUMN dm.dm_driver_performance.total_fuel_gallons   IS 'Расход топлива за период, галлон';
COMMENT ON COLUMN dm.dm_driver_performance.avg_mpg              IS 'Средний расход, миль/галлон';
COMMENT ON COLUMN dm.dm_driver_performance.total_idle_hours     IS 'Суммарное время холостого хода за период, часов';
COMMENT ON COLUMN dm.dm_driver_performance.date_from            IS 'Начало периода';
COMMENT ON COLUMN dm.dm_driver_performance.date_to              IS 'Конец периода';
COMMENT ON COLUMN dm.dm_driver_performance.load_date            IS 'Тех.поле: момент пересчёта витрины';
