DROP TABLE IF EXISTS dds.hub_customer;
CREATE TABLE dds.hub_customer (
    customer_hk varchar(32)  NOT NULL,
    customer_bk varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (customer_hk);
COMMENT ON TABLE  dds.hub_customer IS 'Hub: Клиент';
COMMENT ON COLUMN dds.hub_customer.customer_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_customer.customer_bk IS 'Бизнес-ключ: customer_id';
COMMENT ON COLUMN dds.hub_customer.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_customer.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_customer.batch_id    IS 'Тех.поле: батч загрузки';
