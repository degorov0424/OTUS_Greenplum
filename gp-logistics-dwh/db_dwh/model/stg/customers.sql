DROP TABLE IF EXISTS stg.customers;
CREATE TABLE stg.customers (
    customer_id               varchar(16)  NOT NULL,
    customer_name             varchar(150),
    customer_type             varchar(50),
    credit_terms_days         integer,
    primary_freight_type      varchar(50),
    account_status            varchar(30),
    contract_start_date       date,
    annual_revenue_potential  numeric(14,2),
    is_deleted              varchar(1),
    load_date                 timestamp    NOT NULL DEFAULT now(),
    source_name               varchar(255),
    batch_id                  bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (customer_id);
COMMENT ON TABLE  stg.customers IS 'Stage: клиенты';
COMMENT ON COLUMN stg.customers.customer_id              IS 'Идентификатор клиента (бизнес-ключ)';
COMMENT ON COLUMN stg.customers.customer_name            IS 'Наименование клиента';
COMMENT ON COLUMN stg.customers.customer_type            IS 'Тип клиента';
COMMENT ON COLUMN stg.customers.credit_terms_days        IS 'Отсрочка платежа, дней';
COMMENT ON COLUMN stg.customers.primary_freight_type     IS 'Основной тип груза';
COMMENT ON COLUMN stg.customers.account_status           IS 'Статус аккаунта';
COMMENT ON COLUMN stg.customers.contract_start_date      IS 'Дата начала контракта';
COMMENT ON COLUMN stg.customers.annual_revenue_potential IS 'Потенциальная годовая выручка, USD';
COMMENT ON COLUMN stg.customers.load_date                IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.customers.source_name              IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.customers.batch_id                 IS 'Тех.поле: идентификатор батча';
