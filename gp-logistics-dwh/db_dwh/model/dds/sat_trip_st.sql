DROP TABLE IF EXISTS dds.sat_trip_st;
CREATE TABLE dds.sat_trip_st (
    trip_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trip_hk);
COMMENT ON TABLE dds.sat_trip_st IS 'STS: отслеживание is_deleted для trip';
COMMENT ON COLUMN dds.sat_trip_st.trip_hk IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.sat_trip_st.is_deleted IS 'Y = удалён, NULL = активен';
