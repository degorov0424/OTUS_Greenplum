DROP TABLE IF EXISTS dds.hub_route;
CREATE TABLE dds.hub_route (
    route_hk    varchar(32)  NOT NULL,
    route_bk    varchar(16)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (route_hk);
COMMENT ON TABLE  dds.hub_route IS 'Hub: Маршрут';
COMMENT ON COLUMN dds.hub_route.route_hk    IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_route.route_bk    IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_route.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_route.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_route.batch_id    IS 'Тех.поле: батч загрузки';
