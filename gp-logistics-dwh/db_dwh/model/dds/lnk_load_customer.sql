DROP TABLE IF EXISTS dds.lnk_load_customer;
CREATE TABLE dds.lnk_load_customer (
    load_customer_hk varchar(32) NOT NULL,
    load_hk            varchar(32) NOT NULL,
    customer_hk        varchar(32) NOT NULL,
    load_date          timestamp   NOT NULL,
    source_name        varchar(50) NOT NULL,
    batch_id           bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (load_hk);
COMMENT ON TABLE  dds.lnk_load_customer IS 'Link: Заказ -> Клиент';
COMMENT ON COLUMN dds.lnk_load_customer.load_customer_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_load_customer.load_hk            IS 'Ссылка на hub_load';
COMMENT ON COLUMN dds.lnk_load_customer.customer_hk        IS 'Ссылка на hub_customer';
COMMENT ON COLUMN dds.lnk_load_customer.load_date          IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_load_customer.source_name        IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_load_customer.batch_id           IS 'Тех.поле: батч загрузки';
