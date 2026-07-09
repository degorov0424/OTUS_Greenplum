DROP TABLE IF EXISTS dm.dm_truck_utilization;
CREATE TABLE dm.dm_truck_utilization (
    truck_hk               varchar(32)  NOT NULL,
    truck_bk               varchar(16)  NOT NULL,
    make                   varchar(50),
    model_year             integer,
    fuel_type              varchar(30),
    status                 varchar(30),
    trips_count            integer,
    total_distance_miles   numeric(16,2),
    total_revenue          numeric(18,2),
    total_fuel_gallons     numeric(16,2),
    total_fuel_cost        numeric(18,2),
    repairs_count          integer,
    total_maintenance_cost numeric(18,2),
    date_from              date         NOT NULL,
    date_to                date         NOT NULL,
    load_date              timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dm.dm_truck_utilization IS 'Витрина: утилизация грузовиков';
COMMENT ON COLUMN dm.dm_truck_utilization.truck_hk               IS 'Ключ';
COMMENT ON COLUMN dm.dm_truck_utilization.truck_bk               IS 'Бизнес-ключ';
COMMENT ON COLUMN dm.dm_truck_utilization.make                   IS 'Марка';
COMMENT ON COLUMN dm.dm_truck_utilization.model_year             IS 'Год выпуска';
COMMENT ON COLUMN dm.dm_truck_utilization.fuel_type              IS 'Тип топлива';
COMMENT ON COLUMN dm.dm_truck_utilization.status                 IS 'Статус';
COMMENT ON COLUMN dm.dm_truck_utilization.trips_count            IS 'Количество рейсов за период';
COMMENT ON COLUMN dm.dm_truck_utilization.total_distance_miles   IS 'Пробег за период, миль';
COMMENT ON COLUMN dm.dm_truck_utilization.total_revenue          IS 'Выручка за период, USD';
COMMENT ON COLUMN dm.dm_truck_utilization.total_fuel_gallons     IS 'Расход топлива за период, галлон';
COMMENT ON COLUMN dm.dm_truck_utilization.total_fuel_cost        IS 'Стоимость топлива за период, USD';
COMMENT ON COLUMN dm.dm_truck_utilization.repairs_count          IS 'Количество ремонтов/ТО за период';
COMMENT ON COLUMN dm.dm_truck_utilization.total_maintenance_cost IS 'Суммарная стоимость ремонтов за период, USD';
COMMENT ON COLUMN dm.dm_truck_utilization.date_from              IS 'Начало периода';
COMMENT ON COLUMN dm.dm_truck_utilization.date_to                IS 'Конец периода';
COMMENT ON COLUMN dm.dm_truck_utilization.load_date              IS 'Тех.поле: момент пересчёта витрины';
