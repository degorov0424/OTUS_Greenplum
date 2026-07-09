DROP TABLE IF EXISTS dds.sat_facility_st;
CREATE TABLE dds.sat_facility_st (
    facility_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (facility_hk);
COMMENT ON TABLE dds.sat_facility_st IS 'STS: отслеживание is_deleted для facility';
COMMENT ON COLUMN dds.sat_facility_st.facility_hk IS 'Ссылка на hub_facility';
COMMENT ON COLUMN dds.sat_facility_st.is_deleted IS 'Y = удалён, NULL = активен';
