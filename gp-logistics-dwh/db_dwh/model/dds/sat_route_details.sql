DROP TABLE IF EXISTS dds.sat_route_details;
CREATE TABLE dds.sat_route_details (
    route_hk             varchar(32)  NOT NULL,
    load_date            timestamp    NOT NULL,
    source_name          varchar(50)  NOT NULL,
    batch_id             bigint,
    hash_diff            varchar(32)  NOT NULL,
    origin_city          varchar(80),
    origin_state         varchar(10),
    destination_city     varchar(80),
    destination_state    varchar(10),
    typical_distance_miles numeric(10,2),
    base_rate_per_mile   numeric(8,3),
    fuel_surcharge_rate  numeric(8,3),
    typical_transit_days integer
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (route_hk);
COMMENT ON TABLE  dds.sat_route_details IS 'Satellite: атрибуты маршрута';
COMMENT ON COLUMN dds.sat_route_details.route_hk             IS 'Ссылка на hub_route';
COMMENT ON COLUMN dds.sat_route_details.load_date            IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_route_details.source_name          IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_route_details.batch_id             IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_route_details.hash_diff            IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_route_details.origin_city          IS 'Город отправления';
COMMENT ON COLUMN dds.sat_route_details.origin_state         IS 'Штат отправления';
COMMENT ON COLUMN dds.sat_route_details.destination_city     IS 'Город назначения';
COMMENT ON COLUMN dds.sat_route_details.destination_state    IS 'Штат назначения';
COMMENT ON COLUMN dds.sat_route_details.typical_distance_miles IS 'Типовое расстояние, миль';
COMMENT ON COLUMN dds.sat_route_details.base_rate_per_mile   IS 'Базовый тариф, USD/миля';
COMMENT ON COLUMN dds.sat_route_details.fuel_surcharge_rate  IS 'Топливная надбавка, USD/миля';
COMMENT ON COLUMN dds.sat_route_details.typical_transit_days IS 'Типовое время в пути, дней';
