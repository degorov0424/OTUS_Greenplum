DROP TABLE IF EXISTS dds.sat_trailer_st;
CREATE TABLE dds.sat_trailer_st (
    trailer_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trailer_hk);
COMMENT ON TABLE dds.sat_trailer_st IS 'STS: отслеживание is_deleted для trailer';
COMMENT ON COLUMN dds.sat_trailer_st.trailer_hk IS 'Ссылка на hub_trailer';
COMMENT ON COLUMN dds.sat_trailer_st.is_deleted IS 'Y = удалён, NULL = активен';
