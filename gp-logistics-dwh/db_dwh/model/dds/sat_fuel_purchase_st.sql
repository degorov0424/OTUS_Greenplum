DROP TABLE IF EXISTS dds.sat_fuel_purchase_st;
CREATE TABLE dds.sat_fuel_purchase_st (
    fuel_purchase_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (fuel_purchase_hk);
COMMENT ON TABLE dds.sat_fuel_purchase_st IS 'STS: отслеживание is_deleted для fuel_purchase';
COMMENT ON COLUMN dds.sat_fuel_purchase_st.fuel_purchase_hk IS 'Ссылка на hub_fuel_purchase';
COMMENT ON COLUMN dds.sat_fuel_purchase_st.is_deleted IS 'Y = удалён, NULL = активен';
