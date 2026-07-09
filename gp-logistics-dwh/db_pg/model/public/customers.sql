DROP TABLE IF EXISTS public.customers CASCADE;
CREATE TABLE public.customers (
    customer_id               varchar(16)  NOT NULL,
    customer_name             varchar(150),
    customer_type             varchar(50),
    credit_terms_days         integer,
    primary_freight_type      varchar(50),
    account_status            varchar(30),
    contract_start_date       date,
    annual_revenue_potential  numeric(14,2),
    is_deleted              varchar(1),
    created_at                timestamp    NOT NULL DEFAULT now(),
    updated_at                timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);
COMMENT ON TABLE  public.customers IS 'Источник: клиенты';
COMMENT ON COLUMN public.customers.customer_id              IS 'Идентификатор клиента (бизнес-ключ)';
COMMENT ON COLUMN public.customers.customer_name            IS 'Наименование клиента';
COMMENT ON COLUMN public.customers.customer_type            IS 'Тип клиента (Dedicated/Spot/…)';
COMMENT ON COLUMN public.customers.credit_terms_days        IS 'Отсрочка платежа, дней';
COMMENT ON COLUMN public.customers.primary_freight_type     IS 'Основной тип груза';
COMMENT ON COLUMN public.customers.account_status           IS 'Статус аккаунта (Active/Inactive/…)';
COMMENT ON COLUMN public.customers.contract_start_date      IS 'Дата начала контракта';
COMMENT ON COLUMN public.customers.annual_revenue_potential IS 'Потенциальная годовая выручка, USD';
COMMENT ON COLUMN public.customers.created_at               IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.customers.updated_at               IS 'Тех.колонка источника: момент последнего изменения';
