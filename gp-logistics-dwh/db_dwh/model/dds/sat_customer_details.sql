DROP TABLE IF EXISTS dds.sat_customer_details;
CREATE TABLE dds.sat_customer_details (
    customer_hk            varchar(32)  NOT NULL,
    load_date              timestamp    NOT NULL,
    source_name            varchar(50)  NOT NULL,
    batch_id               bigint,
    hash_diff              varchar(32)  NOT NULL,
    customer_name          varchar(150),
    customer_type          varchar(50),
    credit_terms_days      integer,
    primary_freight_type   varchar(50),
    account_status         varchar(30),
    contract_start_date    date,
    annual_revenue_potential numeric(14,2)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (customer_hk);
COMMENT ON TABLE  dds.sat_customer_details IS 'Satellite: атрибуты клиента';
COMMENT ON COLUMN dds.sat_customer_details.customer_hk            IS 'Ссылка на hub_customer';
COMMENT ON COLUMN dds.sat_customer_details.load_date              IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_customer_details.source_name            IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_customer_details.batch_id               IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_customer_details.hash_diff              IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_customer_details.customer_name          IS 'Наименование клиента';
COMMENT ON COLUMN dds.sat_customer_details.customer_type          IS 'Тип клиента';
COMMENT ON COLUMN dds.sat_customer_details.credit_terms_days      IS 'Отсрочка платежа, дней';
COMMENT ON COLUMN dds.sat_customer_details.primary_freight_type   IS 'Основной тип груза';
COMMENT ON COLUMN dds.sat_customer_details.account_status         IS 'Статус аккаунта';
COMMENT ON COLUMN dds.sat_customer_details.contract_start_date    IS 'Дата начала контракта';
COMMENT ON COLUMN dds.sat_customer_details.annual_revenue_potential IS 'Потенциальная годовая выручка, USD';
