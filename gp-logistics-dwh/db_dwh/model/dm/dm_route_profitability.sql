DROP TABLE IF EXISTS dm.dm_route_profitability;
CREATE TABLE dm.dm_route_profitability (
    route_hk              varchar(32)  NOT NULL,
    route_bk              varchar(16)  NOT NULL,
    origin_city           varchar(80),
    origin_state          varchar(10),
    destination_city      varchar(80),
    destination_state     varchar(10),
    typical_distance_miles numeric(10,2),
    trips_count           integer,
    total_revenue         numeric(18,2),
    total_fuel_cost       numeric(18,2),
    profit                numeric(18,2),
    profit_margin_pct     numeric(7,2),
    date_from             date         NOT NULL,
    date_to               date         NOT NULL,
    load_date             timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dm.dm_route_profitability IS 'Витрина: прибыльность маршрутов';
COMMENT ON COLUMN dm.dm_route_profitability.route_hk               IS 'Ссылка на hub_route';
COMMENT ON COLUMN dm.dm_route_profitability.route_bk               IS 'Бизнес-ключ: route_id';
COMMENT ON COLUMN dm.dm_route_profitability.origin_city            IS 'Город отправления';
COMMENT ON COLUMN dm.dm_route_profitability.origin_state           IS 'Штат отправления';
COMMENT ON COLUMN dm.dm_route_profitability.destination_city       IS 'Город назначения';
COMMENT ON COLUMN dm.dm_route_profitability.destination_state      IS 'Штат назначения';
COMMENT ON COLUMN dm.dm_route_profitability.typical_distance_miles IS 'Типовое расстояние, миль';
COMMENT ON COLUMN dm.dm_route_profitability.trips_count            IS 'Количество рейсов по маршруту за период';
COMMENT ON COLUMN dm.dm_route_profitability.total_revenue          IS 'Выручка за период, USD';
COMMENT ON COLUMN dm.dm_route_profitability.total_fuel_cost        IS 'Стоимость топлива за период, USD';
COMMENT ON COLUMN dm.dm_route_profitability.profit                 IS 'Прибыль';
COMMENT ON COLUMN dm.dm_route_profitability.profit_margin_pct     IS 'Рентабельность';
COMMENT ON COLUMN dm.dm_route_profitability.date_from             IS 'Начало периода';
COMMENT ON COLUMN dm.dm_route_profitability.date_to               IS 'Конец периода';
COMMENT ON COLUMN dm.dm_route_profitability.load_date             IS 'Тех.поле: момент пересчёта витрины';
