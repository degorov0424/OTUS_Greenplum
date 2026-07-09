DROP TABLE IF EXISTS stg.routes;
CREATE TABLE stg.routes (
    route_id               varchar(16)  NOT NULL,
    origin_city            varchar(80),
    origin_state           varchar(10),
    destination_city       varchar(80),
    destination_state      varchar(10),
    typical_distance_miles numeric(10,2),
    base_rate_per_mile     numeric(8,3),
    fuel_surcharge_rate    numeric(8,3),
    typical_transit_days   integer,
    is_deleted              varchar(1),
    load_date              timestamp    NOT NULL DEFAULT now(),
    source_name            varchar(255),
    batch_id               bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (route_id);
COMMENT ON TABLE  stg.routes IS 'Stage: маршруты';
COMMENT ON COLUMN stg.routes.route_id               IS 'Идентификатор маршрута';
COMMENT ON COLUMN stg.routes.origin_city            IS 'Город отправления';
COMMENT ON COLUMN stg.routes.origin_state           IS 'Штат отправления';
COMMENT ON COLUMN stg.routes.destination_city       IS 'Город назначения';
COMMENT ON COLUMN stg.routes.destination_state      IS 'Штат назначения';
COMMENT ON COLUMN stg.routes.typical_distance_miles IS 'Типовое расстояние, миль';
COMMENT ON COLUMN stg.routes.base_rate_per_mile     IS 'Базовый тариф, USD/миля';
COMMENT ON COLUMN stg.routes.fuel_surcharge_rate    IS 'Топливная надбавка, USD/миля';
COMMENT ON COLUMN stg.routes.typical_transit_days   IS 'Типовое время в пути, дней';
COMMENT ON COLUMN stg.routes.load_date              IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.routes.source_name            IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.routes.batch_id               IS 'Тех.поле: идентификатор батча';
