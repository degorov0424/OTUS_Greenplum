DROP TABLE IF EXISTS dds.hub_trailer;
CREATE TABLE dds.hub_trailer (
    trailer_hk  varchar(32)  NOT NULL,
    trailer_bk  varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trailer_hk);
COMMENT ON TABLE  dds.hub_trailer IS 'Hub: Прицеп';
COMMENT ON COLUMN dds.hub_trailer.trailer_hk  IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_trailer.trailer_bk  IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_trailer.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_trailer.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_trailer.batch_id    IS 'Тех.поле: батч загрузки';
