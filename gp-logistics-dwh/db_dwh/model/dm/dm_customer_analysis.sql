DROP TABLE IF EXISTS dm.dm_customer_analysis;
CREATE TABLE dm.dm_customer_analysis (
    customer_hk           varchar(32)  NOT NULL,
    customer_bk           varchar(16)  NOT NULL,
    customer_name         varchar(150),
    customer_type         varchar(50),
    account_status        varchar(30),
    orders_count          integer,
    completed_orders      integer,
    total_revenue         numeric(18,2),
    avg_revenue_per_order numeric(18,2),
    total_weight_lbs      numeric(18,2),
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
COMMENT ON TABLE  dm.dm_customer_analysis IS 'Витрина: анализ клиентов';
COMMENT ON COLUMN dm.dm_customer_analysis.customer_hk           IS 'Ссылка на hub_customer';
COMMENT ON COLUMN dm.dm_customer_analysis.customer_bk           IS 'Бизнес-ключ';
COMMENT ON COLUMN dm.dm_customer_analysis.customer_name         IS 'Наименование клиента';
COMMENT ON COLUMN dm.dm_customer_analysis.customer_type         IS 'Тип клиента';
COMMENT ON COLUMN dm.dm_customer_analysis.account_status        IS 'Статус аккаунта';
COMMENT ON COLUMN dm.dm_customer_analysis.orders_count          IS 'Количество заказов за период';
COMMENT ON COLUMN dm.dm_customer_analysis.completed_orders      IS 'Завершённых заказов за период';
COMMENT ON COLUMN dm.dm_customer_analysis.total_revenue         IS 'Суммарная выручка за период, USD';
COMMENT ON COLUMN dm.dm_customer_analysis.avg_revenue_per_order IS 'Средняя выручка на заказ, USD';
COMMENT ON COLUMN dm.dm_customer_analysis.total_weight_lbs      IS 'Суммарный вес за период, фунтов';
COMMENT ON COLUMN dm.dm_customer_analysis.date_from             IS 'Начало периода';
COMMENT ON COLUMN dm.dm_customer_analysis.date_to               IS 'Конец периода';
COMMENT ON COLUMN dm.dm_customer_analysis.load_date             IS 'Тех.поле: момент пересчёта витрины';
