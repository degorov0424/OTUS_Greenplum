DROP TABLE IF EXISTS dds.lnk_load_route;
CREATE TABLE dds.lnk_load_route (
    load_route_hk varchar(32) NOT NULL,
    load_hk         varchar(32) NOT NULL,
    route_hk        varchar(32) NOT NULL,
    load_date       timestamp   NOT NULL,
    source_name     varchar(50) NOT NULL,
    batch_id        bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (load_hk);
COMMENT ON TABLE  dds.lnk_load_route IS 'Link: Заказ -> Маршрут';
COMMENT ON COLUMN dds.lnk_load_route.load_route_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_load_route.load_hk         IS 'Ссылка на hub_load';
COMMENT ON COLUMN dds.lnk_load_route.route_hk        IS 'Ссылка на hub_route';
COMMENT ON COLUMN dds.lnk_load_route.load_date       IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_load_route.source_name     IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_load_route.batch_id        IS 'Тех.поле: батч загрузки';
