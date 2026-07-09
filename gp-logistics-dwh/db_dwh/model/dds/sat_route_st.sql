DROP TABLE IF EXISTS dds.sat_route_st;
CREATE TABLE dds.sat_route_st (
    route_hk      varchar(32)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint,
    is_deleted  varchar(1)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (route_hk);
COMMENT ON TABLE dds.sat_route_st IS 'STS: отслеживание is_deleted для route';
COMMENT ON COLUMN dds.sat_route_st.route_hk IS 'Ссылка на hub_route';
COMMENT ON COLUMN dds.sat_route_st.is_deleted IS 'Y = удалён, NULL = активен';
