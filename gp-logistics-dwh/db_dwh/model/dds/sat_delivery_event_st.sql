DROP TABLE IF EXISTS dds.sat_delivery_event_st;
CREATE TABLE dds.sat_delivery_event_st (
    delivery_event_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (delivery_event_hk);
COMMENT ON TABLE dds.sat_delivery_event_st IS 'STS: отслеживание is_deleted для delivery_event';
COMMENT ON COLUMN dds.sat_delivery_event_st.delivery_event_hk IS 'Ссылка на hub_delivery_event';
COMMENT ON COLUMN dds.sat_delivery_event_st.is_deleted IS 'Y = удалён, NULL = активен';
